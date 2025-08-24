variable "instances" {
  description = "A map of instance names to machine types."
  type        = map(string)
  
}

variable "subnet_id" {
  description = "The ID of the subnetwork to attach instances to."
  type        = string 
}