data "aws_route53_zone" "external" {
  name = var.domain_name
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.env}.${var.name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Environment = var.env
  }
  
}

resource "aws_s3_bucket_public_access_block" "bucketblock" {
  bucket = "${aws_s3_bucket.bucket.id}"

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_acm_certificate" "tls" {
  domain_name       = "*.${var.env}.${var.name}"
  validation_method = "DNS"

  tags = {
    Environment = "${var.env}.${var.name}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  name    =  aws_acm_certificate.tls.domain_validation_options.0.resource_record_name
  type    =  aws_acm_certificate.tls.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.external.zone_id
  records = [aws_acm_certificate.tls.domain_validation_options.0.resource_record_value]
  ttl     = "60"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.tls.arn
  validation_record_fqdns = [aws_route53_record.validation.fqdn]
  depends_on = [aws_route53_record.validation]
  lifecycle {
    prevent_destroy = true
  }
}


module "vpc" {
  source   = "./modules/vpc"
  name     = var.name
  env      = var.env
  vpc_cidr = var.vpc_cidr

  rtags = {
    Infra             = "${var.env}.${var.name}"
    Environment       = var.env
    Terraform         = "true"
    KubernetesCluster = "${var.env}.${var.name}"
  }
}

module "subnet_pair" {
  source              = "./modules/subnet-pair"
  name                = var.name
  env                 = var.env
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = module.vpc.cidr_block
  internet_gateway_id = module.vpc.internet_gateway_id
  availability_zones  = var.azs
  cidr_whitelist      = var.cidr_whitelist

  rtags = {
    Infra             = "${var.env}.${var.name}"
    Environment       = var.env
    Terraform       = "true"
    KubernetesCluster = "${var.env}.${var.name}"
  }
}
