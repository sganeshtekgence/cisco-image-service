pipeline {
  agent any

  environment {
    AWS_REGION     = "us-east-1"
    AWS_ACCOUNT_ID = "147871689327"
    ECR_REPO       = "147871689327.dkr.ecr.us-east-1.amazonaws.com/cisco-app"
    IMAGE_TAG      = "${BUILD_NUMBER}"
  }

  stages {

    stage("Checkout Source Code") {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            url: 'https://github.com/sganeshtekgence/cisco-image-service.git',
            credentialsId: 'github-https-creds'
          ]]
        ])
      }
    }

    stage("Build Docker Image") {
      steps {
        dir("App") {
          sh 'docker build -t cisco-app:${IMAGE_TAG} .'
        }
      }
    }

    stage("Login & Push to ECR") {
      steps {
        dir("App") {
          sh '''
            aws ecr get-login-password --region $AWS_REGION \
              | docker login --username AWS \
                --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

            docker tag cisco-app:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
            docker push ${ECR_REPO}:${IMAGE_TAG}
          '''
        }
      }
    }

    stage("Deploy to ECS via Terraform") {
      steps {
        dir("App/deploy") {
          sh '''
            terraform init
            terraform apply -auto-approve \
              -var="image_tag=${IMAGE_TAG}"
          '''
        }
      }
    }
  }

  post {
    success {
      echo "Deployment succeeded for image tag: ${IMAGE_TAG}"
    }
    failure {
      echo "Deployment failed for image tag: ${IMAGE_TAG}"
    }
  }
}
