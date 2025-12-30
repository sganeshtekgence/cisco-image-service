resource "aws_ecr_repository" "app" {
  name = "cisco-app"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app.repository_url
}