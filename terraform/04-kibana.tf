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
    file("${path.module}/../helm-charts/kibana/values.yaml")
  ]

  depends_on = [helm_release.elasticsearch]
}
