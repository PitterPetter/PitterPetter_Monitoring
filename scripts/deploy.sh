#!/bin/bash

# PitterPetter ELK Stack 배포 스크립트
# 사용법: ./deploy.sh [environment]
# 환경: dev, prod (기본값: dev)

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 환경 설정
ENVIRONMENT=${1:-dev}
NAMESPACE="monitoring"
CHART_VERSION="7.17.3"

# 환경별 설정
if [ "$ENVIRONMENT" = "prod" ]; then
    TFVARS_FILE="prod.tfvars"
    KIBANA_DOMAIN="kibana-prod.loventure.us"
    PROJECT_ID="pitterpetter-2"
    CLUSTER_NAME="pitterpetter-prod-cluster"
    NODE_POOL_NAME="pitterpetter-pro-nodes"
else
    TFVARS_FILE="dev.tfvars"
    KIBANA_DOMAIN="kibana.loventure.us"
    PROJECT_ID="pitterpetter"
    CLUSTER_NAME="pitterpetter-dev-cluster"
    NODE_POOL_NAME="pitterpetter-nodes"
fi

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 사전 요구사항 확인
check_prerequisites() {
    log_info "사전 요구사항 확인 중..."
    
    # kubectl 확인
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl이 설치되지 않았습니다."
        exit 1
    fi
    
    # helm 확인
    if ! command -v helm &> /dev/null; then
        log_error "helm이 설치되지 않았습니다."
        exit 1
    fi
    
    # terraform 확인
    if ! command -v terraform &> /dev/null; then
        log_error "terraform이 설치되지 않았습니다."
        exit 1
    fi
    
    # Kubernetes 클러스터 연결 확인
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Kubernetes 클러스터에 연결할 수 없습니다."
        exit 1
    fi
    
    # tfvars 파일 확인
    if [ ! -f "terraform/$TFVARS_FILE" ]; then
        log_error "Terraform 변수 파일을 찾을 수 없습니다: terraform/$TFVARS_FILE"
        exit 1
    fi
    
    log_success "사전 요구사항 확인 완료"
}

# Helm repository 추가
add_helm_repos() {
    log_info "Helm repository 추가 중..."
    
    helm repo add elastic https://helm.elastic.co
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    
    log_success "Helm repository 추가 완료"
}

# 네임스페이스 확인
check_namespace() {
    log_info "네임스페이스 확인 중..."
    
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        log_success "네임스페이스 $NAMESPACE가 존재합니다."
    else
        log_error "네임스페이스 $NAMESPACE가 존재하지 않습니다. 먼저 애플리케이션을 배포해주세요."
        exit 1
    fi
}

# Terraform 배포
deploy_with_terraform() {
    log_info "Terraform으로 ELK Stack 배포 중..."
    
    cd terraform
    
    # Terraform 초기화
    log_info "Terraform 초기화 중..."
    terraform init
    
    # Terraform 계획
    log_info "Terraform 계획 생성 중..."
    terraform plan -var-file="$TFVARS_FILE"
    
    # Terraform 적용
    log_info "Terraform 적용 중..."
    terraform apply -var-file="$TFVARS_FILE" -auto-approve
    
    cd ..
    
    log_success "Terraform 배포 완료"
}

# 배포 상태 확인
check_deployment_status() {
    log_info "배포 상태 확인 중..."
    
    echo ""
    echo "=== Pod 상태 ==="
    kubectl get pods -n $NAMESPACE
    
    echo ""
    echo "=== 서비스 상태 ==="
    kubectl get svc -n $NAMESPACE
    
    echo ""
    echo "=== Ingress 상태 ==="
    kubectl get ingress -n $NAMESPACE
    
    echo ""
    echo "=== Helm 릴리스 상태 ==="
    helm list -n $NAMESPACE
}

# 접근 정보 출력
show_access_info() {
    log_info "접근 정보:"
    
    echo ""
    echo "=== Kibana 접근 ==="
    echo "URL: https://$KIBANA_DOMAIN"
    echo "대기 시간: 2-3분 (초기 설정 완료 후)"
    
    echo ""
    echo "=== Elasticsearch 접근 ==="
    echo "내부 URL: http://loventure-elk-master.$NAMESPACE.svc.cluster.local:9200"
    echo "포트 포워딩: kubectl port-forward svc/loventure-elk-master 9200:9200 -n $NAMESPACE"
    
    echo ""
    echo "=== 로그 확인 ==="
    echo "Elasticsearch: kubectl logs -f statefulset/loventure-elk-master -n $NAMESPACE"
    echo "Kibana: kubectl logs -f deployment/kibana-kibana -n $NAMESPACE"
    echo "Logstash: kubectl logs -f deployment/logstash-logstash -n $NAMESPACE"
    echo "Filebeat: kubectl logs -f daemonset/filebeat -n $NAMESPACE"
}

# 메인 실행 함수
main() {
    log_info "PitterPetter ELK Stack 배포 시작 (환경: $ENVIRONMENT)"
    log_info "사용할 설정: $TFVARS_FILE"
    
    check_prerequisites
    add_helm_repos
    check_namespace
    
    # Terraform으로 배포
    deploy_with_terraform
    
    check_deployment_status
    show_access_info
    
    log_success "ELK Stack 배포 완료!"
    log_info "Kibana에 접속하여 대시보드를 확인하세요: https://$KIBANA_DOMAIN"
}

# 스크립트 실행
main "$@"
