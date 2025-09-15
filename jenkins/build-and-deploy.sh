#!/bin/bash

# Jenkins 커스텀 이미지 빌드 및 배포 스크립트
set -e

# 환경변수 설정
REGISTRY="490913547024.dkr.ecr.ap-northeast-2.amazonaws.com"
IMAGE_NAME="jenkins-custom"
TAG="${1:-latest}"
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${TAG}"

echo "🏗️ Building Jenkins custom image..."

# 1. Docker 이미지 빌드
echo "Building image: ${FULL_IMAGE}"
docker build -t ${IMAGE_NAME}:${TAG} .
docker tag ${IMAGE_NAME}:${TAG} ${FULL_IMAGE}

echo "✅ Image built successfully: ${FULL_IMAGE}"

# 2. ECR 로그인 (선택사항 - 푸시할 경우)
read -p "Do you want to push to ECR? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔐 Logging in to ECR..."
    aws ecr get-login-password --region ap-northeast-2 | \
        docker login --username AWS --password-stdin ${REGISTRY}
    
    # ECR 리포지토리가 없으면 생성
    aws ecr describe-repositories --repository-names ${IMAGE_NAME} --region ap-northeast-2 || \
        aws ecr create-repository --repository-name ${IMAGE_NAME} --region ap-northeast-2
    
    # 3. 이미지 푸시
    echo "🚀 Pushing image to ECR..."
    docker push ${FULL_IMAGE}
    
    echo "✅ Image pushed successfully: ${FULL_IMAGE}"
    
    # 4. Kubernetes 배포 업데이트 제안
    echo ""
    echo "📝 To update your Jenkins deployment, run:"
    echo "kubectl set image deployment/jenkins jenkins=${FULL_IMAGE} -n jenkins"
    echo ""
    echo "Or update the jenkins-dp.yaml file with:"
    echo "  image: ${FULL_IMAGE}"
else
    echo "ℹ️ Image built locally only."
    echo ""
    echo "📝 To use locally, update jenkins-dp.yaml with:"
    echo "  image: ${IMAGE_NAME}:${TAG}"
fi

echo ""
echo "🎉 Done! Your custom Jenkins image includes:"
echo "  ✅ Docker CE"
echo "  ✅ AWS CLI v2" 
echo "  ✅ kubectl"
echo "  ✅ Gradle"
echo "  ✅ Jenkins with JDK 17"
