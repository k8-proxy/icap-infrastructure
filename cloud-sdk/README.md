
## Connect to Kubernetes Cluster
### For GCP
- Create a Kubernetes cluster in GCP with a node size of at least 2 CPU cores and 8GB Memory
- Run below command in the local machine to get kubernetes configuration of the cluster.
```
gcloud container clusters get-credentials <cluster name> --zone <zone id> --project <GCP project id>
```
- Run below command to assign `cluster-admin` role to your user. This is required only to deploy the helm charts. `Kubernetes Engine Admin` role is required to run below command.
```
kubectl create clusterrolebinding <your name>-cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
```

### For Azure
- Create a Kubernetes cluster in Azure.
- Run below command in the local machine to get kubernetes configuration of the cluster.
```
az aks get-credentials -n <cluster name> -g <resource group name>
```
### For AWS
- TBD

## Setup pre-requisites:
- Install helmfile and helm-diff plugins
```
# For linux/mac
helm plugin install https://github.com/databus23/helm-diff
curl -fsSL -o helmfile https://github.com/roboll/helmfile/releases/download/v0.139.9/helmfile_linux_amd64
chmod 700 helmfile 
sudo mv helmfile  /usr/local/bin/
```
- Install `ReadWriteMany` supported persistence volume. These steps vary based on the cloud provider. For Azure, this step is not requied. For AWS or GCP follow the specific sections.

### For GCP
- Create a Google Filestore instance by running below command. Make sure the given IP range is not in use. `Filestore Editor` role is required to create a Filestore instance.
```
NETWORK_PROJECT=network-project-b1
SERVICE_PROJECT=unique-axle-314109
ZONE_ID=us-central1-c
gcloud filestore instances create nfs-server \
    --project=$SERVICE_PROJECT \
    --zone=<zone id> \
    --tier=STANDARD \
    --file-share=name="glasswallstore",capacity=1TB \
    --network=name="<VPC-name>",reserved-ip-range="</29 IP range>"
wget -O yq https://github.com/mikefarah/yq/releases/download/v4.9.8/yq_linux_amd64  && sudo mv yq /usr/local/bin
FILESTORE_IP=$(gcloud beta filestore instances describe nfs-serverdp --zone us-central1-c --project $SERVICE_PROJECT | yq eval '.networks[0].ipAddresses[0]' - )
FILESTORE_NAME=$(gcloud beta filestore instances describe nfs-serverdp --zone us-central1-c --project $SERVICE_PROJECT | yq eval '.fileShares[0].name' - )
echo "Filestore IP address is $FILESTORE_IP and name is $FILESTORE_NAME"
gcloud beta compute --project=$SERVICE_PROJECT instances create nfs-client --zone=$ZONE_ID --machine-type=e2-micro --subnet=projects/$NETWORK_PROJECT/regions/us-central1/subnetworks/< VPC name > --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=564212831534-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --image=ubuntu-2004-focal-v20210702 --image-project=ubuntu-os-cloud --boot-disk-size=10GB --boot-disk-type=pd-balanced --boot-disk-device-name=nfs-client --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
sleep 20s
gcloud compute ssh nfs-client --command "sudo apt-get -y update && sudo apt-get -y install nfs-common && sudo mkdir -p /mnt/glasswall-filestore && sudo mount $FILESTORE_IP:/$FILESTORE_NAME /mnt/glasswall-filestore && sudo mkdir -p /mnt/glasswall-filestore/source /mnt/glasswall-filestore/target /mnt/glasswall-filestore/transactions && sudo umount /mnt/glasswall-filestore && sudo rm -rf /mnt/glasswall-filestore" --zone=$ZONE_ID
echo "Created directories in the Google Filestore"
gcloud --quiet compute instances delete nfs-client --zone $ZONE_ID
echo "Delete nfs-client instance"
```
### For AWS
- TBD

## Deploy helm charts:
```
cd cloud-sdk
export MINIO_USERNAME=minio
export MINIO_PASSWORD=<password>
export RABBITMQ_USERNAME=guest
export RABBITMQ_PASSWORD=<password>
export FILESTORE_IP=<fileshare ip>
export FILESHARENAME=<fileshare name>
helmfile diff
helmfile apply
```
## Change Firewall rules
Describe the ingress and run the gcloud commands mentioned to create Firewall rules to allow 
traffic to ingress
```
kubectl describe ing -nicap-adaptation
```

## Validate the deployment
- Get Cloud SDK REST API ingress external IP address.  Run below command and copy the IP address mentioned in `ADDRESS` column of `rebuild-api-glasswall-sdk-api` ingress
```
kubectl get ing -n icap-adaptation
```
- Go to http://< ip address >/swagger to access the API's swagger
- It may take around 5 minutes for the ingress rules to sync and the IP of ingress may change after few minutes.
