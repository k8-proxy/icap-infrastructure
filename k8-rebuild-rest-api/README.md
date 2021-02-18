# Rebuild REST API Helm Chart

## Parameters

### Global parameters

| Parameter              | Description                  | Default |
| ---------------------- | ---------------------------- | ------- |
| `global.imageRegistry` | Global Docker image registry | `nil`   |

### Common parameters

| Parameter          | Description                           | Default |
| ------------------ | ------------------------------------- | ------- |
| `nameOverride`     | String to partially override fullname | `nil`   |
| `fullnameOverride` | String to fully override fullname     | `nil`   |

### App parameters

| Parameter          | Description        | Default                            |
| ------------------ | ------------------ | ---------------------------------- |
| `image.registry`   | App image registry | `docker.io`                        |
| `image.repository` | App image name     | `yardenshoham/k8-rebuild-rest-api` |
| `image.tag`        | App image tag      | `latest`                           |

### Exposure parameters

| Parameter          | Description               | Default    |
| ------------------ | ------------------------- | ---------- |
| `service.type`     | Kubernetes Service type   | `NodePort` |
| `service.nodePort` | Kubernetes http node port | `31344`    |

### App deployment parameters

| Parameter                 | Description                                   | Default                  |
| ------------------------- | --------------------------------------------- | ------------------------ |
| `resources.requests`      | The requested resources for the app container | Check `values.yaml` file |
| `resources.limits`        | The resources limits for the app container    | Check `values.yaml` file |
| `autoscaling.enabled`     | Enable autoscaling for app deployment         | `true`                   |
| `autoscaling.minReplicas` | Minimum number of replicas to scale back      | `1`                      |
| `autoscaling.maxReplicas` | Maximum number of replicas to scale out       | `10`                     |
| `autoscaling.targetCPU`   | Target CPU utilization percentage             | `50`                     |
