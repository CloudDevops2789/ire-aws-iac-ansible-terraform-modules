resource "aws_subnet" "public" {

  for_each = var.public_subnets

  vpc_id = aws_vpc.this.id

  cidr_block = each.value

  availability_zone = local.availability_zones[
    index(local.public_subnet_keys, each.key)
  ]

  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-${each.key}"
      Tier = "Public"
    }
  )

}

resource "aws_subnet" "private" {

  for_each = var.private_subnets

  vpc_id = aws_vpc.this.id

  cidr_block = each.value

  availability_zone = local.availability_zones[
    index(local.private_subnet_keys, each.key)
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-${each.key}"
      Tier = "Private"
    }
  )

}