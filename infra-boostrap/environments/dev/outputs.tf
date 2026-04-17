output "ecr_repo_name" {
  description = "Name of the Amazon ECR repository used to store the application container images."
  value       = module.ecr_repo.ecr_repo_name
}

output "ecs_cluster_name" {
  description = "Name of the Amazon ECS cluster where the application services are deployed."
  value       = module.ecs.ecs_cluster_name
}

output "ecs_api_service_name" {
  description = "Name of the Amazon ECS service that runs the API workload, used by the pipeline to validate service status and stability."
  value       = module.ecs.ecs_api_service_name
}

output "ecs_frontend_service_name" {
  description = "Name of the Amazon ECS service that runs the frontend workload, used by the pipeline to validate service status and stability."
  value       = module.ecs.ecs_frontend_service_name
}

output "ecs_worker_service_name" {
  description = "Name of the Amazon ECS service that runs the worker workload, used by the pipeline to validate service status and stability."
  value       = module.ecs.ecs_worker_service_name
}

output "certificate_arn" {
  description = "ARN of the AWS Certificate Manager certificate associated with the application domain, used by the pipeline to verify that the certificate status is ISSUED."
  value       = module.tls_certificate.certificate_arn
}

output "db_instance_id" {
  description = "Identifier of the Amazon RDS instance provisioned for the application, used by the pipeline to verify that the database status is available."
  value       = module.database.db_instance_id
}

output "alb_name" {
  description = "Name of the Application Load Balancer created to expose the application, used by the pipeline to verify that it is active."
  value       = module.alb.alb_name
}

output "frontend_target_group_arn" {
  description = "ARN of the frontend target group associated with the Application Load Balancer."
  value       = module.alb.frontend_target_group_arn
}

output "api_target_group_arn" {
  description = "ARN of the API target group associated with the Application Load Balancer."
  value       = module.alb.api_target_group_arn
}

output "redis_arn" {
  description = "ARN of the Amazon ElastiCache Serverless Redis cache provisioned for the application."
  value       = module.redis.redis_arn
}