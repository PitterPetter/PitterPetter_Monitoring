#!/bin/bash

# PitterPetter ELK Stack 정리 스크립트
# 사용법: ./cleanup.sh [--force]

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 설정
NAMESPACE="elk-stack"
FORCE=false

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

# 사용법 출력
show_usage() {
    echo "사용법: $0 [--force]"
    echo ""
    echo "옵션:"
    echo "  --force    확인 없이 강제 삭제"
    echo ""
    echo "예시:"
    echo "  $0              # 확인 후 삭제"
    echo "  $0 --force      # 확인 없이 삭제"
}

# 확인 함수
confirm() {
    if [ "$FORCE" = true ]; then
        return 0
    fi
    
    read -p "정말로 ELK Stack을 삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        log_info "삭제가 취소되었습니다."
        exit 0
    fi
}

# Helm 릴리스 삭제
delete_helm_releases() {
    log_info "Helm 릴리스 삭제 중..."
    
    # Filebeat 삭제
    if helm list -n $NAMESPACE | grep -q filebeat; then
        log_info "Filebeat 삭제 중..."
        helm uninstall filebeat -n $NAMESPACE
        log_success "Filebeat 삭제 완료"
    fi
    
    # Logstash 삭제
    if helm list -n $NAMESPACE | grep -q logstash; then
        log_info "Logstash 삭제 중..."
        helm uninstall logstash -n $NAMESPACE
        log_success "Logstash 삭제 완료"
    fi
    
    # Kibana 삭제
    if helm list -n $NAMESPACE | grep -q kibana; then
        log_info "Kibana 삭제 중..."
        helm uninstall kibana -n $NAMESPACE
        log_success "Kibana 삭제 완료"
    fi
    
    # Elasticsearch 삭제
    if helm list -n $NAMESPACE | grep -q elasticsearch; then
        log_info "Elasticsearch 삭제 중..."
        helm uninstall elasticsearch -n $NAMESPACE
        log_success "Elasticsearch 삭제 완료"
    fi
}

# PVC 삭제
delete_pvcs() {
    log_info "PersistentVolumeClaims 삭제 중..."
    
    if kubectl get pvc -n $NAMESPACE --no-headers | wc -l | grep -q "0"; then
        log_info "삭제할 PVC가 없습니다."
    else
        kubectl delete pvc --all -n $NAMESPACE
        log_success "PVC 삭제 완료"
    fi
}

# 네임스페이스 삭제
delete_namespace() {
    log_info "네임스페이스 삭제 중..."
    
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        kubectl delete namespace $NAMESPACE
        log_success "네임스페이스 $NAMESPACE 삭제 완료"
    else
        log_warning "네임스페이스 $NAMESPACE가 존재하지 않습니다."
    fi
}

# 정리 상태 확인
check_cleanup_status() {
    log_info "정리 상태 확인 중..."
    
    echo ""
    echo "=== 네임스페이스 상태 ==="
    kubectl get namespace $NAMESPACE 2>/dev/null || echo "네임스페이스가 삭제되었습니다."
    
    echo ""
    echo "=== Helm 릴리스 상태 ==="
    helm list -n $NAMESPACE 2>/dev/null || echo "Helm 릴리스가 없습니다."
    
    echo ""
    echo "=== PVC 상태 ==="
    kubectl get pvc -n $NAMESPACE 2>/dev/null || echo "PVC가 없습니다."
}

# 메인 실행 함수
main() {
    # 인수 처리
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                FORCE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "알 수 없는 옵션: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    log_info "PitterPetter ELK Stack 정리 시작"
    
    # 네임스페이스 존재 확인
    if ! kubectl get namespace $NAMESPACE &> /dev/null; then
        log_warning "네임스페이스 $NAMESPACE가 존재하지 않습니다."
        exit 0
    fi
    
    confirm
    
    delete_helm_releases
    delete_pvcs
    delete_namespace
    
    check_cleanup_status
    
    log_success "ELK Stack 정리 완료!"
}

# 스크립트 실행
main "$@"
