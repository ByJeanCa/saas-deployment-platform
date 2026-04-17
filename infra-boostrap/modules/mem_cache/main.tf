resource "aws_security_group" "redis" {
  name        = "redis-sg"
  description = "Allow ecs service inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_ecs_service" {
  type                     = "ingress"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = var.ecs_service_sg_id
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
}


resource "aws_elasticache_serverless_cache" "redis" {
  engine = "redis"
  name   = format("redis-%s", var.project_name)
  cache_usage_limits {
    data_storage {
      maximum = 10
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  major_engine_version     = "7"
  snapshot_retention_limit = 1
  security_group_ids       = [aws_security_group.redis.id]
  subnet_ids               = var.private_subnet_ids
}