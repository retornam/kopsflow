variable "name" {
}

variable "env" {
}

variable "vpc_id" {
}

variable "vpc_cidr" {
}

variable "availability_zones" {
  type = list(string)
  default = [
    "us-west-2a",
    "us-west-2b",
    "us-west-2c",
  ]
}

variable "internet_gateway_id" {
}

variable "newbits" {
  default     = 8
  description = "number of bits to add to the vpc cidr when building subnets"
}

variable "az_number" {
  default = {
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
  }
}

variable "public_netnum_offset" {
  default = 0
}

variable "private_netnum_offset" {
  default = 100
}

variable "rtags" {
  type    = map(string)
  default = {}
}

variable "cidr_whitelist" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
