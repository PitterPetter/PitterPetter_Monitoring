# ELK Stack Terraform 배포

이 디렉토리는 Terraform을 사용하여 ELK 스택을 GKE 클러스터에 배포하는 설정을 포함합니다.

## 📁 파일 구조

```
terraform/
├── 01-namespace.tf      # 네임스페이스 생성
├── 02-elasticsearch.tf  # Elasticsearch 배포
├── 03-logstash.tf       # Logstash 배포
├── 04-kibana.tf         # Kibana 배포
├── 05-filebeat.tf       # Filebeat 배포
├── 06-ingress.tf        # Ingress 설정
├── variables.tf         # 변수 정의
├── outputs.tf           # 출력 값 정의
├── versions.tf          # Provider 버전 정의
├── dev.tfvars          # 개발환경 변수 파일
├── prod.tfvars         # 운영환경 변수 파일
└── README.md           # 이 파일
```

## 🚀 배포 방법

### 1. 사전 준비

```bash
# GKE 클러스터에 연결 (개발환경)
gcloud container clusters get-credentials pitterpetter-dev-cluster --zone=asia-northeast3-b --project=pitterpetter

# GKE 클러스터에 연결 (운영환경)
gcloud container clusters get-credentials pitterpetter-prod-cluster --zone=asia-northeast3-b --project=pitterpetter-2

# Helm repository 추가
helm repo add elastic https://helm.elastic.co
helm repo update
```

### 2. 자동 배포 (권장)

```bash
# 개발환경 배포
./scripts/deploy.sh dev

# 운영환경 배포
./scripts/deploy.sh prod
```

### 3. 수동 배포

```bash
cd terraform

# Terraform 초기화
terraform init

# 개발환경 배포
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"

# 운영환경 배포
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

## 🔧 환경별 설정

### 개발환경 (dev.tfvars)
- 프로젝트: `pitterpetter`
- 클러스터: `pitterpetter-dev-cluster`
- 도메인: `kibana.loventure.us`
- 리소스: 작은 크기

### 운영환경 (prod.tfvars)
- 프로젝트: `pitterpetter-2`
- 클러스터: `pitterpetter-prod-cluster`
- 도메인: `kibana-prod.loventure.us`
- 리소스: 큰 크기

## 🗑️ 삭제

```bash
# 개발환경 삭제
terraform destroy -var-file="dev.tfvars"

# 운영환경 삭제
terraform destroy -var-file="prod.tfvars"
```

## 📊 모니터링

### 로그 확인

```bash
# Elasticsearch 로그
kubectl logs -f statefulset/loventure-elk-master -n monitoring

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
kubectl port-forward svc/loventure-elk-master 9200:9200 -n monitoring

# Kibana 외부 접근
# 개발환경: https://kibana.loventure.us
# 운영환경: https://kibana-prod.loventure.us
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

- 환경별로 다른 설정 파일을 사용합니다.
- Helm Charts는 `templatefile()` 함수로 동적 값 주입됩니다.
- 리소스 설정은 환경에 따라 자동으로 조정됩니다.