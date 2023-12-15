# Author: Surya Kumar Kunderu
# Project: Slices RI
# Version: 1.0
# License: None - Opensource
/* 
Terraform configurations can include variables to make your configuration more dynamic 
and flexible. 
*/

variable "instance_control" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Control"
}

variable "instance_master" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Master"
}

variable "instance_worker1" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Worker1"
}

variable "instance_worker2" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Worker2"
}

variable "instance_openvpn" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "OpenVPN"
}

variable "instance_switch" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "Switch"
}
