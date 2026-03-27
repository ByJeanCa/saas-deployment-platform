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