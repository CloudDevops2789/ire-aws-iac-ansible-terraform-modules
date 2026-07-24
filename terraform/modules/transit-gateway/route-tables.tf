# Create one Transit Gateway route table for each routing domain.
# Using `for_each` keeps the module reusable instead of hardcoding
# route tables for a specific environment.
resource "aws_ec2_transit_gateway_route_table" "this" {

  for_each = var.route_tables

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  # Merge module tags with any route-table-specific tags.
  tags = merge(
    local.tags,
    each.value.tags,
    {
      Name = each.value.name
    }
  )
}