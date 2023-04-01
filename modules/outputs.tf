output "public_ip" {
  value = aws_instance.aws_linux[*].public_ip
}

output "arn" {
  value = aws_instance.aws_linux[*].arn
}