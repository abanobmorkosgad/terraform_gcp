resource "google_compute_instance" "instance" {
  for_each     = var.instances
  name         = "instance-${each.key}"
  machine_type = each.value
  zone         = each.key
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {}
  }
}
