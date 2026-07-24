# Propagate VPC attachment routes into the configured Transit Gateway
# route tables. Each propagation creates one learned route source.
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {

  for_each = {
    for propagation in flatten([
      for attachment_key, attachment in var.vpc_attachments : [
        for route_table_key in attachment.propagate_to : {
          key             = "${attachment_key}-${route_table_key}"
          attachment_key  = attachment_key
          route_table_key = route_table_key
        }
      ]
    ]) : propagation.key => propagation
  }

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.this[each.value.attachment_key].id

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.route_table_key].id
}