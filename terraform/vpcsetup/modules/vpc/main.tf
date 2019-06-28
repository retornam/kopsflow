resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge(
    {
      "Name" = "${var.name}-${var.env}-vpc"
    },
    var.rtags,
  )
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = merge(
    {
      "Name" = "${var.name}-${var.env}-ig"
    },
    var.rtags,
  )
}