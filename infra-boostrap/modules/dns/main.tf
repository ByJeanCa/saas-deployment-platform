resource "aws_route53_zone" "web_domain" {
  name = var.domain

  tags = var.common_tags
}

