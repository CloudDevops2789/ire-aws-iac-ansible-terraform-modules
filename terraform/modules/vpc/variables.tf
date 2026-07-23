variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zone_count" {
  description = "Number of Availability Zones to use"

  type    = number
  default = 2

  validation {
    condition     = var.availability_zone_count >= 2
    error_message = "At least two Availability Zones are recommended."
  }
}

variable "public_subnets" {
  description = "Map of public subnet CIDRs"

  type = map(string)

  default = {}
}

variable "private_subnets" {
  description = "Map of private subnet CIDRs"

  type = map(string)

  validation {
    condition     = length(var.private_subnets) > 0
    error_message = "At least one private subnet is required."
  }
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}