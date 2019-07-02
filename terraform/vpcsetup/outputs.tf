output "name" {
  value = var.name
}

output "awsRegion" {
  value = var.region
}

output "clusterName" {
  value = "${var.env}.${var.name}"
}

output "vpcID" {
  value = module.vpc.vpc_id
}

output "vpcCIDR" {
  value = module.vpc.cidr_block
}

output "publicSubnets" {
  value = module.subnet_pair.public_subnet_ids
}

output "privateSubnets" {
  value = module.subnet_pair.private_subnet_ids
}

output "privateNATGateways" {
  value = module.subnet_pair.nat_gateway_ids
}

output "availability_zones" {
  value = [
    for item in module.subnet_pair.availability_zones :
    substr(item, -1, -1)
  ]
}

output "default_security_group_id" {
  value = module.subnet_pair.internal_sg_group_id
}

output "s3_bucket" {
  value = "s3://${aws_s3_bucket.bucket.id}"
}

output "certificate_arn" {
  value = aws_acm_certificate.tls.arn
}
