############################################
# ECS Cluster
############################################

resource "aws_ecs_cluster" "app" {
  name = "cisco-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Project = "cisco"
    Network = "shared"
  }
}

############################################
# ECS TASK DEFINITION
############################################

resource "aws_ecs_task_definition" "app" {
  family                   = "cisco-image-service"
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

  container_definitions = jsonencode([
    {
      name  = "image-service"
      image = "${aws_ecr_repository.app.repository_url}:latest"
      essential = true
      portMappings = [{ containerPort = 80 }]
    }
  ])
}
############################################
# SECURITY GROUP FOR ECS TASKS
############################################

resource "aws_security_group" "ecs_task_sg" {
  name        = "cisco-ecs-task-sg"
  description = "Allow inbound HTTP and all outbound"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
# ECS SERVICE (NO ALB, PUBLIC IP)
############################################

resource "aws_ecs_service" "app" {
  name            = "cisco-image-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_task_sg.id]
  }

  tags = local.common_tags
}

############################################
# Output (optional)
############################################

output "ecs_cluster_id" {
  value = aws_ecs_cluster.app.id
}