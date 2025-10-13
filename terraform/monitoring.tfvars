# ELK Stack Terraform Variables
# 실제 배포용 설정 파일

# GKE 클러스터 설정
cluster_name     = "pitterpetter-dev-cluster"
cluster_location = "asia-northeast3-b"
project_id       = "pitterpetter"

# Kubernetes 설정
namespace   = "monitoring"
environment = "development"

# ELK Stack 버전 (7.x 버전으로 다운그레이드 - 보안 비활성화로 간단한 설정)
elasticsearch_version = "7.17.3"
kibana_version       = "7.17.3"
logstash_version     = "7.17.3"
filebeat_version     = "7.17.3"

# 도메인 설정
kibana_domain       = "kibana.loventure.us"
elasticsearch_domain = "loventure-elk-master.monitoring.svc.cluster.local"

# 리소스 설정
elasticsearch_resources = {
  requests = {
    cpu    = "1000m"
    memory = "2Gi"
  }
  limits = {
    cpu    = "2000m"
    memory = "4Gi"
  }
}

kibana_resources = {
  requests = {
    cpu    = "500m"
    memory = "1Gi"
  }
  limits = {
    cpu    = "1000m"
    memory = "2Gi"
  }
}

logstash_resources = {
  requests = {
    cpu    = "500m"
    memory = "1Gi"
  }
  limits = {
    cpu    = "1000m"
    memory = "2Gi"
  }
}

filebeat_resources = {
  requests = {
    cpu    = "100m"
    memory = "200Mi"
  }
  limits = {
    cpu    = "200m"
    memory = "400Mi"
  }
}

# 스토리지 설정
elasticsearch_storage_class_name = "standard-rwo"
elasticsearch_storage_size       = "20Gi"

# Kibana Ingress TLS Secret 이름
kibana_ingress_tls_secret_name = "loventure-tls-secret"

# Elasticsearch CORS 허용 오리진
elasticsearch_cors_allow_origin = "https://loventure.us, https://api.loventure.us, https://kibana.loventure.us"
