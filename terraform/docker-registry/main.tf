# Provide the public key that we want in our instance so we can
# SSH into it using the other side (private) of it.
resource "aws_key_pair" "main" {
  key_name_prefix = "registy"
  public_key      = file("./keys/keys.rsa.pub")
}

# Create a security group that allows anyone to access our
# instance's port 5000 (where the main registry functionality
# lives).
#
# Naturally, you'd not do this if you're deploying a private
# registry - something you could do is allow the internal cidr
# and not 0.0.0.0/0.
resource "aws_security_group" "allow-registry-ingress" {
  name = "allow-registry-ingress"

  description = "Allows ingress on 443 and 80."
  vpc_id      = var.vpc

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docker-registry-ingress"
  }
}

# Allow SSHing into the instance
resource "aws_security_group" "allow-ssh-and-egress" {
  name = "allow-ssh-and-egress"

  description = "Allows ingress SSH traffic and egress to any address."
  vpc_id      = var.vpc

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_whitelist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docker-registry-ssh-egress"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create an instance in the default VPC with a specified
# SSH key so we can properly SSH into it to verify whether
# everything is worked as intended.
resource "aws_instance" "main" {
  instance_type               = "t2.micro"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.main.id
  iam_instance_profile        = aws_iam_instance_profile.main.name
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.allow-ssh-and-egress.id,
    aws_security_group.allow-registry-ingress.id,
  ]

  tags = {
    Name = "docker-registry"
  }
}



resource "aws_eip" "registryeip" {
  vpc = true
  tags = {
    Name = "docker-registry"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.main.id
  allocation_id = aws_eip.registryeip.id
}

resource "aws_route53_record" "registryroute" {
  name    = var.server_name
  type    = "A"
  ttl     = "300"
  records = [aws_eip.registryeip.public_ip]

  zone_id = format("/hostedzone/%s", var.zone_id)
}


resource "null_resource" "cluster" {
  # ...

  provisioner "local-exec" {
    command = <<EOT
cat << EOF > ../../ansible/hosts
[registry]
${aws_eip.registryeip.public_ip}
EOF
EOT
  }
}
