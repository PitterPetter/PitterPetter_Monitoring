# 5단계: Filebeat 배포
# 이 파일을 적용: terraform apply -target=helm_release.filebeat

# Filebeat 배포
resource "helm_release" "filebeat" {
  name       = "filebeat"
  repository = "https://helm.elastic.co"
  chart      = "filebeat"
  version    = var.filebeat_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  timeout    = 300  # 5분

  values = [
    file("${path.module}/../helm-charts/filebeat/values.yaml")
  ]

  depends_on = [helm_release.logstash]
}
