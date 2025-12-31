provider "aws" {
  region = var.region
}

# -------------------------------------------------
# Read IMAGE_SECRET from AWS Secrets Manager
# -------------------------------------------------

data "aws_secretsmanager_secret" "image_secret" {
  name = "cisco/image-service/IMAGE_SECRET_NEW"
}

data "aws_secretsmanager_secret_version" "image_secret" {
  secret_id = data.aws_secretsmanager_secret.image_secret.id
}

locals {
  image_secret = data.aws_secretsmanager_secret_version.image_secret.secret_string
}
# -------------------------------------------------
# Get existing ECS cluster
# -------------------------------------------------

data "aws_ecs_cluster" "this" {
  cluster_name = "cisco-ecs-cluster"
}

# -------------------------------------------------
# Register NEW task definition revision
# -------------------------------------------------
resource "aws_ecs_task_definition" "app" {
  family                   = "cisco-image-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  # ✅ REQUIRED for Fargate + ECR + Secrets
  execution_role_arn = "arn:aws:iam::147871689327:role/cisco-ecs-execution-role"

  # ✅ Used by application code (optional but correct)
  task_role_arn = "arn:aws:iam::147871689327:role/cisco-ecs-task-role"

  container_definitions = jsonencode([
    {
      name      = "cisco-image-service"
      image     = "147871689327.dkr.ecr.us-east-1.amazonaws.com/cisco-app:${var.image_tag}"
      essential = true

      portMappings = [
        { containerPort = 8080, protocol = "tcp" }
      ]

      environment = [
        { name = "APP_PORT", value = "8080" }
      ]

      # ✅ BEST PRACTICE: Secrets injected at runtime
      secrets = [
        {
          name      = "IMAGE_SECRET"
          valueFrom = "arn:aws:secretsmanager:us-east-1:147871689327:secret:cisco/image-service/IMAGE_SECRET_NEW"
        }
      ]
    }
  ])
}


# -------------------------------------------------
# Update ECS Service to new task revision
# -------------------------------------------------

resource "aws_ecs_service" "deploy" {
  name            = "cisco-image-service"
  cluster         = data.aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  lifecycle {
    ignore_changes = [
      desired_count,
      network_configuration
    ]
  }
}
