provider "aws" {

  region = "us-east-1"

  default_tags {

    tags = {

      Project     = "AWS-IRE"
      Environment = "Sandbox"
      ManagedBy   = "Terraform"
      Owner       = "CloudEngineering"

    }

  }

}
