resource "google_container_cluster" "gke" {
  name            = "gke-cluster"
  location        = local.region
  project         = local.service_project_id
  network         = google_compute_network.main.self_link
  subnetwork      = google_compute_subnetwork.private.self_link
  networking_mode = "VPC_NATIVE"

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ip-range"
    services_secondary_range_name = "services-ip-range"
  }

  network_policy {
    enabled  = true
    provider = "PROVIDER_UNSPECIFIED"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "${local.service_project_id}.svc.id.goog"
  }
}    