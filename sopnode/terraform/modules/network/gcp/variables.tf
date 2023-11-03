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
    subnet = string
    nameservers = optional(list(string))
  })
}