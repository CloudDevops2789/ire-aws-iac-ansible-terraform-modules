output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.this.cidr_block
}

############################################
# Public Subnets
############################################

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = values(aws_subnet.public)[*].id
}

output "public_subnet_map" {
  description = "Public subnet map"

  value = {
    for k, subnet in aws_subnet.public :
    k => subnet.id
  }
}

############################################
# Private Subnets
############################################

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = values(aws_subnet.private)[*].id
}

output "private_subnet_map" {
  description = "Private subnet map"

  value = {
    for k, subnet in aws_subnet.private :
    k => subnet.id
  }
}

############################################
# Route Tables
############################################

output "public_route_table_id" {
  value = try(aws_route_table.public[0].id, null)
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

############################################
# Internet Gateway
############################################

output "internet_gateway_id" {
  value = try(aws_internet_gateway.this[0].id, null)
}
