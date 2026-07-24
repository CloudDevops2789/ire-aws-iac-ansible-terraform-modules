terraform {

  backend "s3" {

    bucket = "yoganand-terraform-state-781436988948"

    key = "sandbox/networking/terraform.tfstate"

    region = "us-east-1"

    use_lockfile = true

    encrypt = true

  }

}
