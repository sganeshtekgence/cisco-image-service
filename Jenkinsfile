pipeline {
  agent any

  environment {
    AWS_REGION    = "us-east-1"
    ECR_REPO      = "cisco-app"
    ECS_CLUSTER   = "cisco-ecs-cluster"
    ECS_SERVICE   = "cisco-image-service"
    IMAGE_TAG     = "${BUILD_NUMBER}"
  }

  stages {

    stage("Checkout") {
      steps {
        checkout scm
      }
    }

    stage("Terraform Init & Apply") {
      steps {
        dir("Infra") {
          sh """
            terraform init -input=false
            terraform apply -auto-approve
          """
        }
      }
    }

    stage("Resolve AWS Account") {
      steps {
        script {
          env.AWS_ACCOUNT_ID = sh(
            script: "aws sts get-caller-identity --query Account --output text",
            returnStdout: true
          ).trim()

          env.ECR_URI = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
        }
      }
    }

    stage("Login to ECR") {
      steps {
        sh """
          aws ecr get-login-password --region ${AWS_REGION} \
          | docker login --username AWS --password-stdin ${ECR_URI}
        """
      }
    }

    stage("Build Docker Image") {
      steps {
        sh """
          docker build \
            -t ${ECR_URI}:${IMAGE_TAG} \
            -t ${ECR_URI}:latest \
            App
        """
      }
    }

    stage("Push Image to ECR") {
      steps {
        sh """
          docker push ${ECR_URI}:${IMAGE_TAG}
          docker push ${ECR_URI}:latest
        """
      }
    }

    stage("Deploy to ECS") {
      steps {
        sh """
          aws ecs update-service \
            --cluster ${ECS_CLUSTER} \
            --service ${ECS_SERVICE} \
            --force-new-deployment \
            --region ${AWS_REGION}
        """
      }
    }
  }

  post {
    success {
      echo "Deployment successful"
    }
    failure {
      echo "Deployment failed"
    }
  }
}