# 🚀 ELK Stack 단계별 배포 가이드

이 가이드는 ELK 스택을 단계별로 안전하게 배포하는 방법을 설명합니다.

## 📋 배포 순서

### 1단계: 기본 인프라 (네임스페이스)
```bash
# 네임스페이스 생성
terraform apply -target=kubernetes_namespace.monitoring -var-file="monitoring.tfvars"

# 확인
kubectl get namespace monitoring
```

### 2단계: Elasticsearch 배포
```bash
# Elasticsearch 배포
terraform apply -target=helm_release.elasticsearch -var-file="monitoring.tfvars"

# 상태 확인 (약 5-10분 소요)
kubectl get pods -n monitoring -w

# Elasticsearch가 Ready 상태가 될 때까지 대기
kubectl wait --for=condition=ready pod -l app=loventure-elk-master -n monitoring --timeout=600s

# 헬스체크
kubectl port-forward svc/elasticsearch-master 9200:9200 -n monitoring &
curl http://localhost:9200/_cluster/health
```

### 3단계: Logstash 배포
```bash
# Logstash 배포
terraform apply -target=helm_release.logstash -var-file="monitoring.tfvars"

# 상태 확인
kubectl get pods -n monitoring -l app=logstash-logstash

# 로그 확인
kubectl logs -f deployment/logstash-logstash -n monitoring
```

### 4단계: Kibana 배포
```bash
# Kibana 배포
terraform apply -target=helm_release.kibana -var-file="monitoring.tfvars"

# 상태 확인
kubectl get pods -n monitoring -l app=kibana-kibana

# Ingress 확인
kubectl get ingress -n monitoring

# 접근 테스트
kubectl port-forward svc/kibana-kibana 5601:5601 -n monitoring &
# 브라우저에서 http://localhost:5601 접속
```

### 5단계: Filebeat 배포
```bash
# Filebeat 배포
terraform apply -target=helm_release.filebeat -var-file="monitoring.tfvars"

# 상태 확인
kubectl get pods -n monitoring -l app=filebeat

# 로그 확인
kubectl logs -f daemonset/filebeat -n monitoring
```

## 🔍 각 단계별 확인 사항

### 1단계 확인
```bash
kubectl get namespace monitoring
# NAME        STATUS   AGE
# monitoring  Active   1m
```

### 2단계 확인
```bash
kubectl get pods -n monitoring
# NAME                     READY   STATUS    RESTARTS   AGE
# loventure-elk-master-0   1/1     Running   0          5m

# Elasticsearch 헬스체크
kubectl port-forward svc/elasticsearch-master 9200:9200 -n monitoring &
curl http://localhost:9200/_cluster/health
# {"cluster_name":"loventure-elk","status":"green",...}
```

### 3단계 확인
```bash
kubectl get pods -n monitoring -l app=logstash-logstash
# NAME                     READY   STATUS    RESTARTS   AGE
# logstash-logstash-0      1/1     Running   0          3m

# Logstash 헬스체크
kubectl port-forward svc/logstash-logstash 9600:9600 -n monitoring &
curl http://localhost:9600/_node/stats
```

### 4단계 확인
```bash
kubectl get pods -n monitoring -l app=kibana-kibana
# NAME                     READY   STATUS    RESTARTS   AGE
# kibana-kibana-0          1/1     Running   0          2m

kubectl get ingress -n monitoring
# NAME             CLASS   HOSTS                ADDRESS   PORTS     AGE
# kibana-kibana    nginx   kibana.loventure.us            80, 443   2m
```

### 5단계 확인
```bash
kubectl get pods -n monitoring -l app=filebeat
# NAME                     READY   STATUS    RESTARTS   AGE
# filebeat-abc123          1/1     Running   0          1m
# filebeat-def456          1/1     Running   0          1m

# 로그 수집 확인
kubectl logs -f daemonset/filebeat -n monitoring | grep "loventure"
```

## 🚨 문제 해결

### Elasticsearch가 시작되지 않는 경우
```bash
# Pod 상태 확인
kubectl describe pod loventure-elk-master-0 -n monitoring

# 로그 확인
kubectl logs loventure-elk-master-0 -n monitoring

# PVC 확인
kubectl get pvc -n monitoring

# 스토리지 클래스 확인
kubectl get storageclass
```

### Logstash가 Elasticsearch에 연결되지 않는 경우
```bash
# 네트워크 연결 확인
kubectl exec -it logstash-logstash-0 -n monitoring -- nslookup elasticsearch-master.monitoring.svc.cluster.local

# Elasticsearch 연결 테스트
kubectl exec -it logstash-logstash-0 -n monitoring -- curl http://elasticsearch-master.monitoring.svc.cluster.local:9200/_cluster/health
```

### Kibana가 Elasticsearch에 연결되지 않는 경우
```bash
# Kibana 로그 확인
kubectl logs kibana-kibana-0 -n monitoring

# Elasticsearch 연결 확인
kubectl exec -it kibana-kibana-0 -n monitoring -- curl http://elasticsearch-master.monitoring.svc.cluster.local:9200/_cluster/health
```

## 🔄 롤백 방법

### 특정 단계 롤백
```bash
# Filebeat 제거
terraform destroy -target=helm_release.filebeat -var-file="monitoring.tfvars"

# Kibana 제거
terraform destroy -target=helm_release.kibana -var-file="monitoring.tfvars"

# Logstash 제거
terraform destroy -target=helm_release.logstash -var-file="monitoring.tfvars"

# Elasticsearch 제거
terraform destroy -target=helm_release.elasticsearch -var-file="monitoring.tfvars"

# 네임스페이스 제거
terraform destroy -target=kubernetes_namespace.monitoring -var-file="monitoring.tfvars"
```

### 전체 롤백
```bash
terraform destroy -var-file="monitoring.tfvars"
```

## 📊 모니터링 명령어

```bash
# 전체 상태 확인
kubectl get all -n monitoring

# 리소스 사용량 확인
kubectl top pods -n monitoring

# 로그 확인
kubectl logs -f deployment/elasticsearch-master -n monitoring
kubectl logs -f deployment/logstash-logstash -n monitoring
kubectl logs -f deployment/kibana-kibana -n monitoring
kubectl logs -f daemonset/filebeat -n monitoring

# 이벤트 확인
kubectl get events -n monitoring --sort-by='.lastTimestamp'
```

## ⚡ 빠른 배포 (전체 한번에)

모든 단계를 한번에 배포하려면:
```bash
terraform apply -var-file="monitoring.tfvars"
```

하지만 문제 발생 시 디버깅이 어려우므로, 단계별 배포를 권장합니다.
