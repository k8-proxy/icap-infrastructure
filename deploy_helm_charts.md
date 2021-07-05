
## Connect to Kubernetes Cluster in GCP
- Create a Kubernetes cluster in GCP
- Run below command in the local machine to get kubernetes configuration of the cluster.
```
gcloud container clusters get-credentials <cluster name> --zone <zone id> --project <GCP project id>
```
- Run below command to assign `cluster-admin` role to your user. This is required only to deploy the helm charts. `Kubernetes Engine Admin` role is required to run below command.
```
kubectl create clusterrolebinding <your name>-cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
```

## Setup pre-requisites:
1. Install nginx ingress controller

```
kubectl create ns ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx -ningress-nginx
kubectl get all -ningress-nginx
```

2. Install `ReadWriteMany` supported persistence volume

- Create a Google Filestore instance by running below command. Make sure the given IP range is not in use. `Filestore Editor` role is required to create a Filestore instance.
```
gcloud filestore instances create nfs-server \
    --project=<project id> \
    --zone=<zone id> \
    --tier=STANDARD \
    --file-share=name="icapsourcevol1",capacity=1TB \
    --network=name="default",reserved-ip-range="10.1.0.0/29"
```
- SSH to any instance with Ubuntu/RHEL/CentOS/SUSE OS present in the zone where Filestore is created. If no instance exists, please create a new instance.
- Install NFS client.
```
# Install nfs client, based on the OS
# For Ubuntu
sudo apt-get -y update &&
sudo apt-get install nfs-common
# For RHEL/CentOs
sudo yum update &&
sudo yum install nfs-utils
# For SUSE
sudo zypper update &&
sudo zypper -n install nfs-client
```
- Mount the Filestore and create 3 folders (source, target, transactions)

```
sudo mkdir -p /mnt/glasswall-filestore
sudo mount <ip-address>:/<file-share-name> /mnt/glasswall-filestore
sudo mkdir /mnt/glasswall-filestore/source /mnt/glasswall-filestore/target /mnt/glasswall-filestore/transactions
sudo umount /mnt/glasswall-filestore
```

## Deploy helm charts:
- Create namespaces
```
kubectl create ns icap-adaptation
kubectl create ns minio
kubectl create ns jaeger
```
- clone icap-infrastructure repo
```
git clone https://github.com/k8-proxy/icap-infrastructure.git --branch k8-minio && pushd icap-infrastructure
```
- Open adaptation/custom-values.yaml file and update under gcp.filestore with ip address and paths of Google Filestore.
- Update password in secrets section of yaml with strong passwords.
- Generate a SSL cert and key pair and copy to adaptation folder
```
cat >> openssl.cnf <<EOF
[ req ]
prompt = no
distinguished_name = req_distinguished_name
[ req_distinguished_name ]
C = GB
ST = London
L = London
O = Glasswall
OU = IT
CN = icap-server
emailAddress = admin@glasswall.com
EOF

openssl req -newkey rsa:2048 -config openssl.cnf -nodes -keyout  tls.key -x509 -days 365 -out certificate.crt
mv certificate.crt tls.key adaptation/
```
- Update secrets.mvpicapservice.tls.tlsCert and secrets.mvpicapservice.tls.tlsKey in adaptation/custom-values.yaml with paths of certificate.crt and tls.key respectively
- Install rabbitmq and adaptation helm charts. 
```
helm upgrade rabbitmq --install rabbitmq --namespace icap-adaptation --atomic
helm upgrade adaptation --values adaptation/custom-values.yaml --install adaptation --namespace icap-adaptation --set cloud_provider=GCP
popd
```

- Install Minio, update MINIO_SECRET variable with a strong password
```
helm repo add minio https://helm.min.io/
MINIO_SECRET="strong-secret"
helm upgrade --install -n minio minio --set accessKey=minio,secretKey=$MINIO_SECRET,buckets[0].name=sourcefiles,buckets[0].policy=none,buckets[0].purge=false,buckets[1].name=cleanfiles,buckets[1].policy=none,buckets[1].purge=false,fullnameOverride=minio-server,persistence.enabled=false,service.type=LoadBalancer minio/minio
kubectl create -n icap-adaptation secret generic minio-credentials --from-literal=username='minio' --from-literal=password=$MINIO_SECRET
```
- Install go k8s services
```
git clone https://github.com/k8-proxy/go-k8s-infra.git -b main && pushd go-k8s-infra
kubectl -n icap-adaptation scale --replicas=0 deployment/adaptation-service
kubectl -n icap-adaptation delete cronjob pod-janitor
# Install jaeger-agent
kubectl apply -f jaeger-agent/jaeger.yaml
# Install k8s-dashboard
kubectl apply -f k8s-dash
# Apply helm chart to create the services
helm upgrade servicesv2 --install services --namespace icap-adaptation
popd
```

- Install Cloud SDK Rest API
```
git clone https://github.com/k8-proxy/cs-k8s-api -b develop && pushd cs-k8s-api
helm upgrade --install -n icap-adaptation rebuild-api --set application.api.env.SDKApiVersion="0.5.1" --set application.api.env.SDKEngineVersion="1.255" infra/kubernetes/chart
popd
```

## Validate the deployment
- Get Cloud SDK REST API ingress external IP address.  Run below command and copy the IP address mentioned in `ADDRESS` column of `rebuild-api-glasswall-sdk-api` ingress
```
kubectl get ing -n icap-adaptation
```
- Go to http://<ip address>/swagger to access the API's swagger

