data "terraform_remote_state" "remote_data_source" {
  backend = "gcs"
  config = {
    bucket = "my-terraform-state-bucket"
    prefix = "terraform/state"
  }
}

output "sql_ip" {
  value = data.terraform_remote_state.remote_data_source.google_sql_database_instance.mydb.ip_address
}