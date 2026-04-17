output "domain_validation_options" {
  description = "Domain validation options for the ACM certificate, used by other services or modules to create the required DNS validation records."
  value       = aws_acm_certificate.cert.domain_validation_options
}

output "certificate_arn" {
  description = "ARN of the ACM certificate that can be consumed by other services and modules requiring HTTPS or TLS termination."
  value       = aws_acm_certificate.cert.arn
}