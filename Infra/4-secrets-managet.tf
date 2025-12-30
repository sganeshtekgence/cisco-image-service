############################################
# Secrets Manager - Image API Secret
############################################
resource "aws_secretsmanager_secret" "image_secret" {
  name        = "cisco/image-service/IMAGE_SECRET"
  description = "Secret used to authenticate image upload/download API"

  recovery_window_in_days = 0  # delete immediately if destroyed

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "image_secret_version" {
  secret_id     = aws_secretsmanager_secret.image_secret.id
  secret_string = var.image_secret_value
}

############################################
# Outputs (used by ECS later)
############################################

output "image_secret_arn" {
  description = "ARN of IMAGE_SECRET in Secrets Manager"
  value       = aws_secretsmanager_secret.image_secret.arn
}