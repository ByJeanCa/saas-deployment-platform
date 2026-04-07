terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>6.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region = var.region
}

module "network" {
  source = "../../modules/network"

  vpc_cidr = var.vpc_cidr
  region = var.region
  common_tags = var.common_tags
  project_name = var.project_name
  az_count = var.az_count
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  db_subnet_cidrs = var.db_subnet_cidrs
}

module "tls_certificate" {
  source = "../../modules/certificate"

  domain = var.domain
  common_tags = var.common_tags
}

module "dns" {
  source = "../../modules/dns"

  domain = var.domain
  common_tags = var.common_tags
}


resource "aws_route53_record" "acm_validation" {
  for_each = {
    for o in module.tls_certificate.domain_validation_options : o.domain_name => {
      name  = o.resource_record_name
      type  = o.resource_record_type
      value = o.resource_record_value
    }
  }
  zone_id = module.dns.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "tls_certificate" {
  certificate_arn         = module.tls_certificate.certificate_arn
  validation_record_fqdns = [ for record in aws_route53_record.acm_validation : record.fqdn ]
}

module "alb" {
  source = "../../modules/load-balancer"

  project_name = var.project_name
  region = var.region
  vpc_id = module.network.vpc_id
  common_tags = var.common_tags
  certificate_arn = aws_acm_certificate_validation.tls_certificate.certificate_arn
  public_subnet_ids = module.network.public_subnet_ids
}

resource "aws_route53_record" "lb_a_record" {
  zone_id = module.dns.zone_id
  name    = var.domain
  type    = "A"
  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

module "ecr_repo" {
  source = "../../modules/ecr"

  image_names = var.image_names
  common_tags = var.common_tags
}

resource "aws_security_group" "svc" {
  name        = format("ecs-svc-%s", var.project_name)
  description = "ECS service SG"
  vpc_id      = module.network.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [module.alb.alb_security_group_id]
    description     = "ALB - ECS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}

module "database" {
  source = "../../modules/db"

  common_tags = var.common_tags
  vpc_id = module.network.vpc_id
  api_sg_id = aws_security_group.svc.id
  db_subnet_group_name = module.network.db_group_name
}

module "redis" {
  source = "../../modules/mem_cache"

  project_name = var.project_name
  private_subnet_ids = module.network.private_subnet_ids
  vpc_id = module.network.vpc_id
  ecs_service_sg_id = aws_security_group.svc.id
}


locals {
  redis_url = "redis://${module.redis.redis_endpoint[0].address}:${module.redis.redis_endpoint[0].port}"
  db_host_only = split(":", module.database.db_host)[0]
}

module "ecs" {
  source = "../../modules/ecs"

  project_name = var.project_name
  region = var.region
  db_master_secret_arn = module.database.db_master_secret_arn
  common_tags = var.common_tags
  api_image = module.ecr_repo.repository_urls["api"]
  frontend_image = module.ecr_repo.repository_urls["frontend"]
  worker_image = module.ecr_repo.repository_urls["worker"]
  environment = var.environment
  db_host = local.db_host_only
  db_name = module.database.db_name
  redis_url = local.redis_url 
  private_subnet_ids = module.network.private_subnet_ids
  api_target_group_arn = module.alb.api_target_group_arn
  frontend_target_group_arn = module.alb.frontend_target_group_arn
  ecs_service_sg_id = aws_security_group.svc.id
  image_tag = var.image_tag
}