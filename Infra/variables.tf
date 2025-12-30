variable "region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "image-server"
}
variable "image_secret_value" {
  description = "Secret value used by image API"
  type        = string
  sensitive   = true
  default = "h20tavyWvchAlZko21t0X0lH93VJCQBn"
}