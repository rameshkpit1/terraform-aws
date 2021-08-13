variable "aws_access_key" {}
variable "aws_secret_key"{}
variable "aws_region"{
    description = "EC2 region"
    default = "us-east-2"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default="10.1.0.0/16"
  
}

variable "subnet_cidr" {
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
}

variable "subnet_azs" {
  default = ["us-east-2a", "us-east-2b", "us-east-2c","us-east-2c"]
}

variable "public_subnet_cidr" {
  default = ["10.1.5.0/24", "10.1.6.0/24", "10.1.7.0/24", "10.1.8.0/24"]
}

variable "public_subnet_azs" {
  default = ["us-east-2a", "us-east-2b", "us-east-2c", "us-east-2c"]
}


variable "amis" {
    description = "AMIs by region"
    default = {
        us-east-2 = "ami-0443305dabd4be2bc" # ubuntu 14.04 LTS
    }
}

variable "aws_key_name" {}

