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
  description = "Default route table association (disable to enforce segmented routing)"
  type        = string
  default     = "disable"
}

variable "default_route_table_propagation" {
  description = "Default route table propagation (disable to enforce segmented routing)"
  type        = string
  default     = "disable"
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

    dns_support = optional(string, "enable")
    ipv6_support = optional(string, "disable")
    appliance_mode_support = optional(string, "disable")

    # TGW route table (key of var.route_tables) this attachment is associated with
    route_table = optional(string)

    tags = optional(map(string), {})
  }))

  default = {}
}

variable "route_tables" {
  description = "TGW route tables to create, keyed by name"
  type        = set(string)
  default     = []
}

variable "propagations" {
  description = "Attachment CIDR propagations into TGW route tables"

  type = map(object({
    route_table = string   # key of var.route_tables
    attachment  = string   # key of var.vpc_attachments
  }))

  default = {}
}

variable "static_routes" {
  description = "Static TGW routes (use blackhole = true to explicitly deny a destination)"

  type = map(object({
    route_table            = string           # key of var.route_tables
    destination_cidr_block = string
    attachment             = optional(string) # key of var.vpc_attachments
    blackhole              = optional(bool, false)
  }))

  default = {}
}
