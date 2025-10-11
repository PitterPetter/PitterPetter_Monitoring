# PitterPetter ELK Stack Monitoring

PitterPetter 프로젝트의 로그 모니터링을 위한 ELK Stack 배포 가이드

## 📋 개요

이 프로젝트는 PitterPetter 애플리케이션의 로그를 수집, 저장, 분석하기 위한 ELK Stack을 Helm을 사용하여 GKE에 배포합니다. 
Terraform을 통한 인프라 관리와 Helm을 통한 애플리케이션 배포를 지원합니다.

## 🏗️ 아키텍처

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │    Filebeat     │    │   Logstash      │
│   Services      │───▶│  (DaemonSet)    │───▶│  (Deployment)   │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Kibana      │◀───│  Elasticsearch  │◀───│   Logstash      │
│  (Deployment)   │    │  (StatefulSet)  │    │                 │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 빠른 시작

### 1. 사전 요구사항

- Kubernetes 클러스터 (GKE)
- Helm 3.x
- kubectl
- Terraform (인프라 배포용)

### 2. 배포 방법

#### 방법 1: Terraform을 통한 전체 배포 (권장)

```bash
# Terraform 초기화
cd terraform
terraform init

# 배포 계획 확인
terraform plan -var-file="monitoring.tfvars"

# ELK 스택 배포
terraform apply -var-file="monitoring.tfvars"
```

#### 방법 2: Helm을 통한 수동 배포

```bash
# Helm Repository 추가
helm repo add elastic https://helm.elastic.co
helm repo update

# 네임스페이스 생성
kubectl create namespace monitoring

# ELK Stack 배포
helm install loventure-elk-master elastic/elasticsearch -n monitoring -f helm-charts/elasticsearch/values.yaml
helm install kibana elastic/kibana -n monitoring -f helm-charts/kibana/values.yaml
helm install logstash elastic/logstash -n monitoring -f helm-charts/logstash/values.yaml
helm install filebeat elastic/filebeat -n monitoring -f helm-charts/filebeat/values.yaml
```

## 📁 프로젝트 구조

```
PitterPetter_Monitoring/
├── README.md
├── terraform/                    # Terraform 인프라 코드
│   ├── 01-namespace.tf
│   ├── 02-elasticsearch.tf
│   ├── 03-logstash.tf
│   ├── 04-kibana.tf
│   ├── 05-filebeat.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── monitoring.tfvars
│   └── README.md
├── helm-charts/                  # Helm 차트 설정
│   ├── elasticsearch/
│   │   └── values.yaml
│   ├── kibana/
│   │   ├── values.yaml
│   │   └── kibana-init-configmap.yaml
│   ├── logstash/
│   │   └── values.yaml
│   ├── filebeat/
│   │   └── values.yaml
│   └── monitoring/
│       ├── dashboards/
│       │   ├── application-overview.json
│       │   └── infrastructure-overview.json
│       ├── index-patterns/
│       │   └── pitterpetter-logs.json
│       └── visualizations/
├── scripts/
│   ├── deploy.sh
│   └── cleanup.sh
├── elk-stack/
│   └── namespace.yaml
└── docs/
    └── monitoring-guide.md
```

## 🔧 설정

### 주요 설정 내용

#### Elasticsearch
- **클러스터 타입**: 단일 노드 (single-node)
- **리소스**: CPU 1 core, Memory 2Gi
- **스토리지**: 20Gi PersistentVolume
- **보안**: X-Pack Security 활성화

#### Logstash
- **파이프라인**: Spring Boot, FastAPI, PostgreSQL 로그 파싱
- **템플릿**: 커스텀 인덱스 템플릿 (`loventure-logs`)
- **리소스**: CPU 1 core, Memory 2Gi
- **포트**: 5044 (Beats), 9600 (HTTP)

#### Kibana
- **인덱스 패턴**: `loventure-logs-*`
- **대시보드**: 애플리케이션 및 인프라 모니터링
- **포트**: 5601

#### Filebeat
- **로그 수집**: Kubernetes Pod 로그
- **출력**: Logstash (5044 포트)
- **DaemonSet**: 모든 노드에서 실행

### 네임스페이스
- **모니터링 네임스페이스**: `monitoring`
- **서비스 이름**: `loventure-elk-master`, `kibana-kibana`, `logstash-logstash`

## 📊 모니터링

### 접속 정보
- **Kibana**: `kubectl port-forward -n monitoring svc/kibana-kibana 5601:5601`
- **Elasticsearch**: `kubectl port-forward -n monitoring svc/loventure-elk-master 9200:9200`

### 로그 인덱스
- **인덱스 패턴**: `loventure-logs-*`
- **로그 타입**: Spring Boot, FastAPI, PostgreSQL, Kubernetes Events

## 🛠️ 유지보수

### 상태 확인
```bash
# 전체 ELK 스택 상태 확인
kubectl get pods -n monitoring

# 각 컴포넌트 로그 확인
kubectl logs -n monitoring loventure-elk-master-0
kubectl logs -n monitoring logstash-logstash-0
kubectl logs -n monitoring kibana-kibana-6d64c95589-fmqt7
kubectl logs -n monitoring filebeat-filebeat-277vr
```

### 업그레이드
```bash
# Helm을 통한 업그레이드
helm upgrade loventure-elk-master elastic/elasticsearch -n monitoring -f helm-charts/elasticsearch/values.yaml
helm upgrade kibana elastic/kibana -n monitoring -f helm-charts/kibana/values.yaml
helm upgrade logstash elastic/logstash -n monitoring -f helm-charts/logstash/values.yaml
helm upgrade filebeat elastic/filebeat -n monitoring -f helm-charts/filebeat/values.yaml

# Terraform을 통한 업그레이드
cd terraform
terraform plan -var-file="monitoring.tfvars"
terraform apply -var-file="monitoring.tfvars"
```

### 삭제
```bash
# Helm을 통한 삭제
helm uninstall filebeat -n monitoring
helm uninstall logstash -n monitoring
helm uninstall kibana -n monitoring
helm uninstall loventure-elk-master -n monitoring

# Terraform을 통한 삭제
cd terraform
terraform destroy -var-file="monitoring.tfvars"
```

## 🔍 문제 해결

### 일반적인 문제들

#### 1. Elasticsearch 클러스터 상태가 YELLOW인 경우
- **원인**: 단일 노드 클러스터에서는 정상적인 상태
- **해결**: 무시해도 됨 (복제본이 없어서 YELLOW 상태)

#### 2. Logstash 파이프라인 오류
- **원인**: 템플릿 설정 오류
- **해결**: `logstash-templates` ConfigMap 확인
```bash
kubectl get configmap logstash-templates -n monitoring
```

#### 3. Filebeat가 Ready 상태가 아닌 경우
- **원인**: 정상적인 상태 (DaemonSet 특성상 0/1 Ready)
- **해결**: 로그 수집이 정상적으로 작동하면 문제없음

### 로그 확인 명령어
```bash
# Elasticsearch 클러스터 상태
kubectl exec -n monitoring loventure-elk-master-0 -- curl -k -u "elastic:$(kubectl get secret loventure-elk-master -n monitoring -o jsonpath='{.data.elastic}' | base64 -d)" "https://127.0.0.1:9200/_cluster/health"

# Logstash 파이프라인 상태
kubectl exec -n monitoring logstash-logstash-0 -- curl "http://127.0.0.1:9600/_node/stats/pipelines"

# Kibana 상태
kubectl exec -n monitoring kibana-kibana-6d64c95589-fmqt7 -- curl "http://127.0.0.1:5601/api/status"
```

## 🚀 성능 최적화

### 리소스 튜닝
- **Elasticsearch**: JVM 힙 크기 조정 (`ES_JAVA_OPTS`)
- **Logstash**: 파이프라인 워커 수 조정 (`pipeline.workers`)
- **Filebeat**: 배치 크기 조정 (`queue.mem.events`)

### 스토리지 최적화
- **인덱스 라이프사이클 관리**: ILM 정책 설정
- **로그 보존 기간**: 30일 기본 설정
- **압축**: `index.codec: best_compression` 사용

## 📚 추가 문서

- [Terraform 배포 가이드](terraform/README.md)
- [모니터링 가이드](docs/monitoring-guide.md)
- [로그 파싱 규칙](helm-charts/logstash/values.yaml)
- [대시보드 설정](helm-charts/monitoring/dashboards/)

## 🤝 기여하기

1. 이슈 생성 또는 기존 이슈 확인
2. Fork 후 브랜치 생성
3. 변경사항 커밋 및 푸시
4. Pull Request 생성

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.