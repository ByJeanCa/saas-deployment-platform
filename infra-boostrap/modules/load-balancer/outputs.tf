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
  description = "Canonical hosted zone ID of the Application Load Balancer, used when creating Route 53 alias records."
  value       = aws_lb.application.zone_id
}

output "alb_name" {
  description = "Name of the Application Load Balancer created to expose the application, used by the pipeline to verify that it is active."
  value       = aws_lb.application.name
}