## ICAP Infrastructure

Each of the cluster types that form the Glasswall ICAP System are defined through the Helm charts in the subfolders.

### Adaptation Cluster
Deploying to local cluster (Docker Desktop).

#### Prerequisites

1- Create transactionstoresecret secret

```
kubectl create -n icap-adaptation secret generic transactionstoresecret --from-literal=accountName=ACCOUNT_NAME --from-literal=accountKey=$ACCOUNTKEY
```

Note: Replace ACCOUNT_NAME and $ACCOUNTKEY with the corresponding values

2- The minimum reqs are 2 machines with at least 2 vCPUs as the adaptation-service requires at least 1 vCPUs.

Reset the Kubernetes cluster.

```
cd .\adaptation
```

3- Replace the storage class name with your cluster value in adaptation/values.yaml as following:

```
kubectl get sc
```

Add the name of the sc in .Values.storage.class.

 
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

In case of the pods CrashLoopBackOff, delete the pods by executing the following command:

```
kubectl get pods
kubectl delete pod adaptation-service- event-submission-service- -n icap-adaptation
```

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

*all commands below should be run from the root directory of the repo "aks-deployment-icap"*

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

Create transactionstoresecret secret

```
kubectl create -n icap-adaptation secret generic transactionstoresecret --from-literal=accountName=ACCOUNT_NAME --from-literal=accountKey=$ACCOUNTKEY
```

Install the cluster components
```
helm install ./adaptation --namespace icap-adaptation --generate-name
```

The cluster's services should now be deployed (Please note the adaptation service can restart several times before it is "running")
```
> kubectl get pods -n icap-adaptation
NAME                                 READY   STATUS    RESTARTS   AGE
adaptation-service-64cc49f99-kwfp6   1/1     Running   0          3m22s
mvp-icap-service-b7ddccb9-gf4z6      1/1     Running   0          3m22s
rabbitmq-controller-747n4            1/1     Running   0          3m22s
```

If required, the following steps provide access to the RabbitMQ Management Console

Change the current context

```
kubectl config set-context --current --namespace=icap-adaptation
```

Run the below command to enable the Management Plugin, this step takes a couple of minutes
```
kubectl exec -it rabbitmq-controller-747n4 -- /bin/bash -c "rabbitmq-plugins enable rabbitmq_management"
```

In case of the pods CrashLoopBackOff, delete the pods by executing the following command:

```
kubectl get pods
kubectl delete pod adaptation-service- event-submission-service- -n icap-adaptation
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
