# 7단계: Ingress 배포 (HTTP 모드)
# 이 파일을 적용: terraform apply -target=kubernetes_ingress_v1.kibana_ingress

# Kibana Ingress (HTTP 모드)
resource "kubernetes_ingress_v1" "kibana_ingress" {
  metadata {
    name      = "kibana-ingress"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "nginx.ingress.kubernetes.io/cors-allow-origin" = "https://loventure.us, https://api.loventure.us, https://argo.loventure.us"
      "nginx.ingress.kubernetes.io/enable-cors"   = "true"
      "nginx.ingress.kubernetes.io/load-balancer-ip" = "34.22.65.113"
      "nginx.ingress.kubernetes.io/ssl-redirect"  = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }

  spec {
    tls {
      hosts       = [var.kibana_domain]
      secret_name = "pitterpetter-ssl"
    }

    rule {
      host = var.kibana_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kibana-kibana"
              port {
                number = 5601
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.kibana]
}
