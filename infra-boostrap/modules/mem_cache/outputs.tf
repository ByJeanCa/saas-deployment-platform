output "redis_endpoint" {
  description = "Endpoint of the Redis serverless cache."
  value       = aws_elasticache_serverless_cache.redis.endpoint
}