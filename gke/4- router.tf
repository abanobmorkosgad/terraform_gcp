resource "google_compute_router" "router" {
  name    = "router"
  network = google_compute_network.main.self_link
  region  = local.region
  project = local.host_project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat"
  router                             = google_compute_router.router.name
  region                             = local.region
  project                            = local.host_project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  depends_on = [google_compute_subnetwork.private]
}