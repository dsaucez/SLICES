variable "instances" {
  type = map(object({
    instance_count  = number
    image           = string
    disk_size       = optional(number)
    flavor          = string
    zone            = optional(string)
    publickey_name  = string
    network_name    = string
    security_groups = optional(list(string))
    tags            = optional(list(string))
  }))
}

variable "subnetwork" {
  type              = string
}