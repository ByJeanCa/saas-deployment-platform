output "repository_urls" {
  description = "Map of ECR repository URLs keyed by image name."
  value = {
    for key, repo in aws_ecr_repository.images : key => repo.repository_url
  }
}

output "ecr_repo_name" {
  description = "Name of the Amazon ECR repository used to store the application container images."
  value       = aws_ecr_repository.images.name
}