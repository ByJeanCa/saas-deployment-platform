output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.application.dns_name
}

output "alb_security_group_id" {
  description = "Security group ID of the Application Load Balancer."
  value       = aws_security_group.http_https.id
}

output "frontend_target_group_arn" {
  description = "ARN of the frontend target group."
  value       = aws_lb_target_group.frontend.arn
}

output "api_target_group_arn" {
  description = "ARN of the API target group."
  value       = aws_lb_target_group.api.arn
}

output "alb_zone_id" {
  value = aws_lb.application.zone_id
}