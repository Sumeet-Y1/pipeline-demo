output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.pipeline_demo.public_ip
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.pipeline_demo.repository_url
}