# One attachment per entry of the var.vpc_attachments map (for_each).
# An attachment is the 'network cable' between a VPC and the TGW - AWS
# places an ENI in each listed subnet (one per AZ for HA).
# each.value is the object for this VPC, so fields like
# each.value.dns_support come either from the caller or from the
# optional() defaults declared in variables.tf.
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {

  for_each = var.vpc_attachments

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  vpc_id = each.value.vpc_id

  subnet_ids = each.value.subnet_ids

  dns_support            = each.value.dns_support
  ipv6_support           = each.value.ipv6_support
  appliance_mode_support = each.value.appliance_mode_support

  # Three-level tag merge, later wins: module-wide tags, then per-attachment
  # tags, then a Name derived from the map key.
  tags = merge(
    local.tags,
    each.value.tags,
    {
      Name = each.key
    }
  )
}
