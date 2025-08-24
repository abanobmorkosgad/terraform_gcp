resource "google_compute_instance" "instance" {
  for_each     = var.zones_types
  name         = "my-instance-${each.key}"
  machine_type = each.value
  zone         = each.key

  tags = [tolist(google_compute_firewall.ssh-22.target_tags)[0], tolist(google_compute_firewall.http-80.target_tags)[0]]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {

    }
  }

  metadata_startup_script = "echo hi > /test.txt"
}

output "insance_ips" {
  value = google_compute_instance.instance[*].network_interface[0].access_config[0].nat_ip
}

data "google_compute_image" "debian" {
  family  = "debian-11"
  project = "debian-cloud"

}