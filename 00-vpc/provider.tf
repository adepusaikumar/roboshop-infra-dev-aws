terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
        version = "6.33.0" # Terraform AWS provider version
    }
  }

backend "s3" {
    bucket = "remote-state-daws88s-roboshop-sai-dev"
    key = "00-vpc/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    }

}

provider "aws" {
    region = "us-east-1"
}
