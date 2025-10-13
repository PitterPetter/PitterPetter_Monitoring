#!/bin/bash

# PitterPetter ELK Stack 배포 스크립트
# 사용법: ./deploy.sh [environment]
# 환경: dev, staging, prod (기본값: dev)

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
    
    # Kubernetes 클러스터 연결 확인
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Kubernetes 클러스터에 연결할 수 없습니다."
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

# Elasticsearch 배포
deploy_elasticsearch() {
    log_info "Elasticsearch 배포 중..."
    
    helm upgrade --install elasticsearch elastic/elasticsearch \
        --namespace $NAMESPACE \
        --version $CHART_VERSION \
        --values helm-charts/elasticsearch/values.yaml \
        --wait \
        --timeout=10m
    
    log_success "Elasticsearch 배포 완료"
}

# Kibana 배포
deploy_kibana() {
    log_info "Kibana 배포 중..."
    
    helm upgrade --install kibana elastic/kibana \
        --namespace $NAMESPACE \
        --version $CHART_VERSION \
        --values helm-charts/kibana/values.yaml \
        --wait \
        --timeout=10m
    
    log_success "Kibana 배포 완료"
}

# Logstash 배포
deploy_logstash() {
    log_info "Logstash 배포 중..."
    
    helm upgrade --install logstash elastic/logstash \
        --namespace $NAMESPACE \
        --version $CHART_VERSION \
        --values helm-charts/logstash/values.yaml \
        --wait \
        --timeout=10m
    
    log_success "Logstash 배포 완료"
}

# Filebeat 배포
deploy_filebeat() {
    log_info "Filebeat 배포 중..."
    
    helm upgrade --install filebeat elastic/filebeat \
        --namespace $NAMESPACE \
        --version $CHART_VERSION \
        --values helm-charts/filebeat/values.yaml \
        --wait \
        --timeout=10m
    
    log_success "Filebeat 배포 완료"
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
    echo "URL: https://kibana.loventure.us"
    echo "대기 시간: 2-3분 (초기 설정 완료 후)"
    
    echo ""
    echo "=== Elasticsearch 접근 ==="
    echo "내부 URL: http://pitterpetter-elk-master.$NAMESPACE.svc.cluster.local:9200"
    echo "포트 포워딩: kubectl port-forward svc/pitterpetter-elk-master 9200:9200 -n $NAMESPACE"
    
    echo ""
    echo "=== 로그 확인 ==="
    echo "Elasticsearch: kubectl logs -f deployment/pitterpetter-elk-master -n $NAMESPACE"
    echo "Kibana: kubectl logs -f deployment/kibana-kibana -n $NAMESPACE"
    echo "Logstash: kubectl logs -f deployment/logstash-logstash -n $NAMESPACE"
    echo "Filebeat: kubectl logs -f daemonset/filebeat -n $NAMESPACE"
}

# 메인 실행 함수
main() {
    log_info "PitterPetter ELK Stack 배포 시작 (환경: $ENVIRONMENT)"
    
    check_prerequisites
    add_helm_repos
    check_namespace
    
    # 순차 배포 (의존성 고려)
    deploy_elasticsearch
    sleep 30  # Elasticsearch 초기화 대기
    
    deploy_kibana
    deploy_logstash
    deploy_filebeat
    
    check_deployment_status
    show_access_info
    
    log_success "ELK Stack 배포 완료!"
    log_info "Kibana에 접속하여 대시보드를 확인하세요: https://kibana.loventure.us"
}

# 스크립트 실행
main "$@"
