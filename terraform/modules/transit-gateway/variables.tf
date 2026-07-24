variable "name" {
  description = "Transit Gateway name"
  type        = string
}

variable "amazon_side_asn" {
  description = "Amazon side ASN"
  type        = number
  default     = 64512
}

variable "dns_support" {
  description = "Enable DNS support"
  type        = string
  default     = "enable"
}

variable "vpn_ecmp_support" {
  description = "Enable VPN ECMP"
  type        = string
  default     = "enable"
}

variable "auto_accept_shared_attachments" {
  description = "Auto accept shared attachments"
  type        = string
  default     = "disable"
}

variable "default_route_table_association" {
  description = "Default route table association"
  type        = string
  default     = "enable"
}

variable "default_route_table_propagation" {
  description = "Default route table propagation"
  type        = string
  default     = "enable"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "vpc_attachments" {
  description = "Transit Gateway VPC attachments"

  type = map(object({
    vpc_id     = string
    subnet_ids = list(string)

    dns_support            = optional(string, "enable")
    ipv6_support           = optional(string, "disable")
    appliance_mode_support = optional(string, "disable")

    tags = optional(map(string), {})
  }))

  default = {}
}