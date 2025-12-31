variable "region" {
  type    = string
  default = "us-east-1"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag pushed to ECR"
}
