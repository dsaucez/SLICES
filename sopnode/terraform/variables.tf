variable "cloud_provider" {
  type = string
}

variable "publickey" {
  type = string 
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuamOAVQDpVDyIb5yhP8kvEFGuTv32YBV5sZJ8+5HkPte0qq0/kmA7vp/9L7Mgbq4vCA4jBkbAflJeTw25F+0yl8P/Jaz0wnLkoYxtYXbBwv9sdGjbcvp1To1uyXhj+JCkklGKAqJ+V+Ap98NQEwm61AbuztGNgtpWUCaeqc2xYMxSYqTWX08P0F6KRQdQwLH3myiueflQKDXOLH31KPqmYVIEch5R+3SEmqLxUFDPWKmJgZ4eQESTkM1TfkN8jnoyPqBSs/01k+qMXd/DBsAD/rINJPE6ht8vl1k4SkrIFl4Apc5hO7xAJp+d7hvScrVGa3gZdcpPpaReVs2N1AAqw1RHEZqADm3t3bUwjvcIu7vz9WeNdSE5UjSM9oydr3w1iVR73iPpybWdzRvxtywQ8qzwJjeb3DvbcDH/jtoRr0N30Dd7HO3sFK8RD2ZMTxOnU72oyYdk3BrlvsV/6AsZvtYM1eSc4x0iDjGSaJmfc+6OeNi+KYZb7MOBHM/FoHE= dsaucez@srv-diana"
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
    subnet = string
    nameservers = optional(list(string))
  })
}