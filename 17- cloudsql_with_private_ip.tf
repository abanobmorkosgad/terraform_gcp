resource "google_compute_network" "sql_vpc" {
  name                    = "sql_vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_subnet_sql" {
  name          = "subnet"
  region        = "us-central1"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc.id
}

resource "random_id" "server" {

  byte_length = 4
}


resource "google_sql_database_instance" "private_mydb" {
  name             = "private-mydb-${random_id.server.hex}"
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
      ipv4_enabled = false
      private_network = google_compute_network.sql_vpc.self_link
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