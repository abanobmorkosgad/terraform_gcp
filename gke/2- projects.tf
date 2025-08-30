# resource "google_project" "host-staging" {
#   name                = local.host_project
#   project_id          = local.host_project_id
#   org_id              = local.org_id
#   billing_account     = local.billing_account
#   auto_create_network = false
# }

# resource "google_project" "k8s-staging" {
#   name                = local.service_project
#   project_id          = local.service_project_id
#   org_id              = local.org_id
#   billing_account     = local.billing_account
#   auto_create_network = false
# }

# resource "google_project_service" "host" {
#   count   = length(local.project_ids)
#   project = local.project_ids[count.index]
#   service = local.projects_api
# }