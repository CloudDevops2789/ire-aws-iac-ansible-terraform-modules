output "vpc_ids" {
  description = "VPC IDs by name"

  value = {
    landing_zone   = module.landing_zone.vpc_id
    core_recovery  = module.core_recovery.vpc_id
    protected_data = module.protected_data.vpc_id
  }
}

output "transit_gateway_id" {
  value = module.transit_gateway.id
}

output "transit_gateway_route_tables" {
  value = module.transit_gateway.route_table_ids
}

output "transit_gateway_attachments" {
  value = module.transit_gateway.vpc_attachment_ids
}
