# Stand Alone Rabbitmq Chart

## Please note

Please remember to remove or comment out the rabbitmq charts within the Adaptation chart.

Follow the below to stand up the rabbit mq service

```bash
helm install ./rabbitmq --namespace icap-adaptation --generate-name
```

Once pod is up and running, exec the following command to enable management plugins

```bash
kubectl exec -it rabbitmq-controller-747n4 -- /bin/bash -c "rabbitmq-plugins enable rabbitmq_management"
```

