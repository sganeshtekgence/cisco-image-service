data "aws_availability_zones" "azs" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "cisco-vpc"
  cidr = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  azs = slice(data.aws_availability_zones.azs.names, 0, 3)

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  map_public_ip_on_launch = true

  # Global VPC tags
  tags = {
    Project = "cisco"
    Network = "shared"
  }

  # Public subnet naming (ALB)
  public_subnet_tags = {
    Tier = "public"
    Role = "alb"
  }

  # Private subnet naming (ECS)
  private_subnet_tags = {
    Tier = "private"
    Role = "ecs"
  }

  # Per-subnet Name tags (important)
  public_subnet_names = [
    "cisco-public-a",
    "cisco-public-b",
    "cisco-public-c"
  ]

  private_subnet_names = [
    "cisco-private-ecs-a",
    "cisco-private-ecs-b",
    "cisco-private-ecs-c"
  ]
}