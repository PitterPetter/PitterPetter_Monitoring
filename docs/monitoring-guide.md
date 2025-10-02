# PitterPetter ELK Stack 모니터링 가이드

## 📊 개요

이 가이드는 PitterPetter 애플리케이션의 로그 모니터링을 위한 ELK Stack 사용법을 설명합니다.

## 🚀 빠른 시작

### 1. ELK Stack 배포

```bash
# 배포 스크립트 실행
./scripts/deploy.sh

# 또는 수동 배포
kubectl create namespace elk-stack
helm repo add elastic https://helm.elastic.co
helm repo update

# Elasticsearch 배포
helm install elasticsearch elastic/elasticsearch -n elk-stack -f helm-charts/elasticsearch/values.yaml

# Kibana 배포
helm install kibana elastic/kibana -n elk-stack -f helm-charts/kibana/values.yaml

# Logstash 배포
helm install logstash elastic/logstash -n elk-stack -f helm-charts/logstash/values.yaml

# Filebeat 배포
helm install filebeat elastic/filebeat -n elk-stack -f helm-charts/filebeat/values.yaml
```

### 2. Kibana 접속

- **URL**: https://kibana.loventure.us
- **대기 시간**: 배포 후 2-3분
- **초기 설정**: Index Pattern 생성 필요

## 📈 모니터링 대시보드

### 1. 애플리케이션 대시보드

**접근 방법**: Kibana → Dashboard → "PitterPetter Application Overview"

**주요 지표**:
- 서비스별 로그 볼륨
- 에러율 추이
- 로그 타임라인
- 서비스별 성능 지표

### 2. 인프라 대시보드

**접근 방법**: Kibana → Dashboard → "PitterPetter Infrastructure Overview"

**주요 지표**:
- Pod 상태 분포
- 시스템 로그 타임라인
- Kubernetes 이벤트
- 리소스 사용률

## 🔍 로그 검색

### 1. 기본 검색

```kql
# 모든 로그
*

# 특정 서비스 로그
service: "auth-service"

# 에러 로그만
level: "ERROR"

# 특정 시간 범위
@timestamp >= "now-1h"

# 복합 검색
service: "auth-service" AND level: "ERROR"
```

### 2. 고급 검색

```kql
# API 응답 시간 분석
service: "auth-service" AND log_message: "*response time*"

# 데이터베이스 연결 오류
service: "postgresql" AND log_message: "*connection*"

# Kubernetes 이벤트
service: "kubernetes-events" AND kubernetes.event.reason: "Failed"

# 특정 사용자 활동
log_message: "*user_id:12345*"
```

## 📊 시각화 생성

### 1. 새로운 시각화 생성

1. Kibana → Visualize Library → Create visualization
2. Lens 선택
3. Index Pattern: "pitterpetter-logs-*" 선택
4. 원하는 차트 타입 선택

### 2. 유용한 시각화 예시

#### 로그 볼륨 추이
- **타입**: Line chart
- **X축**: @timestamp (Date histogram)
- **Y축**: Count
- **Split by**: service.keyword

#### 에러율 분포
- **타입**: Pie chart
- **Metric**: Count
- **Buckets**: service.keyword
- **Filter**: level: "ERROR"

#### 응답 시간 분석
- **타입**: Histogram
- **Field**: response_time (numeric)
- **Interval**: 100ms

## 🚨 알림 설정

### 1. Watcher 설정

```json
{
  "trigger": {
    "schedule": {
      "interval": "1m"
    }
  },
  "input": {
    "search": {
      "request": {
        "search_type": "query_then_fetch",
        "indices": ["pitterpetter-logs-*"],
        "body": {
          "query": {
            "bool": {
              "must": [
                {
                  "range": {
                    "@timestamp": {
                      "gte": "now-1m"
                    }
                  }
                },
                {
                  "term": {
                    "level": "ERROR"
                  }
                }
              ]
            }
          }
        }
      }
    }
  },
  "condition": {
    "compare": {
      "ctx.payload.hits.total": {
        "gt": 10
      }
    }
  },
  "actions": {
    "send_email": {
      "email": {
        "to": "admin@loventure.us",
        "subject": "PitterPetter Error Alert",
        "body": "High error rate detected: {{ctx.payload.hits.total}} errors in the last minute"
      }
    }
  }
}
```

## 🔧 유지보수

### 1. 로그 인덱스 관리

```bash
# 인덱스 목록 확인
curl -X GET "elasticsearch-master.elk-stack.svc.cluster.local:9200/_cat/indices?v"

# 오래된 인덱스 삭제 (30일 이상)
curl -X DELETE "elasticsearch-master.elk-stack.svc.cluster.local:9200/pitterpetter-logs-2024.01.*"
```

### 2. 성능 최적화

#### Elasticsearch 설정
```yaml
# helm-charts/elasticsearch/values.yaml
esConfig:
  elasticsearch.yml: |
    # 인덱스 설정
    index.number_of_shards: 1
    index.number_of_replicas: 0
    index.refresh_interval: 30s
    
    # 메모리 설정
    indices.memory.index_buffer_size: 20%
    indices.queries.cache.size: 10%
```

#### Logstash 설정
```yaml
# helm-charts/logstash/values.yaml
logstashConfig:
  logstash.yml: |
    pipeline.workers: 2
    pipeline.batch.size: 1000
    pipeline.batch.delay: 50
```

### 3. 백업 및 복구

#### 스냅샷 생성
```bash
# 스냅샷 저장소 등록
curl -X PUT "elasticsearch-master.elk-stack.svc.cluster.local:9200/_snapshot/backup_repo" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/backup"
  }
}'

# 스냅샷 생성
curl -X PUT "elasticsearch-master.elk-stack.svc.cluster.local:9200/_snapshot/backup_repo/snapshot_1" -H 'Content-Type: application/json' -d'
{
  "indices": "pitterpetter-logs-*",
  "ignore_unavailable": true,
  "include_global_state": false
}'
```

## 🐛 문제 해결

### 1. 일반적인 문제

#### Kibana 접속 불가
```bash
# Pod 상태 확인
kubectl get pods -n elk-stack

# 로그 확인
kubectl logs -f deployment/kibana-kibana -n elk-stack

# 서비스 확인
kubectl get svc -n elk-stack
```

#### 로그 수집 안됨
```bash
# Filebeat 상태 확인
kubectl get daemonset -n elk-stack

# Filebeat 로그 확인
kubectl logs -f daemonset/filebeat -n elk-stack

# Logstash 상태 확인
kubectl logs -f deployment/logstash-logstash -n elk-stack
```

#### Elasticsearch 메모리 부족
```bash
# 리소스 사용량 확인
kubectl top pods -n elk-stack

# 메모리 제한 증가
helm upgrade elasticsearch elastic/elasticsearch -n elk-stack -f helm-charts/elasticsearch/values.yaml
```

### 2. 로그 레벨 조정

```bash
# Filebeat 로그 레벨 변경
kubectl edit configmap filebeat-config -n elk-stack

# Logstash 로그 레벨 변경
kubectl edit configmap logstash-config -n elk-stack
```

## 📚 추가 리소스

- [Elasticsearch 공식 문서](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Kibana 사용자 가이드](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Logstash 설정 가이드](https://www.elastic.co/guide/en/logstash/current/index.html)
- [Filebeat 설정 가이드](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
