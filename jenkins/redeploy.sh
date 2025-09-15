#!/bin/bash

# Jenkins 재배포 스크립트
set -e

echo "🔄 Redeploying Jenkins with custom image..."

# 1. 기존 Jenkins pod 삭제
echo "Deleting existing Jenkins pods..."
kubectl delete pods -l app=jenkins -n jenkins --ignore-not-found=true

# 2. 배포 업데이트
echo "Applying custom Jenkins deployment..."
kubectl apply -f jenkins-dp-custom.yaml

# 3. 배포 상태 확인
echo "Waiting for Jenkins to be ready..."
kubectl rollout status deployment/jenkins -n jenkins --timeout=300s

# 4. Pod 상태 확인
echo ""
echo "📊 Current Jenkins pod status:"
kubectl get pods -l app=jenkins -n jenkins -o wide

echo ""
echo "📝 To check logs:"
echo "kubectl logs -f deployment/jenkins -n jenkins"

echo ""
echo "🌐 To access Jenkins:"
echo "kubectl port-forward -n jenkins deployment/jenkins 8080:8080"

echo ""
echo "✅ Jenkins redeployment completed!"
