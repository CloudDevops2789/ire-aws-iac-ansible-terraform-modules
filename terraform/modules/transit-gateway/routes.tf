resource "aws_ec2_transit_gateway_route" "this" {

  for_each = var.static_routes

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table].id

  destination_cidr_block = each.value.destination_cidr_block

  blackhole = each.value.blackhole

  transit_gateway_attachment_id = (
    each.value.blackhole
    ? null
    : aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment].id
  )
}
