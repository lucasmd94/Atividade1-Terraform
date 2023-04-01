terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "us-east-1" {
  source = "./modules"
  instance_type = "t2.micro"
  providers = {
    aws = "aws"
  }
}

module "us-east-2" {
  source = "./modules"
  instance_type = "t2.micro"
  providers = {
    aws = "aws.us-east-2"
  }
}