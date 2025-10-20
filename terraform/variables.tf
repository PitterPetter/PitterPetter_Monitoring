# GKE 클러스터 설정
variable "cluster_name" {
  description = "GKE 클러스터 이름"
  type        = string
}

variable "cluster_location" {
  description = "GKE 클러스터 위치"
  type        = string
}

variable "project_id" {
  description = "Google Cloud 프로젝트 ID"
  type        = string
}

# Kubernetes 설정
variable "namespace" {
  description = "Kubernetes 네임스페이스"
  type        = string
}

variable "environment" {
  description = "환경 (development, staging, production)"
  type        = string
}

# ELK Stack 버전
variable "elasticsearch_version" {
  description = "Elasticsearch Helm chart 버전"
  type        = string
  default     = "8.5.1"
}

variable "kibana_version" {
  description = "Kibana Helm chart 버전"
  type        = string
  default     = "8.5.1"
}

variable "logstash_version" {
  description = "Logstash Helm chart 버전"
  type        = string
  default     = "8.5.1"
}

variable "filebeat_version" {
  description = "Filebeat Helm chart 버전"
  type        = string
  default     = "8.5.1"
}

# 도메인 설정
variable "kibana_domain" {
  description = "Kibana 도메인"
  type        = string
}

variable "elasticsearch_domain" {
  description = "Elasticsearch 내부 도메인"
  type        = string
}

# 리소스 설정
variable "elasticsearch_resources" {
  description = "Elasticsearch 리소스 설정"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "1000m"
      memory = "2Gi"
    }
    limits = {
      cpu    = "2000m"
      memory = "4Gi"
    }
  }
}

variable "kibana_resources" {
  description = "Kibana 리소스 설정"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "500m"
      memory = "1Gi"
    }
    limits = {
      cpu    = "1000m"
      memory = "2Gi"
    }
  }
}

variable "logstash_resources" {
  description = "Logstash 리소스 설정"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "500m"
      memory = "1Gi"
    }
    limits = {
      cpu    = "1000m"
      memory = "2Gi"
    }
  }
}

variable "filebeat_resources" {
  description = "Filebeat 리소스 설정"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "100m"
      memory = "200Mi"
    }
    limits = {
      cpu    = "200m"
      memory = "400Mi"
    }
  }
}

# 스토리지 설정
variable "elasticsearch_storage_class_name" {
  description = "Elasticsearch StorageClass 이름"
  type        = string
  default     = "standard-rwo"
}

variable "elasticsearch_storage_size" {
  description = "Elasticsearch 스토리지 크기"
  type        = string
  default     = "20Gi"
}

# Kibana Ingress TLS Secret 이름
variable "kibana_ingress_tls_secret_name" {
  description = "Kibana Ingress TLS Secret 이름"
  type        = string
}

# Elasticsearch CORS 허용 오리진
variable "elasticsearch_cors_allow_origin" {
  description = "Elasticsearch CORS 허용 오리진"
  type        = string
}

# 노드풀 설정
variable "node_pool_name" {
  description = "GKE 노드풀 이름"
  type        = string
}

# 클러스터 설정
variable "cluster_config" {
  description = "클러스터 설정"
  type = object({
    cluster_name = string
    environment  = string
  })
}