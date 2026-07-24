resource "aws_ec2_transit_gateway_route_table" "this" {

  for_each = var.route_tables

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(
    local.tags,
    {
      Name = each.value
    }
  )
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {

  for_each = {
    for k, v in var.vpc_attachments : k => v
    if v.route_table != null
  }

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {

  for_each = var.propagations

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table].id
}
