# 카나리 배포 설정 가이드

## 1. 설치 단계

### 1.1 Argo Rollouts 설치
```bash
# EKS 클러스터에 Argo Rollouts 설치
kubectl apply -f argo-rollouts/install-argo-rollouts.yaml

# 설치 확인
kubectl get pods -n argo-rollouts
```

### 1.2 기존 Deployment 제거 (카나리 배포 사용할 서비스만)
```bash
# 기존 user-service deployment 제거
kubectl delete -f deployments/user-dp.yaml
```

### 1.3 Rollout 배포
```bash
# user-service Rollout 배포
kubectl apply -f rollouts/user-rollout.yaml

# Rollout 상태 확인
kubectl argo rollouts get rollout user-service -n default
```

## 2. 카나리 배포 워크플로우

### GitHub Actions를 통한 자동 배포:
1. **코드 푸시** → `goormOne_msa_2` 레포의 `release/1.0.0` 브랜치에 푸시
2. **ECR 이미지 빌드 및 푸시** → 새 이미지가 ECR에 업로드
3. **카나리 배포 시작** → Rollout이 새 이미지로 20% 트래픽 카나리 배포 시작
4. **수동 승인 대기** → 로그에서 제공하는 명령어로 수동 승인 필요

## 3. 수동 제어 명령어

### 3.1 배포 진행
```bash
# 다음 단계로 진행 (20% → 50% → 100%)
kubectl argo rollouts promote user-service -n default

# 전체 단계 건너뛰고 바로 100% 배포
kubectl argo rollouts promote user-service -n default --full
```

### 3.2 배포 중단 및 롤백
```bash
# 현재 카나리 배포 중단하고 이전 버전으로 롤백
kubectl argo rollouts abort user-service -n default

# 특정 리비전으로 롤백
kubectl argo rollouts undo user-service -n default --to-revision=2
```

### 3.3 상태 확인
```bash
# 현재 Rollout 상태 확인
kubectl argo rollouts get rollout user-service -n default

# 실시간 모니터링
kubectl argo rollouts get rollout user-service -n default --watch

# Rollout 히스토리 확인
kubectl argo rollouts history user-service -n default
```

## 4. 카나리 배포 단계 설명

1. **20% 트래픽** → 새 버전으로 20% 트래픽 전달 (30초 대기)
2. **50% 트래픽** → 새 버전으로 50% 트래픽 전달 (30초 대기)
3. **100% 트래픽** → 새 버전으로 모든 트래픽 전달 (배포 완료)

각 단계에서 문제가 발생하면 자동으로 롤백하거나 수동으로 중단할 수 있습니다.

## 5. 모니터링

### 5.1 Pod 상태 확인
```bash
kubectl get pods -l app=user-service
```

### 5.2 Service 상태 확인
```bash
kubectl get svc user-service
```

### 5.3 Ingress 상태 확인
```bash
kubectl get ingress title
```

## 6. 다른 서비스에 카나리 배포 적용

다른 서비스(auth, order, store 등)에도 동일하게 적용하려면:

1. `rollouts/` 폴더에 해당 서비스의 rollout.yaml 생성
2. 해당 서비스의 GitHub Actions 워크플로우 수정
3. 기존 deployment 제거 후 rollout 배포

## 7. 트러블슈팅

### Rollout이 진행되지 않는 경우:
```bash
# Rollout 이벤트 확인
kubectl describe rollout user-service -n default

# Pod 로그 확인
kubectl logs -l app=user-service --tail=100
```

### ALB 타겟 그룹 확인:
```bash
# AWS CLI로 타겟 그룹 헬스 확인
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## 8. 주의사항

- 카나리 배포 중에는 절대 수동으로 Pod을 삭제하지 마세요
- 배포가 실패하면 자동 롤백이 실행됩니다
- 프로덕션 환경에서는 더 세밀한 헬스체크와 메트릭 모니터링을 설정하는 것을 권장합니다
