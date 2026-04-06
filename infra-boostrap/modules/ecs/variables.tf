variable "project_name" {
  description = "Name of the project used for naming and tagging resources."
  type        = string
}

variable "region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
}

variable "db_master_secret_arn" {
  description = "value"
  type = string
}

variable "common_tags" {
  description = "Map of common tags to apply to all project resources."
  type        = map(string)
}

variable "api_image" {
  type = string
}

variable "environment" {
  type        = string
  description = "Environment name (dev/stage/prod)"
}


variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "redis_url" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "worker_image" {
  type = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "api_target_group_arn" {
  type = string
}

variable "frontend_target_group_arn" {
  type = string
}

variable "ecs_service_sg_id" {
  description = "ID of the security group associated with the ECS service."
  type        = string
}

variable "image_tag" {
  type = string
}