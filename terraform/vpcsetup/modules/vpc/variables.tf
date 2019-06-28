variable "name" {
}

variable "env" {
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
}

variable "rtags" {
  type    = map(string)
  default = {}
}

