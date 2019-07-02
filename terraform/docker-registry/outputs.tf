output "public-ip" {
  description = "Public IP of the instance created"
  value       = aws_eip.registryeip.public_ip
}