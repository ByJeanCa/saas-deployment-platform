output "vpc_id" {
  description = "The ID of the main VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = [for k in sort(keys(aws_subnet.public)) : aws_subnet.public[k].id]
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = [for k in sort(keys(aws_subnet.private)) : aws_subnet.private[k].id]
}

output "db_group_name" {
  description = "The name of the DB subnet group."
  value       = aws_db_subnet_group.db.name
}