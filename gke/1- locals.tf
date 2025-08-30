locals {
  region             = "us-west2"
  org_id             = "0"
  billing_account    = "01913B-AE1F0C-B0CD2C"
  host_project       = "host-project"
  service_project    = "service-project"
  host_project_id    = "host-project-470610"
  service_project_id = "service-project-470610"
  projects_api       = "container.googleapis.com"
  secondary_ip_range = {
    "pod-ip-range"       = "10.0.0.0/14",
    "services-ip-ranges" = "10.4.0.0/19"
  }
  project_ids = [
    local.host_project_id,
    local.service_project_id,
  ]
}