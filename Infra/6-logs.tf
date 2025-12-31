############################################
# CloudWatch Logs for ECS
############################################
resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/cisco-image-service-new"
  retention_in_days = 7

  tags = local.common_tags
}

############################################
# Output (used by ECS task definition)
############################################

output "ecs_log_group_name" {
  value = aws_cloudwatch_log_group.ecs_app.name
}