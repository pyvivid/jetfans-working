terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.74.2"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
  aws_access_key_id = AKIA35XN7SLM5D45URFP
aws_secret_access_key = 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
}