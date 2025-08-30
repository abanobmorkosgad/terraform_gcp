terraform {
  required_version = ">= 1.9.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.47.0"
    }
  }
}

provider "google" {
  project = "mystical-vial-466908-c7"
  credentials = file("mystical-vial-466908-c7-e8a27ce47304.json")
}