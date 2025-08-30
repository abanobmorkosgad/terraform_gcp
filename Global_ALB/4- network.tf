resource "google_compute_network" "vpc" {
  name                    = "vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_us-central1" {
  name          = "subnet-us-central1"
  region        = "us-central1"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "subnet_us-central2" {
  name          = "subnet-us-central2"
  region        = "us-central2"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc.id
}


# resource "google_compute_subnetwork" "proxy_only_subnet" {
#   name          = "proxy-only-subnet"
#   region        = "us-central1"
#   ip_cidr_range = "10.0.2.0/24"
#   network       = google_compute_network.vpc.id
#   purpose       = "REGIONAL_MANAGED_PROXY"
#   role          = "ACTIVE"
# }

resource "google_compute_firewall" "http-80" {
  name    = "http-firewall"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

resource "google_compute_firewall" "ssh-22" {
  name    = "ssh-firewall"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}