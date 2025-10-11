# 3단계: Logstash 배포
# 이 파일을 적용: terraform apply -target=helm_release.logstash

# Logstash 배포
resource "helm_release" "logstash" {
  name       = "logstash"
  repository = "https://helm.elastic.co"
  chart      = "logstash"
  version    = var.logstash_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("${path.module}/../helm-charts/logstash/values.yaml")
  ]

  # values.yaml 파일을 사용하므로 set 구문 제거

  depends_on = [helm_release.elasticsearch]
}
