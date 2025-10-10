# LoveVenture ELK Stack Monitoring

LoveVenture 프로젝트의 로그 모니터링을 위한 ELK Stack 배포 가이드

## 📋 개요

이 프로젝트는 LoveVenture 애플리케이션의 로그를 수집, 저장, 분석하기 위한 ELK Stack을 Helm을 사용하여 GKE에 배포합니다.

## 🏗️ 아키텍처

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │    Filebeat     │    │   Logstash      │
│   Services      │───▶│  (DaemonSet)    │───▶│  (Deployment)   │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Kibana      │◀───│  Elasticsearch  │◀───│   Logstash      │
│  (Deployment)   │    │  (StatefulSet)  │    │                 │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 빠른 시작

### 1. 사전 요구사항

- Kubernetes 클러스터 (GKE)
- Helm 3.x
- kubectl

### 2. Helm Repository 추가

```bash
helm repo add elastic https://helm.elastic.co
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### 3. 네임스페이스 확인

```bash
# loventure-app 네임스페이스가 이미 존재하는지 확인
kubectl get namespace loventure-app
```

### 4. ELK Stack 배포

```bash
# Elasticsearch 배포
helm install elasticsearch elastic/elasticsearch -n loventure-app -f helm-charts/elasticsearch/values.yaml

# Kibana 배포
helm install kibana elastic/kibana -n loventure-app -f helm-charts/kibana/values.yaml

# Logstash 배포
helm install logstash elastic/logstash -n loventure-app -f helm-charts/logstash/values.yaml

# Filebeat 배포
helm install filebeat elastic/filebeat -n loventure-app -f helm-charts/filebeat/values.yaml
```

## 📁 프로젝트 구조

```
LoveVenture_Monitoring/
├── README.md
├── helm-charts/
│   ├── elasticsearch/
│   │   └── values.yaml
│   ├── kibana/
│   │   └── values.yaml
│   ├── logstash/
│   │   └── values.yaml
│   ├── filebeat/
│   │   └── values.yaml
│   └── monitoring/
│       ├── dashboards/
│       └── index-patterns/
├── scripts/
│   ├── deploy.sh
│   └── cleanup.sh
└── docs/
    └── monitoring-guide.md
```

## 🔧 설정

각 컴포넌트의 상세 설정은 `helm-charts/` 디렉토리의 `values.yaml` 파일을 참조하세요.

## 📊 모니터링

- **Kibana URL**: `https://kibana.loventure.us`
- **Elasticsearch URL**: `http://elasticsearch-master.loventure-app.svc.cluster.local:9200`

## 🛠️ 유지보수

### 업그레이드
```bash
helm upgrade elasticsearch elastic/elasticsearch -n loventure-app -f helm-charts/elasticsearch/values.yaml
```

### 삭제
```bash
helm uninstall filebeat -n loventure-app
helm uninstall logstash -n loventure-app
helm uninstall kibana -n loventure-app
helm uninstall elasticsearch -n loventure-app
```

## 📚 추가 문서

- [모니터링 가이드](docs/monitoring-guide.md)
- [로그 파싱 규칙](helm-charts/logstash/README.md)
- [대시보드 설정](helm-charts/monitoring/README.md)