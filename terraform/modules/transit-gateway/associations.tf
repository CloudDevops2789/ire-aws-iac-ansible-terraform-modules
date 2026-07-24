# Associate each VPC attachment with its Transit Gateway route table.
# The attachment specifies the routing domain using the `route_table`
# attribute defined in `var.vpc_attachments`.
resource "aws_ec2_transit_gateway_route_table_association" "this" {

  for_each = var.vpc_attachments

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table].id
}