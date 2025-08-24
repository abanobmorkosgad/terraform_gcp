module "network" {
  source  = "terraform-google-modules/network/google"
  version = "11.1.1"
  network_name = "mvpc"
  project_id = "mystical-vial-466908-c7"
  subnets = [
    {
      subnet_name   = "subnet1"
      subnet_ip     = "10.0.0.0/24"
      subnet_region        = "us-central1"
    }
  ]
}

output "subnet_ip" {
  value = module.network.subnets_ips
}

module "instance" {
  source  = "./modules/instance"
  instances = {
    "us-central1-a" = "e2-micro"
    "us-central1-b" = "e2-small"
  }
  subnet_id = module.network.subnets_ids[0]
}

output "instance_ips" {
  value = module.instance.instance_ips
}