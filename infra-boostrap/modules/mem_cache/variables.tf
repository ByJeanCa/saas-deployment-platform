variable "project_name" {
  description = "Name of the project used for naming and tagging resources."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC where the load balancer and target groups will be created."
  type        = string
}

variable "ecs_service_sg_id" {
  description = "ID of the security group associated with the ECS service."
  type        = string
}