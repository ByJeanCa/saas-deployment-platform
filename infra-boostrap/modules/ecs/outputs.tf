output "ecs_cluster_name" {
  description = "Name of the Amazon ECS cluster where the application services are deployed."
  value       = aws_ecs_cluster.main.name
}

output "ecs_api_service_name" {
  description = "Name of the Amazon ECS service that runs the API workload, used by the pipeline to validate service status and stability."
  value       = aws_ecs_service.api.name
}

output "ecs_frontend_service_name" {
  description = "Name of the Amazon ECS service that runs the frontend workload, used by the pipeline to validate service status and stability."
  value       = aws_ecs_service.frontend.name
}

output "ecs_worker_service_name" {
  description = "Name of the Amazon ECS service that runs the frontend workload, used by the pipeline to validate service status and stability."
  value       = aws_ecs_service.worker.name
}