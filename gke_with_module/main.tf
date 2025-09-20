provider "google" {
  project     = "mystical-vial-466908-c7"
  region      = "us-central1"
  credentials = file("mystical-vial-466908-c7-67205fecedbb.json")
}

# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "mystical-vial-466908-c7"
  name                       = "gke-test"
  region                     = "us-central1"
  zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
  network                    = "vpc"
  subnetwork                 = "subnet-us-central1"
  ip_range_pods              = "pods-ip-range"
  ip_range_services          = "svcs-ip-range"
  http_load_balancing        = true
  network_policy             = true
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  dns_cache                  = false
  remove_default_node_pool   = true
  
  node_pools = [
    {
      name                        = "node-pool-1"
      machine_type                = "e2-medium"
      node_locations              = "us-central1-b,us-central1-c"
      min_count                   = 1
      max_count                   = 2
      local_ssd_count             = 0
      spot                        = false
      disk_size_gb                = 100
      disk_type                   = "pd-standard"
      image_type                  = "COS_CONTAINERD"
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      auto_repair                 = true
      auto_upgrade                = true
      create_service_account=true
      service_account_name             = "gke-node-pool@mystical-vial-466908-c7.iam.gserviceaccount.com"
      preemptible                 = false
      initial_node_count          = 1
    },
    {
      name                        = "node-pool-2"
      machine_type                = "e2-medium"
      node_locations              = "us-central1-b,us-central1-c"
      min_count                   = 1
      max_count                   = 1
      local_ssd_count             = 0
      spot                        = false
      disk_size_gb                = 100
      disk_type                   = "pd-standard"
      image_type                  = "COS_CONTAINERD"
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      auto_repair                 = true
      auto_upgrade                = true
      service_account_name             = "gke-node-pool@mystical-vial-466908-c7.iam.gserviceaccount.com"
      preemptible                 = false
      initial_node_count          = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}