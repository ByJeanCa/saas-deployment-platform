output "repository_urls" {
  description = "Map of ECR repository URLs keyed by image name."
  value = {
    for key, repo in aws_ecr_repository.images : key => repo.repository_url
  }
}

