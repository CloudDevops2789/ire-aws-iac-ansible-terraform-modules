# Return values for callers - the TGW ID is what VPC route tables need as
# a route target when inter-VPC routes are added at the environment level.
output "id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.this.id
}

output "arn" {
  description = "Transit Gateway ARN"
  value       = aws_ec2_transit_gateway.this.arn
}

# IDs of the automatically-created default TGW route table. Exposed so a
# future environment can inspect it or add static/blackhole routes to it.
output "association_default_route_table_id" {
  description = "Default association route table"
  value       = aws_ec2_transit_gateway.this.association_default_route_table_id
}

output "propagation_default_route_table_id" {
  description = "Default propagation route table"
  value       = aws_ec2_transit_gateway.this.propagation_default_route_table_id
}