resource "google_container_node_pool" "general" {
  name       = "general-pool"
  location   = local.region
  cluster    = google_container_cluster.gke.name
  project    = local.service_project_id
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    labels = {
      env = "staging"
    }
    machine_type    = "e2-medium"
    service_account = google_service_account.k8s-staging.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}