# The VPC is the network boundary every other resource in this module lives
# inside. The name "this" is a common convention for a module's single main
# resource - callers never see it, they only see the module outputs.
# DNS support + hostnames are required for private endpoints and for EC2
# instances to resolve/receive internal DNS names.
resource "aws_vpc" "this" {

  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = local.common_tags
}
