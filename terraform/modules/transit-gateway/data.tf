# Identity/context lookups (region, account ID, partition). Not consumed
# by any resource yet - they're here ready for building ARNs or
# cross-account RAM sharing later. Data sources cost nothing to keep.
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}
