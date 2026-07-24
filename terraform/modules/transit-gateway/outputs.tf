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

output "vpc_attachment_ids" {
  description = "Map of attachment key => TGW VPC attachment ID"

  value = {
    for k, a in aws_ec2_transit_gateway_vpc_attachment.this :
    k => a.id
  }
}

output "route_table_ids" {
  description = "Map of route table key => TGW route table ID"

  value = {
    for k, rt in aws_ec2_transit_gateway_route_table.this :
    k => rt.id
  }
}
