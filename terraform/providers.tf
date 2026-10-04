terraform {
  required_version = ">=0.12"
  backend "s3" {
    bucket = "myapp-tf-s3-bucket"
    key = "myapp/state.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}