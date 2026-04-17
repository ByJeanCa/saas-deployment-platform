
variable "common_tags" {
  description = "Map of common tags to apply to all project resources."
  type        = map(string)
}

variable "vpc_id" {
  description = "ID of the VPC where the load balancer and target groups will be created."
  type        = string
}

variable "api_sg_id" {
  description = "ID of the security group associated with the API service that is allowed to access the database."
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group where the database instance will be deployed."
  type        = string
}