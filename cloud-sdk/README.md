
## Connect to Kubernetes Cluster
### For GCP
- Create a Kubernetes cluster in GCP
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
Install `ReadWriteMany` supported persistence volume. These steps vary based on the cloud provider. For Azure, this step is not requied. For AWS or GCP follow the specific sections.

### For GCP
- Create a Google Filestore instance by running below command. Make sure the given IP range is not in use. `Filestore Editor` role is required to create a Filestore instance.
```
gcloud filestore instances create nfs-server \
    --project=<project id> \
    --zone=<zone id> \
    --tier=STANDARD \
    --file-share=name="icapsourcevol1",capacity=1TB \
    --network=name="<VPC-name>",reserved-ip-range="</29 IP range>"
```
- SSH to any instance with Ubuntu/RHEL/CentOS/SUSE OS present in the zone where Filestore is created. If no instance exists, please create a new instance.
- Install NFS client.
```
# Install nfs client, based on the OS
# For Ubuntu
sudo apt-get -y update &&
sudo apt-get -y install nfs-common
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
sudo mount 10.1.0.2:/icapsourcevol1 /mnt/glasswall-filestore
sudo mkdir /mnt/glasswall-filestore/source /mnt/glasswall-filestore/target /mnt/glasswall-filestore/transactions
sudo umount /mnt/glasswall-filestore
sudo rm -rf /mnt/glasswall-filestore
```
### For AWS
- TBD

## Deploy helm charts:
```
cd cloud-sdk
helmfile apply
```
## Change Firewall rules
Describe the ingress and run the gcloud commands mentioned to create Firewall rules to allow traffic to ingress

## Validate the deployment
- Get Cloud SDK REST API ingress external IP address.  Run below command and copy the IP address mentioned in `ADDRESS` column of `rebuild-api-glasswall-sdk-api` ingress
```
kubectl get ing -n icap-adaptation
```
- Go to http://< ip address >/swagger to access the API's swagger

