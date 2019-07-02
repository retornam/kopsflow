variable "bucket" {
  description = "Name of the bucket to use to store image layers"
  default     = "sample-docker-registry-bucket"
}

variable "zone_id" {
  description = "zone_id in aws"
}

variable "region" {
  description = "Region to create the AWS resources"
  default     = "us-west-2"
}

variable "vpc" {
  description = "vpc id"
}

variable "server_name" {
  description = "The FQDN of the registry server"
}

variable "profile" {
  description = "Profile to use when provisioning AWS resources"
  default     = "default"
}

variable "ssl_certificate_id" {
  description = "ssl certificate id"
}

variable "cidr_whitelist" {
  description = "IP whitelist for security groups"
}

