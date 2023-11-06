variable "cloud_provider" {
  type = string
}

variable "rules" {
  type = map(object({
    description       = string
    direction         = string
    protocol          = string
    port              = number
    remote_prefix     = string
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