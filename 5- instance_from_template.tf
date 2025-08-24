resource "google_compute_instance_template" "default" {
  name        = "appserver-template"
  description = "This template is used to create app server instances."

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
    resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  metadata_startup_script = file("startup-script.sh")

  network_interface {
    network = google_compute_subnetwork.subnet.id
    access_config {
      // Ephemeral IP
    }
  }
}

data "google_compute_zones" "available" {
  status = "UP"
}


resource "google_compute_instance_from_template" "tpl" {
  for_each = toset(data.google_compute_zones.available.names)
  name     = "instance-from-template-${each.key}"
  zone     = each.key

  source_instance_template = google_compute_instance_template.default.self_link_unique

  // Override fields from instance template
  can_ip_forward = false
}