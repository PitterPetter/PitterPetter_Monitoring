# 1단계: 기본 인프라 (네임스페이스)
# 이 파일을 먼저 적용: terraform apply -target=kubernetes_namespace.monitoring

# Google Cloud 클라이언트 설정
data "google_client_config" "current" {}

# GKE 클러스터 정보 가져오기
data "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.cluster_location
  project  = var.project_id
}

# Kubernetes 네임스페이스 생성
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
      app  = "monitoring"
    }
  }
}
