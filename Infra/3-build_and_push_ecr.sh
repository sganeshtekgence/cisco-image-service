#!/usr/bin/env bash
set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)
REPO_NAME="cisco-app"
IMAGE_TAG="latest"

ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="${SCRIPT_DIR}/../App"

echo "Using app directory: ${APP_DIR}"

aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin \
    "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

docker build -t "${ECR_URI}" "$APP_DIR"
docker push "${ECR_URI}"

echo "Image pushed: ${ECR_URI}"