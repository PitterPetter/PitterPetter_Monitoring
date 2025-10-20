# 2단계: Elasticsearch 배포
# 이 파일을 적용: terraform apply -target=helm_release.elasticsearch

# Elasticsearch 배포
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = var.elasticsearch_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    templatefile("${path.module}/../helm-charts/elasticsearch/values.yaml", {
      NODE_POOL_NAME = var.node_pool_name
    })
  ]

  # values.yaml 파일을 사용하므로 set 구문 제거

  depends_on = [kubernetes_namespace.monitoring]
}
