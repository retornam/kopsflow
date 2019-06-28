output "public_subnet_ids" {
  value = [aws_subnet.public.*.id]
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = [aws_subnet.public.*.cidr_block]
}

output "public_subnets_az" {
  description = "List of public subnet availability_zones"
  value = [aws_subnet.public.*.availability_zone]
}

output "private_subnets_az" {
  description = "List of public subnet availability_zones"
  value = [aws_subnet.private.*.availability_zone]
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = [aws_subnet.private.*.cidr_block]
}

output "private_subnet_ids" {
  value = [aws_subnet.private.*.id]
}

output "internal_sg_group_id" {
  value = aws_security_group.internal_sg.id
}

output "nat_gateway_ids" {
  value = [aws_nat_gateway.nat_gw.*.id]
}

output "nat_security_group_id" {
  value = aws_security_group.nat.id
}

output "availability_zones" {
  value = var.availability_zones
}

