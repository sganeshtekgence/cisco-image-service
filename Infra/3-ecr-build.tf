###########################################
# Build & Push Docker Image via Terraform
###########################################

# variable "image_tag" {
#   description = "Docker image tag"
#   type        = string
#   default     = "latest"
# }

# resource "null_resource" "build_and_push_image" {

#   triggers = {
#     # Rebuild when Dockerfile changes
#     dockerfile_hash = filesha256("${path.module}/../App/Dockerfile")

#     # Rebuild when application code changes
#     app_code_hash = filesha256("${path.module}/../App/app.py")

#     # Optional: requirements changes
#     requirements_hash = filesha256("${path.module}/../App/requirements.txt")

#     # Optional: force rebuild manually by changing this value
#     image_tag = "latest"
#   }

#   provisioner "local-exec" {
#     working_dir = path.module
#     command     = "bash ./3-build_and_push_ecr.sh"
#   }

#   depends_on = [
#     aws_ecr_repository.app
#   ]
# }