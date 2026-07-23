locals {

  common_tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags
  )

  has_public_subnets = length(var.public_subnets) > 0

  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    var.availability_zone_count
  )

  public_subnet_keys = keys(var.public_subnets)

  private_subnet_keys = keys(var.private_subnets)

}