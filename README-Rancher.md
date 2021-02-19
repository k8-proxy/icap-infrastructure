## ICAP Infrastructure

Each of the cluster types that form the Glasswall ICAP System are defined through the Helm charts in the subfolders.

## Install kubernetes

### Rancher

Rancher is a container management platform built for organizations that deploy containers in production. Rancher makes it easy to run Kubernetes everywhere, meet IT requirements, and empower DevOps teams.

### Installation steps to deploy K8s cluster on EC2 instances using Rancher

1. Deploy rancher server using docker

```
docker run -d --restart=unless-stopped \
  -p 8080:80 -p 8443:443 \
  --privileged \
  rancher/rancher:latest
```

Once the docker is running, it takes few minutes to initialize the server. Once the server is started, access the rancher UI on https://<host or IP>:8443

2. Setup AWS cloud credentials

Under profile, select "Cloud Credentials" and click on "Add Cloud Credentails". Populate the details of region, access key, secret key, credentails name and save it.

3. Create an ec2 node template.

Under profile, select "Node templates" and click on "Add template". Choose Amazon ec2 type for node template. 

Under Account Access, Choose the region where k8s cluster needs to be deployed. Choose the cloud credentails that is created in step 2.

Under Zone and Network, choose the Availability zone and the subnet where cluster nodes should be deployed. Then click next.

Under Secuirity groups, choose stander to automatically create a security group with required rules for cluster nodes. Then click next.

Under Instance, choose the instance type, root disk size etc.

Give a name for the node template and click on Create.


4. Create a K8s cluster.

Go to Clusters in rancher UI.

Click on Add cluster. Provide a cluster name and Name prefix for nodes.

Select the previously created template from step 3 in the dropdown and give the number of nodes required in the count field.

Select etcd, control plane and worker to make sure they are installed in at least 1 node.

Click on create button to provision the k8s cluster.


5. Test the cluster deployment:

Select and open the cluster to be tested. On the right top, click on "Kubeconfig File" and copy the config file data.

Create a local file called `kubeconfig` and paste the copied data.

Use this file to connect to the cluster by running below commands. Please note, in the below command the `KUBECONFIG` variable should be set to the path of `kubeconfig` file created in the previous step. It is easy to connect to the cluster, if the file is merged with `~/.kube/config` or if the file is placed in `stable-src` directory which will be created in the next step so that the file can be used to deploy the helm chart.

  ```
  export KUBECONFIG=kubeconfig
  kubectl get nodes
  kubectl get all --all-namespaces
  ``` 

### Adaptation Cluster
Deploying to Kubernetes

```
cd .\adaptation
```

Create the Kubernetes namespace
```
kubectl create ns icap-adaptation
```

Create container registry secret
```
kubectl create -n icap-adaptation secret docker-registry regcred	\ 
	--docker-server=https://index.docker.io/v1/ 	\
	--docker-username=<username>	\
	--docker-password=<password>	\
	--docker-email=<email address>
```

Create secret with rabbitmq username and password

```
kubectl create -n icap-adaptation secret generic transactionstoresecret --from-literal=accountName=guest --from-literal=accountKey=guest
```

Install the cluster components
```
helm install . --namespace icap-adaptation --generate-name
```

The cluster's services should now be deployed
```
> kubectl get pods -n icap-adaptation
NAME                                 READY   STATUS    RESTARTS   AGE
adaptation-service-64cc49f99-kwfp6   1/1     Running   0          3m22s
mvp-icap-service-b7ddccb9-gf4z6      1/1     Running   0          3m22s
rabbitmq-controller-747n4            1/1     Running   0          3m22s
```

If required, the following steps provide access to the RabbitMQ Management Console

Open a command prompt into the RabbitMQ Pod
```
kubectl exec --stdin --tty -n icap-adaptation rabbitmq-controller-747n4 -- /bin/bash
```

Enable the Management Plugin, this step takes a couple of minutes
```
rabbitmq-plugins enable rabbitmq_management
```

Exit from the RabbitMQ Pod.
Setup of port forwarding from a local port (e.g. 8080) to the RabbitMQ Management Port
```
kubectl port-forward -n icap-adaptation rabbitmq-controller-747n4 8080:15672
```
The management console now accessible through the browser
```
http://localhost:8080/
```

## Standing up the Adaptation Service

After you have deployed the AKS Cluster to Azure you will then need to follow the steps below to stand up the Adaptation service.

### Deploying Adaptation Cluster - using helm

Deploying to AKS

In order to get the credentials for the AKS cluster you must run the command below:

```
az aks get-credentials --name gw-icap-aks --resource-group gw-icap-aks-deploy
```

*all commands below should be run from the root directory of the repo "icap-infrastructure"*

Create the Kubernetes namespace
```
kubectl create ns icap-adaptation
```

Create container registry secret - this requires a service account created within Dockerhub

***The command below should only be run on a fresh deployment, if you're deploying to a cluster that has already been deployed to, then this will already be within the secret store***

```
kubectl create -n icap-adaptation secret docker-registry regcred	\ 
	--docker-server=https://index.docker.io/v1/ 	\
	--docker-username=<username>	\
	--docker-password="<password>"	\ # Please ensure you add quotes to password
	--docker-email=<email address>
```

Create Self-signed TLS Certificate
```
openssl req -newkey rsa:2048 -nodes -keyout  tls.key -x509 -days 365 -out certificate.crt
```

Create TLS Certificate Secret
```
kubectl create secret tls icap-service-tls-config --namespace icap-adaptation --key tls.key --cert certificate.crt
```

Create Transaction Store Secret

```
kubectl create -n icap-adaptation secret generic transactionstoresecret --from-literal=accountName=guest --from-literal=accountKey=guest
```

Create Policy Update Service Secret
```
kubectl create -n icap-adaptation secret generic policyupdateservicesecret \
   --from-literal=username=policy-management \
   --from-literal=password='long-password'
```

Install the cluster components
```
helm upgrade --install --namespace icap-adaptation rabbitmq ./rabbitmq
helm upgrade --install --namespace icap-adaptation icap ./adaptation
```

The cluster's services should now be deployed (Please note the adaptation service can restart several times before it is "running")
```
> kubectl get pods -n icap-adaptation
NAME                                          READY   STATUS      RESTARTS   AGE
rabbitmq-controller-s2swm                     1/1     Running     0          6m28s
policy-update-service-7476ccf67b-684xd        1/1     Running     0          3m24s
mvp-icap-service-5cc549bbd6-lqnvn             1/1     Running     0          3m24s
event-submission-service-5c58877cbd-j828h     1/1     Running     4          3m24s
archive-adaptation-service-76d7ffd97b-txvz2   1/1     Running     4          3m24s
adaptation-service-65654457b4-q8xcr           1/1     Running     4          3m25s
```

Setup ingress for icap server

We need to setup ingress for the icap server to expose 1344 port of `icap-service` service from `icap-adaptation` namespace.

Run below command to create yaml file for tcp_services configMap of nginx ingress.

`kubectl get configmap/tcp-services -ningress-nginx -o yaml > tcp_services.yaml`

If the above command gives error, please see below note.

Add below lines to the tcp_services.yaml:

```
data:
  1344: "icap-adaptation/icap-service:1344"
  1344: "icap-adaptation/icap-service:1345"
```

Note: If the `tcp-services` configMap is not present in `ingress-nginx` namespace, manually create `tcp_services.yaml` file with below content

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: ingress-nginx
data:
  1344: "icap-adaptation/icap-service:1344"
  1344: "icap-adaptation/icap-service:1345"
```

Run below command to apply the changes on the cluster.

```
kubectl apply -f tcp_services.yaml
```


If required, the following steps provide access to the RabbitMQ Management Console

Run the below command to enable the Management Plugin, this step takes a couple of minutes
```
kubectl exec -it rabbitmq-controller-747n4 -- /bin/bash -c "rabbitmq-plugins enable rabbitmq_management"
```

Setup of port forwarding from a local port (e.g. 8080) to the RabbitMQ Management Port
```
kubectl port-forward -n icap-adaptation rabbitmq-controller-747n4 8080:15672
```
The management console now accessible through the browser
```
http://localhost:8080/
```

### Standing up Management UI

All of these commands are run in the root folder. Firstly create the namespace

```
kubectl create ns management-ui
```

Next use Helm to deploy the chart

```
helm install ./administration/management-ui/ --namespace management-ui --generate-name
```

Services should start on their own and the management UI will be available from the public IP that is attached to the load balancer.

To see this use the following command

```
❯ kubectl get service -n management-ui
NAME                             TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
icap-management-portal-service   LoadBalancer   xxx.xxx.xxx.xxx   xxx.xxx.xxx.xxx   80:32231/TCP   24h
```

### Standing up Transaction-Event-API

All of these commands are run in the root folder. Firstly create the namespace

```
kubectl create ns transaction-event-api
```

Next use Helm to deploy the chart

```
helm install ./administration/transactioneventapi --namespace management-ui --generate-name
```