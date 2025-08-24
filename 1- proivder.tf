terraform {
  required_version = ">= 1.9.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.47.0"
    }
  }
  backend "gcs" {
    bucket = "my-terraform-state-bucket"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "mystical-vial-466908-c7"
  region  = "us-central1"
}