# LOCALS are named intermediate values computed once and reused - like
# read-only variables internal to the module. They keep repeated
# expressions (tag merging, AZ selection) out of the resource blocks.
locals {

  common_tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags
  )

  # Boolean flag driving the conditional IGW / public routing in routing.tf.
  has_public_subnets = length(var.public_subnets) > 0

  # slice(list, start, end) takes the first N AZ names from the data source
  # lookup - e.g. availability_zone_count=2 in us-east-1 yields
  # ["us-east-1a", "us-east-1b"]. Subnets index into this list.
  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    var.availability_zone_count
  )

  # keys() returns a map's keys as a sorted list - used with index() in
  # subnets.tf to give each subnet a stable position -> AZ mapping.
  public_subnet_keys = keys(var.public_subnets)

  private_subnet_keys = keys(var.private_subnets)

}
