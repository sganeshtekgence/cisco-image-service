
# ########################
# # SECURITY GROUPS
# ########################

# resource "aws_security_group" "alb" {
#   name   = "${var.app_name}-alb-sg"
#   vpc_id = module.vpc.vpc_id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "ecs" {
#   name   = "${var.app_name}-ecs-sg"
#   vpc_id = module.vpc.vpc_id

#   ingress {
#     from_port       = 5000
#     to_port         = 5000
#     protocol        = "tcp"
#     security_groups = [aws_security_group.alb.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }