output "redis_endpoint" {
  description = "Endpoint of the Redis serverless cache."
  value       = aws_elasticache_serverless_cache.redis.endpoint
}

output "redis_arn" {
  value       = aws_elasticache_serverless_cache.redis.arn
  description = "ARN of the Amazon ElastiCache Serverless Redis cache provisioned for the application."

}