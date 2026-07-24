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
# Transit Gateway
############################################

module "transit_gateway" {

  source = "../../modules/transit-gateway"

  name = "ire-transit-gateway"

  vpc_attachments = {

    landing_zone = {
      vpc_id     = module.landing_zone.vpc_id
      subnet_ids = module.landing_zone.private_subnet_ids
    }

    core_recovery = {
      vpc_id     = module.core_recovery.vpc_id
      subnet_ids = module.core_recovery.private_subnet_ids
    }

    protected_data = {
      vpc_id     = module.protected_data.vpc_id
      subnet_ids = module.protected_data.private_subnet_ids
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