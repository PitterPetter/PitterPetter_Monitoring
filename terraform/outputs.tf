# 클러스터 정보
output "cluster_name" {
  description = "GKE 클러스터 이름"
  value       = data.google_container_cluster.main.name
}

output "cluster_location" {
  description = "GKE 클러스터 위치"
  value       = data.google_container_cluster.main.location
}

output "cluster_endpoint" {
  description = "GKE 클러스터 엔드포인트"
  value       = data.google_container_cluster.main.endpoint
}

# 네임스페이스
output "namespace" {
  description = "Kubernetes 네임스페이스"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

# Elasticsearch 정보
output "elasticsearch_url" {
  description = "Elasticsearch 내부 URL"
  value       = "http://${var.elasticsearch_domain}:9200"
}

output "elasticsearch_external_url" {
  description = "Elasticsearch 외부 접근 명령어"
  value       = "kubectl port-forward svc/elasticsearch-master 9200:9200 -n ${kubernetes_namespace.monitoring.metadata[0].name}"
}

output "elasticsearch_release" {
  description = "Elasticsearch Helm release 정보"
  value = {
    name      = helm_release.elasticsearch.name
    namespace = helm_release.elasticsearch.namespace
    status    = helm_release.elasticsearch.status
    version   = helm_release.elasticsearch.version
  }
}

# Kibana 정보
output "kibana_url" {
  description = "Kibana URL"
  value       = "https://${var.kibana_domain}"
}

output "kibana_release" {
  description = "Kibana Helm release 정보"
  value = {
    name      = helm_release.kibana.name
    namespace = helm_release.kibana.namespace
    status    = helm_release.kibana.status
    version   = helm_release.kibana.version
  }
}

# Logstash 정보
output "logstash_release" {
  description = "Logstash Helm release 정보"
  value = {
    name      = helm_release.logstash.name
    namespace = helm_release.logstash.namespace
    status    = helm_release.logstash.status
    version   = helm_release.logstash.version
  }
}

# Filebeat 정보
output "filebeat_release" {
  description = "Filebeat Helm release 정보"
  value = {
    name      = helm_release.filebeat.name
    namespace = helm_release.filebeat.namespace
    status    = helm_release.filebeat.status
    version   = helm_release.filebeat.version
  }
}

# 모니터링 아키텍처
output "monitoring_architecture" {
  description = "모니터링 아키텍처"
  value = {
    log_collection   = "Filebeat"
    log_processing   = "Logstash"
    log_storage      = "Elasticsearch"
    logs_analysis    = "ELK Stack (Kibana)"
    metrics_analysis = "GMP (Google Cloud Console)"
  }
}

# 로그 수집 서비스
output "log_collection_services" {
  description = "로그 수집 대상 서비스"
  value = [
    "loventure-prod-ai-service",
    "loventure-prod-auth-service",
    "loventure-prod-content-service",
    "loventure-prod-course-service",
    "loventure-prod-gateway",
  ]
}

# 로그 인덱스 패턴
output "log_index_pattern" {
  description = "로그 인덱스 패턴"
  value       = "loventure-logs-*"
}

# 유용한 명령어들
output "deployment_commands" {
  description = "유용한 배포 명령어들"
  value = {
    check_pods         = "kubectl get pods -n ${kubernetes_namespace.monitoring.metadata[0].name}"
    check_svcs         = "kubectl get svc -n ${kubernetes_namespace.monitoring.metadata[0].name}"
    check_ingress      = "kubectl get ingress -n ${kubernetes_namespace.monitoring.metadata[0].name}"
    elasticsearch_logs = "kubectl logs -f deployment/elasticsearch-master -n ${kubernetes_namespace.monitoring.metadata[0].name}"
    kibana_logs        = "kubectl logs -f deployment/kibana-kibana -n ${kubernetes_namespace.monitoring.metadata[0].name}"
    logstash_logs      = "kubectl logs -f deployment/logstash-logstash -n ${kubernetes_namespace.monitoring.metadata[0].name}"
    filebeat_logs      = "kubectl logs -f daemonset/filebeat -n ${kubernetes_namespace.monitoring.metadata[0].name}"
  }
}
