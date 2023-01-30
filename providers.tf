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
  access_key = "AKIA35XN7SLM5D45URFP"
  secret_key = "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"
  region = "us-west-2"
}