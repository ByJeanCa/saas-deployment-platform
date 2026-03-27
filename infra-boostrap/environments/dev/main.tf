terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>6.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region = var.region
}

module "network" {
  source = "../../modules/network"

  vpc_cidr = var.vpc_cidr
  region = var.region
  common_tags = var.common_tags
  project_name = var.project_name
  az_count = var.az_count
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}