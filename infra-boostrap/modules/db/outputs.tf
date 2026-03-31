output "db_master_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret that stores the master credentials for the database instance."
  value       = aws_db_instance.default.master_user_secret[0].secret_arn
}

output "db_host" {
  description = "Endpoint hostname of the database instance used by applications and clients to connect."
  value       = aws_db_instance.default.endpoint
}

output "db_name" {
  description = "Name of the primary database created in the database instance."
  value       = aws_db_instance.default.db_name
}