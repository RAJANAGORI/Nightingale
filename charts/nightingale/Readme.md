## Helm Package for Nightingale
Nightingale is an open-source tool that aims to address this problem by providing a ready-to-use environment for pentesters.

This chart bootstraps a Nightingale deployment on a Kubernetes cluster using the Helm package manager.

Let's Open Feathers in the Cloud: Nightingale Meets Kubernetes!

## Prerequisites
Kubernetes 1.19+
Helm 3.7+

## Install/Upgrade Chart
```
helm upgrade --install nightingale oci://ghcr.io/rajanagori/nightingale/nightingale --version 0.0.1 -n nightingale --create-namespace
```

## Values
| Key                         | Type   | Default                 |
|-----------------------------|--------|-------------------------|
| namespaceOverride           | String | ""                      |
| replicaCount                | Int    | 1                       |
| image.repository            | String | ghcr.io/rajanagori/nightingale |
| image.tag                   | String | stable                  |
| image.pullPolicy            | String | IfNotPresent            |
| strategy.type               | String | RollingUpdate           |
| strategy.rollingUpdate.maxUnavailable | String | 25%                |
| strategy.rollingUpdate.maxSurge | String | 25%                   |
| podSecurityContext          | Object | {}                      |
| securityContext             | Object | {}                      |
| resources.limits.cpu        | String | 100m                    |
| resources.limits.memory     | String | 200Mi                   |
| resources.requests.cpu      | String | 50m                     |
| resources.requests.memory   | String | 100Mi                   |
| volumes                     | List   | []                      |
| volumeMounts                | List   | []                      |
| tolerations                 | List   | []                      |
| affinity                    | Object | {}                      |
| service.type                | String | ClusterIP               |
| service.port                | Int    | 80                      |
| ingress.enabled             | Bool   | false                   |
| ingress.ingressClassName    | String | nginx                   |
| ingress.annotations         | Object | {}                      |
| ingress.host.enabled        | Bool   | false                   |
| ingress.host.name           | String | ""                      |
| ingress.tls.enabled         | Bool   | false                   |
| ingress.tls.secretName      | String | ""                      |
| autoscaling.enabled         | Bool   | false                   |
| autoscaling.minReplicas     | Int    | 1                       |
| autoscaling.maxReplicas     | Int    | 10                      |
| autoscaling.cpuUtilization  | Int    | 80                      |
| autoscaling.memoryUtilization | Int   | 95                      |

## Uninstall Chart
```
helm uninstall nightinfgale -n nightingale
```