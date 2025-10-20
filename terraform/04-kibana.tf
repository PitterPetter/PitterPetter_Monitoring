# 4단계: Kibana 배포
# 이 파일을 적용: terraform apply -target=helm_release.kibana

# Kibana 배포
resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = var.kibana_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  timeout    = 300  # 5분

  values = [
    templatefile("${path.module}/../helm-charts/kibana/values.yaml", {
      NODE_POOL_NAME = var.node_pool_name
    })
  ]

  # 보안 설정 완전 비활성화
  set {
    name  = "elasticsearch.security.enabled"
    value = "false"
  }

  set {
    name  = "secret.enabled"
    value = "false"
  }

  set {
    name  = "tls.enabled"
    value = "false"
  }

  set {
    name  = "elasticsearch.ssl.enabled"
    value = "false"
  }

  set {
    name  = "elasticsearch.ssl.verificationMode"
    value = "none"
  }

  # Elasticsearch 호스트 설정
  set {
    name  = "elasticsearchHosts"
    value = "http://loventure-elk-master:9200"
  }

  # Kibana 공개 URL 설정 (경고 해결)
  set {
    name  = "kibanaConfig.kibana\\.yml"
    value = "server.name: kibana\nserver.host: \"0.0.0.0\"\nserver.port: 5601\nserver.publicBaseUrl: \"https://kibana.loventure.us\"\nelasticsearch.hosts: [\"http://loventure-elk-master:9200\"]\nelasticsearch.requestTimeout: 30000\nelasticsearch.shardTimeout: 30000\nelasticsearch.pingTimeout: 30000"
  }

  # 리소스 설정 (변수에서 가져오기)
  set {
    name  = "resources.requests.cpu"
    value = var.kibana_resources.requests.cpu
  }

  set {
    name  = "resources.requests.memory"
    value = var.kibana_resources.requests.memory
  }

  set {
    name  = "resources.limits.cpu"
    value = var.kibana_resources.limits.cpu
  }

  set {
    name  = "resources.limits.memory"
    value = var.kibana_resources.limits.memory
  }

  # 복제본 수
  set {
    name  = "replicas"
    value = "1"
  }

  # 서비스 설정
  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "service.ports.http"
    value = "5601"
  }

  # 노드 선택자
  set {
    name  = "nodeSelector.cloud\\.google\\.com/gke-nodepool"
    value = var.node_pool_name
  }

  depends_on = [helm_release.elasticsearch]
}
