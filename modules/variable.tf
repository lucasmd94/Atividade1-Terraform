variable "instance_type" {
  type = string
}

variable "ami" {

  default = {
    "us-east-1" = "ami-00c39f71452c08778"
    "us-east-2" = "ami-02f97949d306b597a"
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}