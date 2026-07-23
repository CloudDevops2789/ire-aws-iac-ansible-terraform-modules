resource "aws_ec2_transit_gateway_vpc_attachment" "this" {

  for_each = var.vpc_attachments

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  vpc_id = each.value.vpc_id

  subnet_ids = each.value.subnet_ids

  dns_support             = each.value.dns_support
  ipv6_support            = each.value.ipv6_support
  appliance_mode_support  = each.value.appliance_mode_support

  tags = merge(
    local.tags,
    each.value.tags,
    {
      Name = each.key
    }
  )
}