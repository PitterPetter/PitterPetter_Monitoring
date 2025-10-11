# ELK Stack Terraform 배포

이 디렉토리는 Terraform을 사용하여 ELK 스택을 GKE 클러스터에 배포하는 설정을 포함합니다.

## 📁 파일 구조

```
terraform/
├── main.tf              # 메인 Terraform 설정
├── variables.tf         # 변수 정의
├── outputs.tf           # 출력 값 정의
├── versions.tf          # Provider 버전 정의
├── monitoring.tfvars    # 실제 배포용 변수 파일
└── README.md           # 이 파일
```

## 🚀 배포 방법

### 1. 사전 준비

```bash
# GKE 클러스터에 연결
gcloud container clusters get-credentials pitterpetter-dev-cluster --zone=asia-northeast3-b --project=pitterpetter

# Helm repository 추가
helm repo add elastic https://helm.elastic.co
helm repo update
```

### 2. Terraform 초기화

```bash
cd terraform
terraform init
```

### 3. 배포 계획 확인

```bash
terraform plan -var-file="monitoring.tfvars"
```

### 4. 배포 실행

```bash
terraform apply -var-file="monitoring.tfvars"
```

### 5. 배포 확인

```bash
# Pod 상태 확인
kubectl get pods -n monitoring

# 서비스 확인
kubectl get svc -n monitoring

# Ingress 확인
kubectl get ingress -n monitoring
```

## 🔧 설정 수정

### 변수 수정

`monitoring.tfvars` 파일을 수정하여 설정을 변경할 수 있습니다:

```hcl
# 리소스 설정 변경
elasticsearch_resources = {
  requests = {
    cpu    = "2000m"  # CPU 증가
    memory = "4Gi"    # 메모리 증가
  }
  limits = {
    cpu    = "4000m"
    memory = "8Gi"
  }
}

# 스토리지 크기 변경
elasticsearch_storage_size = "50Gi"
```

### Helm Chart Values 수정

`../helm-charts/` 디렉토리의 values.yaml 파일을 수정하여 더 세부적인 설정을 변경할 수 있습니다.

## 🗑️ 삭제

```bash
terraform destroy -var-file="monitoring.tfvars"
```

## 📊 모니터링

### 로그 확인

```bash
# Elasticsearch 로그
kubectl logs -f deployment/elasticsearch-master -n monitoring

# Kibana 로그
kubectl logs -f deployment/kibana-kibana -n monitoring

# Logstash 로그
kubectl logs -f deployment/logstash-logstash -n monitoring

# Filebeat 로그
kubectl logs -f daemonset/filebeat -n monitoring
```

### 서비스 접근

```bash
# Elasticsearch 내부 접근
kubectl port-forward svc/elasticsearch-master 9200:9200 -n monitoring

# Kibana 외부 접근
# https://kibana.loventure.us
```

## 🔍 문제 해결

### 일반적인 문제들

1. **Pod가 Pending 상태**
   ```bash
   kubectl describe pod <pod-name> -n monitoring
   ```

2. **StorageClass 문제**
   ```bash
   kubectl get storageclass
   ```

3. **리소스 부족**
   ```bash
   kubectl top nodes
   kubectl top pods -n monitoring
   ```

### 로그 분석

```bash
# 이벤트 확인
kubectl get events -n monitoring --sort-by='.lastTimestamp'

# Pod 상세 정보
kubectl describe pod <pod-name> -n monitoring
```

## 📝 참고사항

- 이 설정은 개발 환경용으로 최적화되어 있습니다.
- 프로덕션 환경에서는 보안 설정을 강화해야 합니다.
- 리소스 설정은 클러스터 크기에 따라 조정이 필요할 수 있습니다.
