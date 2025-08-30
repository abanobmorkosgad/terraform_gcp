resource "google_compute_firewall" "allow_hc" {
  name    = "allow-health-checks"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80"] # or whatever your health check port is
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  target_tags = ["allow-health-checks"] # must match your MIG instance tags
}

resource "google_compute_instance_template" "private_ip_template" {
  name        = "private_ip_template"
  description = "This template is used to create app server instances."

  tags = [
    tolist(google_compute_firewall.ssh-22.target_tags)[0],
    tolist(google_compute_firewall.http-80.target_tags)[0],
    tolist(google_compute_firewall.allow_hc.target_tags)[0]
  ]

  labels = {
    environment = "dev"
  }

  instance_description = "description assigned to instances"
  machine_type         = "e2-medium"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = data.google_compute_image.debian.name
    auto_delete  = true
    boot         = true
    // backup the disk every day
    resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  metadata_startup_script = file("startup-script.sh")

  network_interface {
    network = google_compute_subnetwork.private_subnet.id
  }
}

resource "google_compute_router" "router" {
  name    = "my-router"
  network = google_compute_network.vpc.name
  region  = "us-central1"
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_instance_group_manager" "private_appserver" {
  name = "private_appserver-igm"

  base_instance_name = "private_app"
  zone               = "us-central1-a"

  version {
    instance_template = google_compute_instance_template.private_ip_template.self_link_unique
  }

  named_port {
    name = "customhttp"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 300
  }
}

resource "google_compute_region_autoscaler" "foobar" {
  name   = "my-region-private-autoscaler"
  region = "us-central1"
  target = google_compute_region_instance_group_manager.private_appserver.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}