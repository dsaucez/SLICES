variable "publickey" {
  type = object({
    name  = string
    key   = string
  })
}

variable "cloud_provider" {
  type = string
}