variable "cloud_provider" {
  type = string
}

variable "publickey" {
  type = object({
    name  = string
    key   = string
  })
}

variable "rules" {
  type = map(object({
    description       = string
    direction         = string
    protocol          = string
    port              = optional(number)
    remote_prefix     = string
    tags               = optional(list(string))
  }))
}

variable "whitelist" {
  type = list(string)
}

variable "network" {
  type = object({
    name                = string
    subnet_name         = string
    subnet              = string
    nameservers         = optional(list(string))
    external_network_id = optional(string)
  })
}

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