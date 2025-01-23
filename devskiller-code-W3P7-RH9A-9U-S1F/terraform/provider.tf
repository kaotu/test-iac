# Terraform Provider Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider, If we have AWS profile, we can use the profile name as well.
provider "aws" {
  region  = "eu-central-1"
  # profile = "default"
}