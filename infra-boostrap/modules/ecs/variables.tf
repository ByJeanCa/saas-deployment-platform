variable "project_name" {
  description = "Name of the project used for naming and tagging resources."
  type        = string
}

variable "region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
}

variable "db_master_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret that stores the database credentials."
  type        = string
}

variable "common_tags" {
  description = "Map of common tags to apply to all project resources."
  type        = map(string)
}

variable "api_image" {
  description = "Container image URI for the API service."
  type        = string
}

variable "environment" {
  description = "Environment name (dev/stage/prod)."
  type        = string
}

variable "db_host" {
  description = "Database endpoint or hostname used by the API service."
  type        = string
}

variable "db_name" {
  description = "Name of the database used by the API service."
  type        = string
}

variable "redis_url" {
  description = "Connection URL for the Redis instance used by the application."
  type        = string
}

variable "frontend_image" {
  description = "Container image URI for the frontend service."
  type        = string
}

variable "worker_image" {
  description = "Container image URI for the background worker service."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where ECS tasks will run."
  type        = list(string)
}

variable "api_target_group_arn" {
  description = "ARN of the Application Load Balancer target group for the API service."
  type        = string
}

variable "frontend_target_group_arn" {
  description = "ARN of the Application Load Balancer target group for the frontend service."
  type        = string
}

variable "ecs_service_sg_id" {
  description = "ID of the security group associated with the ECS services."
  type        = string
}

variable "image_tag" {
  description = "Tag of the container images to deploy for the services."
  type        = string
}