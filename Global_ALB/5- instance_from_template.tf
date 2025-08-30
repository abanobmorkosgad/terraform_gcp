data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

resource "google_compute_region_instance_template" "us-central1" {
  name        = "appserver-template"
  description = "This template is used to create app server instances."
  region    = "us-central1"
  
  tags = [tolist(google_compute_firewall.ssh-22.target_tags)[0], tolist(google_compute_firewall.http-80.target_tags)[0]]

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
  }

  network_interface {
    network = google_compute_subnetwork.subnet_us-central1.id
    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_region_instance_template" "us-central2" {
  name        = "appserver-template"
  description = "This template is used to create app server instances."
  region    = "us-central2"
  
  tags = [tolist(google_compute_firewall.ssh-22.target_tags)[0], tolist(google_compute_firewall.http-80.target_tags)[0]]

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
  }

  network_interface {
    network = google_compute_subnetwork.subnet_us-central2.id
    access_config {
      // Ephemeral IP
    }
  }
}