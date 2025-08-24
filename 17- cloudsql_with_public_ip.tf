resource "random_id" "server" {

  byte_length = 4
}


resource "google_sql_database_instance" "mydb" {
  name             = "mydb-${random_id.server.hex}"
  region          = "us-central1"
  database_version = "MYSQL_8_0"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    edition = "ENTERPRISE"
    availability_type = "ZONAL"
    disk_size = 10
    disk_type = "PD_SSD"
    disk_autoresize = true
    disk_autoresize_limit = "10GB"
    backup_configuration {
      enabled = true
      binary_log_enabled = true
    }

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name = "my-network"
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_user" "mydb_user" {
  name     = "mydb_user"
  instance = google_sql_database_instance.mydb.name
  password = "mydb_password"
}

resource "google_sql_database" "mydb_database" {
  name     = "mydb_database"
  instance = google_sql_database_instance.mydb.name
}