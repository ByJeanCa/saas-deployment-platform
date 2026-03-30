variable "vpc_cidr" {
  description = "CIDR block assigned to the VPC."
  type        = string
}

variable "region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
}

variable "common_tags" {
  description = "Map of common tags to apply to all project resources."
  type        = map(string)
}

variable "project_name" {
  description = "Name of the project used for naming and tagging resources."
  type        = string
}

variable "az_count" {
  description = "Number of Availability Zones to use."
  type        = number
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets."
  type        = list(string)
}

variable "domain" {
  description = "Domain name for the application."
  type = string
}


variable "image_names" {
  description = "List of image names to be used by the deployment."
  type        = list(string)
}

variable "db_subnet_cidrs" {
  type = list(string)
}