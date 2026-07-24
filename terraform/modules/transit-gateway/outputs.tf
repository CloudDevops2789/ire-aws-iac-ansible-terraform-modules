output "id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.this.id
}

output "arn" {
  description = "Transit Gateway ARN"
  value       = aws_ec2_transit_gateway.this.arn
}

output "association_default_route_table_id" {
  description = "Default association route table"
  value       = aws_ec2_transit_gateway.this.association_default_route_table_id
}

output "propagation_default_route_table_id" {
  description = "Default propagation route table"
  value       = aws_ec2_transit_gateway.this.propagation_default_route_table_id
}