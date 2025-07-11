terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.98.0"
    }
  }

  backend "s3" {
    bucket = "practice-bucket-infra"
    key = "practice-catalogue"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}

provider "aws" {
  
}