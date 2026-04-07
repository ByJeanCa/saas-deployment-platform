variable "project_name" {
  description = "Name of the project used for naming and tagging resources."
  type        = string
}

variable "region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the load balancer and target groups will be created."
  type = string
}

variable "common_tags" {
  description = "Map of common tags to apply to all project resources."
  type        = map(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate used by the HTTPS listener."
  type = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where the Application Load Balancer will be deployed."
  type = list(string)
}