resource "google_compute_shared_vpc_host_project" "host" {
  project = local.host_project_id
}

# A service project gains access to network resources provided by its
# associated host project.
resource "google_compute_shared_vpc_service_project" "service" {
  host_project    = local.host_project_id
  service_project = local.service_project_id

  depends_on = [google_compute_shared_vpc_host_project.host]
}

resource "google_service_account" "k8s-staging" {
  account_id = "k8s-staging"
  project    = local.service_project_id
}

resource "google_compute_subnetwork_iam_binding" "binding" {
  project    = google_compute_shared_vpc_host_project.host.project
  region     = local.region
  subnetwork = google_compute_subnetwork.private.name
  role       = "roles/compute.networkUser"
  members = [
    "serviceAccount:${google_service_account.k8s-staging.email}",
    "serviceAccount:service-project-470610@cloudservices.gserviceaccount.com",
    "serviceAccount:service-service-project-470610@container-engine-robot.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "container-engine" {
  project = google_compute_shared_vpc_host_project.host.project
  role    = "roles/container.hostServiceAgentUser"
  members = [
    "serviceAccount:service-service-project-470610@container-engine-robot.iam.gserviceaccount.com"
  ]
}