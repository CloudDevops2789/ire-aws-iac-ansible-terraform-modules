############################################
# Landing Zone VPC
############################################

module "landing_zone" {

  source = "../../modules/vpc"

  vpc_name                = "landing-zone"
  cidr_block              = "10.100.0.0/16"
  availability_zone_count = 2

  public_subnets = {
    public-a = "10.100.1.0/24"
    public-b = "10.100.2.0/24"
  }

  private_subnets = {
    private-a = "10.100.11.0/24"
    private-b = "10.100.12.0/24"
  }

}

############################################
# Core Recovery VPC
############################################

module "core_recovery" {

  source = "../../modules/vpc"

  vpc_name                = "core-recovery"
  cidr_block              = "10.101.0.0/16"
  availability_zone_count = 2

  private_subnets = {
    private-a = "10.101.11.0/24"
    private-b = "10.101.12.0/24"
  }

}

############################################
# Protected Data VPC
############################################

module "protected_data" {

  source = "../../modules/vpc"

  vpc_name                = "protected-data"
  cidr_block              = "10.102.0.0/16"
  availability_zone_count = 2

  private_subnets = {
    private-a = "10.102.11.0/24"
    private-b = "10.102.12.0/24"
  }

}

############################################
# Transit Gateway — segmented routing
#
# Isolation model (until the inspection VPC
# is added):
#   - landing zone reaches core + protected
#   - core and protected reach landing only
#   - core <-> protected is blackholed
############################################

module "transit_gateway" {

  source = "../../modules/transit-gateway"

  name = "ire-transit-gateway"

  route_tables = ["landing", "core", "protected"]

  vpc_attachments = {

    landing_zone = {
      vpc_id      = module.landing_zone.vpc_id
      subnet_ids  = module.landing_zone.private_subnet_ids
      route_table = "landing"
    }

    core_recovery = {
      vpc_id      = module.core_recovery.vpc_id
      subnet_ids  = module.core_recovery.private_subnet_ids
      route_table = "core"
    }

    protected_data = {
      vpc_id      = module.protected_data.vpc_id
      subnet_ids  = module.protected_data.private_subnet_ids
      route_table = "protected"
    }

  }

  propagations = {
    landing_to_core      = { route_table = "core", attachment = "landing_zone" }
    landing_to_protected = { route_table = "protected", attachment = "landing_zone" }
    core_to_landing      = { route_table = "landing", attachment = "core_recovery" }
    protected_to_landing = { route_table = "landing", attachment = "protected_data" }
  }

  static_routes = {
    core_deny_protected = {
      route_table            = "core"
      destination_cidr_block = "10.102.0.0/16"
      blackhole              = true
    }
    protected_deny_core = {
      route_table            = "protected"
      destination_cidr_block = "10.101.0.0/16"
      blackhole              = true
    }
  }

  tags = {
    Name        = "ire-transit-gateway"
    Project     = "AWS-IRE"
    Environment = "Sandbox"
    ManagedBy   = "Terraform"
    Owner       = "CloudEngineering"
  }

}

############################################
# VPC routes toward the Transit Gateway
############################################

resource "aws_route" "landing_to_core" {
  route_table_id         = module.landing_zone.private_route_table_id
  destination_cidr_block = module.core_recovery.vpc_cidr
  transit_gateway_id     = module.transit_gateway.id
}

resource "aws_route" "landing_to_protected" {
  route_table_id         = module.landing_zone.private_route_table_id
  destination_cidr_block = module.protected_data.vpc_cidr
  transit_gateway_id     = module.transit_gateway.id
}

resource "aws_route" "core_to_landing" {
  route_table_id         = module.core_recovery.private_route_table_id
  destination_cidr_block = module.landing_zone.vpc_cidr
  transit_gateway_id     = module.transit_gateway.id
}

resource "aws_route" "protected_to_landing" {
  route_table_id         = module.protected_data.private_route_table_id
  destination_cidr_block = module.landing_zone.vpc_cidr
  transit_gateway_id     = module.transit_gateway.id
}
