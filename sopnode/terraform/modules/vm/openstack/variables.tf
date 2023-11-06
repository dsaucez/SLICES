variable "instances" {
  type = map(object({
    instance_count  = number
    image           = string
    flavor          = string
    publickey_name  = string
    network_name    = string
    security_groups = list(string)
  }))
}