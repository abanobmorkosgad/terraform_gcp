provider "google" {
  region      = "us-west2"
  credentials = file("mystical-vial-466908-c7-fedd70cc8bd8.json")
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_integer" "random" {
  min = 100
  max = 100000
}