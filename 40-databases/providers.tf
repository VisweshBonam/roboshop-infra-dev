terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.98.0"
    }
  }

  backend "s3" {
    bucket = "terraform-roboshop-infra-dev"
    key = "roboshop-infra-dev-backend-database"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}

provider "aws" {
  
}