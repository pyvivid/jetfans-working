terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.74.2"
    }
  }
}

# Configure the AWS Provider
# Holding access and secret keys explicitly is not the right method.
# Go to variables method later after you are successful tieht this approach
provider "aws" {
  access_key = "Enter Access Key Here"
  secret_key = "Enter Secret Key here"
  region = "us-west-2"
}
