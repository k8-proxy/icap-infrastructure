#!/bin/bash
  
# Setup rabbitMQ
pushd rabbitmq && helm upgrade rabbitmq --install . --namespace icap-adaptation && popd

## update adaptation
pushd adaptation
kubectl create -n icap-adaptation secret generic policyupdateservicesecret --from-literal=username=policy-management --from-literal=password='long-password'
kubectl create -n icap-adaptation secret generic transactionqueryservicesecret --from-literal=username=query-service --from-literal=password='long-password'
helm upgrade adaptation --install . --namespace icap-adaptation
popd

# update icap policy management
pushd ncfs
kubectl create -n icap-ncfs secret generic ncfspolicyupdateservicesecret --from-literal=username=policy-update --from-literal=password='long-password'
helm upgrade ncfs --install . --namespace icap-ncfs
popd

# update management ui
pushd administration
helm upgrade administration --install . --namespace management-ui
popd