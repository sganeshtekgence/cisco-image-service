############################################
# Variables
############################################

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name"
  default     = "cisco"
}

variable "service_name" {
  type        = string
  description = "ECS service name"
  default     = "cisco-image-service"
}

############################################
# ECS Cluster
############################################

resource "aws_ecs_cluster" "app" {
  name = "cisco-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

############################################
# CloudWatch Logs (for ECS)
############################################

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 14
  tags              = local.common_tags
}

############################################
# ECS Task Definition
############################################

resource "aws_ecs_task_definition" "app" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  # IMPORTANT:
  # Image tag is a placeholder.
  # Jenkins will register a NEW task definition with the real image tag.
  container_definitions = jsonencode([
    {
      name      = "image-service"
      image     = "${aws_ecr_repository.app.repository_url}:PLACEHOLDER"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.common_tags
}

############################################
# Security Group for ECS Tasks
############################################

resource "aws_security_group" "ecs_task_sg" {
  name        = "cisco-ecs-task-sg"
  description = "ECS task security group"
  vpc_id      = module.vpc.vpc_id

  # TEMPORARY:
  # Allow HTTP within VPC.
  # When ALB is added, restrict this to ALB SG only.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

############################################
# ECS Service (Jenkins controls deployments)
############################################

resource "aws_ecs_service" "app" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.app.id
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app.arn

  network_configuration {
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_task_sg.id]
  }

  # CRITICAL:
  # Prevent Terraform from redeploying when Jenkins updates task definition
  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = local.common_tags
}

############################################
# Outputs
############################################

output "ecs_cluster_name" {
  value = aws_ecs_cluster.app.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
