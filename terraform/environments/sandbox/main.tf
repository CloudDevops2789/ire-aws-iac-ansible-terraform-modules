# This file is the ROOT MODULE of the sandbox environment. Terraform starts
# evaluating here. It contains no resources of its own - instead it composes
# reusable child modules (vpc, transit-gateway) into the 3-VPC IRE topology:
# Landing Zone -> Core Recovery -> Protected Data, joined by a Transit Gateway.
#
############################################
# Landing Zone VPC
############################################

# A "module" block instantiates a child module. `source` points at the local
# module directory; everything else is an INPUT passed to that module's
# variables.tf. Terraform copies of the same module (below) are fully
# independent - each gets its own state entries.
# This VPC is the entry point where administrators land before reaching
# recovery workloads. It is the only VPC with public subnets (sandbox-only).
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

# Hosts the recovery tooling/compute tier. Note: no `public_subnets` input is
# given, so the module falls back to its default of {} and creates no public
# subnets, no Internet Gateway, and no public route table for this VPC.
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

# Holds the immutable backup data (most sensitive tier). Private subnets only,
# same pattern as core_recovery - isolation is the point of this VPC.
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

# The Transit Gateway is the central router connecting all three VPCs.
# The references like `module.landing_zone.vpc_id` read OUTPUTS of the vpc
# module instances above. These references are also how Terraform builds its
# dependency graph: it knows the VPCs must exist before the TGW attachments.
module "transit_gateway" {

  source = "../../modules/transit-gateway"

  name = "ire-transit-gateway"

  # A map(object) input: one entry per VPC to attach. Inside the module this map
  # is iterated with for_each, so each key (landing_zone, core_recovery, ...)
  # becomes a stable resource address like
  # aws_ec2_transit_gateway_vpc_attachment.this["landing_zone"].
  # Attachments are placed in the PRIVATE subnets - the TGW creates a network
  # interface in each subnet you list.
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

  # Merged onto the TGW resources by the module (see its locals.tf). These are
  # in addition to the provider-level default_tags defined in provider.tf.
  tags = {
    Name        = "ire-transit-gateway"
    Project     = "AWS-IRE"
    Environment = "Sandbox"
    ManagedBy   = "Terraform"
    Owner       = "CloudEngineering"
  }

}