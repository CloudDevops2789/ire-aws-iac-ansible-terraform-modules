# Modules declare their own compatibility floor so they fail fast when
# used with an older CLI/provider than they were written for.
terraform {

  required_version = ">= 1.10.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

  }

}
