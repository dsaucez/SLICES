variable "rules" {
  type = map(object({
    description   = string
    direction     = string
    protocol      = string
    port          = number
    remote_prefix = string
  }))
}

variable "whitelist" {
  type = list(string)
}