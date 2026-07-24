# The Transit Gateway is a regional cloud router: VPCs attach to it and it
# routes between them, replacing an unscalable mesh of VPC peerings.
# Note the enable/disable values are STRINGS, not booleans - a quirk of the
# EC2 API this provider mirrors.
# default_route_table_association/propagation = enable means every
# attachment is auto-wired into one shared TGW route table -> any-to-any
# reachability between attached VPCs. Fine for a sandbox; a hardened IRE
# later replaces this with per-VPC TGW route tables so traffic can be
# forced through inspection.
resource "aws_ec2_transit_gateway" "this" {

  description = var.name

  amazon_side_asn                 = var.amazon_side_asn
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation

  tags = local.tags
}
