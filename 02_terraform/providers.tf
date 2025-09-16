terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  backend "s3" {
    bucket = "safescale-aws-md25rd"
    key = "terraform/terraform.tfstate"
    region = "eu-central-1"
    use_lockfile = true
    dynamodb_table = "safescale-aws-LockID"
  }
}

provider "aws" {
  region = var.aws_region
}