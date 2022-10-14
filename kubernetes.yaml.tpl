apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: player-update
  namespace: kafka
  labels:
    strimzi.io/cluster: cloudbowl
spec:
  partitions: 10
  replicas: 2
  config:
    retention.ms: -1
    retention.bytes: -1
---
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: arena-config
  namespace: kafka
  labels:
    strimzi.io/cluster: cloudbowl
spec:
  partitions: 10
  replicas: 2
  config:
    retention.ms: -1
    retention.bytes: -1
---
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: viewer-ping
  namespace: kafka
  labels:
    strimzi.io/cluster: cloudbowl
spec:
  partitions: 10
  replicas: 2
  config:
    retention.ms: 60000
---
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: arena-update
  namespace: kafka
  labels:
    strimzi.io/cluster: cloudbowl
spec:
  partitions: 10
  replicas: 2
  config:
    retention.ms: 60000
---
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: scores-reset
  namespace: kafka
  labels:
    strimzi.io/cluster: cloudbowl
spec:
  partitions: 10
  replicas: 2
  config:
    retention.ms: 60000
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: cloudbowl-battle
  name: cloudbowl-battle
spec:
  replicas: 5
  selector:
    matchLabels:
      app: cloudbowl-battle
  template:
    metadata:
      labels:
        app: cloudbowl-battle
    spec:
      containers:
      - name: $REPO_NAME
        image: gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA
        imagePullPolicy: IfNotPresent
        command: ["battle"]
        resources:
          requests:
            cpu: "2"
        env:
        - name: KAFKA_BOOTSTRAP_SERVERS
          value: cloudbowl-kafka-bootstrap.kafka:9091
---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: cloudbowl-web
spec:
  template:
    metadata:
      name: cloudbowl-web-$COMMIT_SHA
      annotations:
        autoscaling.knative.dev/minScale: "1"
        autoscaling.knative.dev/maxScale: "10"
    spec:
      containers:
      - image: gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA
        args:
        - web
        env:
        - name: KAFKA_BOOTSTRAP_SERVERS
          value: cloudbowl-kafka-bootstrap.kafka:9091
        - name: WEBJARS_USE_CDN
          valueFrom:
            configMapKeyRef:
              key: WEBJARS_USE_CDN
              name: cloudbowl-config
        - name: APPLICATION_SECRET
          valueFrom:
            configMapKeyRef:
              key: APPLICATION_SECRET
              name: cloudbowl-config
        - name: ADMIN_PASSWORD
          valueFrom:
            configMapKeyRef:
              key: ADMIN_PASSWORD
              name: cloudbowl-config
        resources:
          limits:
            cpu: "2"
            memory: 1Gi
