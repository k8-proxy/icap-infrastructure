#!/bin/bash

create_pod () {

name=$1

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: adaptation-service
  name: $name
  namespace: icap-adaptation
spec:
  containers:
  - env:
    - name: POD_NAMESPACE
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.namespace
    - name: AMQP_URL
      value: amqp://guest:guest@rabbitmq-service:5672/
    - name: METRICS_PORT
      value: "8081"
    - name: INPUT_MOUNT
      value: /var/source
    - name: OUTPUT_MOUNT
      value: /var/target
    - name: REQUEST_PROCESSING_IMAGE
      value: glasswallsolutions/icap-request-processing:develop-77b6369
    - name: REQUEST_PROCESSING_TIMEOUT
      value: "00:01:00"
    - name: ADAPTATION_REQUEST_QUEUE_HOSTNAME
      value: rabbitmq-service
    - name: ADAPTATION_REQUEST_QUEUE_PORT
      value: "5672"
    - name: ARCHIVE_ADAPTATION_QUEUE_REQUEST_HOSTNAME
      value: rabbitmq-service
    - name: ARCHIVE_ADAPTATION_REQUEST_QUEUE_PORT
      value: "5672"
    - name: TRANSACTION_EVENT_QUEUE_HOSTNAME
      value: rabbitmq-service
    - name: TRANSACTION_EVENT_QUEUE_PORT
      value: "5672"
    - name: CPU_LIMIT
      value: "1"
    - name: CPU_REQUEST
      value: "0.25"
    - name: MEMORY_LIMIT
      value: 10000Mi
    - name: MEMORY_REQUEST
      value: 250Mi
    image: azopat/adaptation
    imagePullPolicy: Always
    name: adaptation-service
    ports:
    - containerPort: 8081
      protocol: TCP
    resources:
      limits:
        cpu: "1"
        memory: 500Mi
      requests:
        cpu: 25m
        memory: 100Mi
    volumeMounts:
    - mountPath: /var/source
      name: source-vol
    - mountPath: /var/target
      name: target-vol
  dnsPolicy: ClusterFirst
  restartPolicy: Never
  schedulerName: default-scheduler
  volumes:
  - name: source-vol
    persistentVolumeClaim:
      claimName: glasswallsource-pvc
  - name: target-vol
    persistentVolumeClaim:
      claimName: glasswalltarget-pvc
EOF

}

i=1
total=$1
while [ $i -le $total ]
do
   podName=rebuild-pod-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1)
   echo $podName
   create_pod $podName
   ((i++))
done
