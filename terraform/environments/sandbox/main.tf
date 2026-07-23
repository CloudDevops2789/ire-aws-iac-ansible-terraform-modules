#
# Modules will be added here.
#
module "landing_zone" {

  source = "../../modules/vpc"

  vpc_name = "landing-zone"

  cidr_block = "10.100.0.0/16"

}