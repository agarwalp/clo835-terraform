output "ecr_mysql_repo_url" {
  value = aws_ecr_repository.mysql_repo.repository_url
}

output "ecr_webapp_repo_url" {
  value = aws_ecr_repository.webapp_repo.repository_url
}

output "ec2_instance_public_ip" {
  value = aws_instance.app_instance.public_ip
}
