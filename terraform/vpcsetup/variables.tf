variable "name" {
  description = "fully qualified dns name of the cluster"
}

variable "region" {
  default = "us-west-2"
}

variable "azs" {
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
  type    = list(string)
}

variable "env" {
  default = "prod"
}

variable "vpc_cidr" {
  description = "CIDR range for VPC"
}

variable "cidr_whitelist" {
  description = "IP whitelist for security groups"
}

variable "domain_name" {
  description = "the domain name"
}