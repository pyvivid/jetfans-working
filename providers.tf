terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
  shared_credentials_files = ["/home/ubuntu/.aws/credentials"]
}