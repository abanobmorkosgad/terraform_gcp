resource "google_service_account" "logging_service_account" {
  account_id   = "logging-service-account"
  display_name = "logging-service-account"
}

resource "google_service_account_iam_member" "logging-account-iam" {
  role               = "roles/logging.logWriter"
  member             = "serviceAccount:${google_service_account.logging_service_account.email}"
  service_account_id = google_service_account.logging_service_account.name
}

resource "google_service_account_iam_member" "monitoring-account-iam" {
  role               = "roles/monitoring.metricWriter"
  member             = "serviceAccount:${google_service_account.logging_service_account.email}"
  service_account_id = google_service_account.logging_service_account.name
}

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

  service_account {
    email  = google_service_account.logging_service_account.email
    scopes = ["cloud-platform"]
  }

  network_interface {
    network = google_compute_subnetwork.subnet.id
    access_config {
      // Ephemeral IP
    }
  }
}