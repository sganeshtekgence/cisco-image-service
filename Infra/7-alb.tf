# ############################################
# # Application Load Balancer
# ############################################

# ############################################
# # ALB Security Group
# ############################################

# resource "aws_security_group" "alb_sg" {
#   name        = "cisco-alb-sg"
#   description = "ALB security group"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     description = "HTTP from internet"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     description = "All outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = local.common_tags
# }

# ############################################
# # ALB
# ############################################

# resource "aws_lb" "app_alb" {
#   name               = "cisco-app-alb"
#   load_balancer_type = "application"
#   internal           = false

#   subnets         = module.vpc.public_subnets
#   security_groups = [aws_security_group.alb_sg.id]

#   enable_deletion_protection = false

#   tags = local.common_tags
# }

# ############################################
# # Target Group (IP mode for Fargate)
# ############################################

# resource "aws_lb_target_group" "app_tg" {
#   name        = "cisco-app-tg"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = module.vpc.vpc_id
#   target_type = "ip"

#   health_check {
#     path                = "/health"
#     healthy_threshold   = 3
#     unhealthy_threshold = 2
#     interval            = 30
#     timeout             = 5
#     matcher             = "200"
#   }

#   tags = local.common_tags
# }

# ############################################
# # Listener
# ############################################

# # resource "aws_lb_listener" "http" {
# #   load_balancer_arn = aws_lb.app_alb.arn
# #   port              = 80
# #   protocol          = "HTTP"

# #   default_action {
# #     type             = "forward"
# #     target_group_arn = aws_lb_target_group.app_tg.arn
# #   }
# # }

# ############################################
# # Outputs (used by ECS Service)
# ############################################

# # output "alb_dns_name" {
# #   value = aws_lb.app_alb.dns_name
# # }

# # output "alb_sg_id" {
# #   value = aws_security_group.alb_sg.id
# # }

# # output "alb_target_group_arn" {
# #   value = aws_lb_target_group.app_tg.arn
# # }