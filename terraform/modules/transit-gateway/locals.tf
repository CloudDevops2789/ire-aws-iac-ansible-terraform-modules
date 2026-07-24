# Central tag map: caller-supplied tags plus a Name. Computed once here so
# every resource in the module tags identically.
locals {

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

}
