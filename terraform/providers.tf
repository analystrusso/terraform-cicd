terraform {
  required_version = ">=0.12"
  backend "s3" {
    bucket = "myapp-terraform-cicd-bucket"
    key = "myapp/state.tfstate"
    region = "us-east-1"
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