# MSA 기반 서비스 아키텍처 구축 프로젝트

## 📌 Goal
본 프로젝트는 **MSA(Microservices Architecture)** 기반으로 서비스 아키텍처를 구축하고, 확장성과 안정성을 강화하는 것을 목표로 합니다.  
주요 목표는 다음과 같습니다:
1. **이벤트 기반 아키텍처** → 서비스 간 느슨한 결합으로 확장성과 복원력 강화  
2. **Kubernetes 오케스트레이션** → 자동 확장, 무중단 배포, 고가용성 확보  
3. **Observability 환경 구축** → 로그·메트릭 통합 분석, 빠른 장애 탐지·해결  

---

## 🚨 Problem
과거에는 **전화 주문 중심**이었으나, 이제는 **앱 기반 실시간 주문**이 일반화되었습니다.  
하지만 기존 컨테이너 기반 MSA 환경은 프로덕션 수준에 적합하지 않았습니다.  

- 서비스 간 **직접 API 호출** → 독립적 확장 어려움, 장애 전파 위험  
- **단순 컨테이너 실행** → 배포·확장·장애 대응 자동화 한계  
- **분산 환경** → 호출 추적 및 오류 원인 분석, 성능 병목 파악 어려움  

---

## 🏗️ Architecture
- **Event-driven Architecture** 기반 메시지 브로커 활용  
- **Kubernetes** 클러스터에서 MSA 서비스 오케스트레이션  
- **CI/CD 파이프라인**: GitHub Actions (CI) + ArgoCD (CD): Canary 배포 
- **Canary Deployment** 전략을 통해 점진적 트래픽 전환 및 안정성 확보  

---

## ⚙️ Tech Stack
- **Backend**: Spring Boot (Java), Redis, Kafka
- **AI**: Python 
- **Infra**: AWS EKS, ECR, MSK , Kubernetes, Helm
- **CI/CD**: GitHub Actions, ArgoCD  
- **Monitoring**: Prometheus, Grafana, Loki  

---

## ✅ Key Features
- **자동 확장 & 무중단 배포** (Kubernetes HPA + Canary Deployment)  
- **안정적인 배포 파이프라인** (CI/CD 분리 운영)  
- **관측 가능성 확보** (로그·메트릭·트레이싱 통합)  

---

```
goormOne_kubernetes/
├── cluster/                       # 클러스터 관련 설정 파일
├── deployments/                   # Deployment 리소스 정의
│   ├── ai-dp.yaml
│   ├── auth-dp.yaml
│   ├── common-dp.yaml
│   ├── order-dp.yaml
│   ├── payment-dp.yaml
│   ├── store-dp.yaml
│   └── user-dp.yaml
├── goormOne/                      # Helm Chart 디렉토리
│   ├── charts/
│   ├── templates/                 # Helm 템플릿 리소스 정의
│   │   ├── tests/
│   │   ├── _helpers.tpl
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── hpa.yaml
│   │   ├── ingress.yaml
│   │   ├── secret.yaml
│   │   ├── service.yaml
│   │   └── serviceaccount.yaml
│   ├── Chart.yaml                 # Helm Chart 메타데이터
│   ├── values.yaml                # 기본 values 설정
│   └── values-secret.yaml         # 시크릿 values 설정
├── jenkins/                       # Jenkins 관련 설정
├── services/                      # Service 리소스 정의
│   ├── ai-svc.yaml
│   ├── auth-svc.yaml
│   ├── common-svc.yaml
│   ├── order-svc.yaml
│   ├── payment-svc.yaml
│   ├── store-svc.yaml
│   └── user-svc.yaml
└── .helmignore                    # Helm 빌드 시 제외할 파일
```


