############################################
# ECS TASK EXECUTION ROLE
# - Pull image from ECR
# - Write logs to CloudWatch
# - Read Secrets Manager (REQUIRED for secret injection)
############################################

resource "aws_iam_role" "ecs_execution_role" {
  name = "cisco-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

# AWS-managed policy:
# - ECR auth
# - CloudWatch logs
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

############################################
# Execution Role Policy (Secrets Manager)
# REQUIRED: secrets are fetched BEFORE container start
############################################

resource "aws_iam_policy" "ecs_execution_secrets_policy" {
  name = "cisco-ecs-execution-secrets-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.image_secret.arn
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution_secrets_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_secrets_policy.arn
}

############################################
# ECS TASK ROLE
# - Used by application code AFTER startup
# - Future DynamoDB / S3 access
############################################

resource "aws_iam_role" "ecs_task_role" {
  name = "cisco-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

############################################
# Task Role Policy (Secrets Manager)
# Optional now, useful if app reads secrets dynamically
############################################

resource "aws_iam_policy" "ecs_task_secrets_policy" {
  name = "cisco-ecs-task-secrets-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.image_secret.arn
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_secrets_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_secrets_policy.arn
}

############################################
# Outputs (used by ECS task definition)
############################################

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}