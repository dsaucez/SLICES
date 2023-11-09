variable "instance_routes" {
  type = list(object({
    name               = string
    destination_prefix = string
    network_name       = string
    next_hop_instance  = string
  }))
}