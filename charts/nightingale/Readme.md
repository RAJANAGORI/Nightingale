# Nightingale Helm Chart

![Nightingale Logo](https://raw.githubusercontent.com/RAJANAGORI/Nightingale/main/assets/images/Nightingale.png)

This Helm chart deploys **Nightingale**, a comprehensive dockerized penetration testing environment, on a Kubernetes cluster. It is designed to be production-ready with proper security contexts, resource management, and autoscaling capabilities.

## Features

- **Production-Ready**: Configured with liveness/readiness probes, resource limits, and security best practices.
- **Scalable**: Supports Horizontal Pod Autoscaler (HPA) based on CPU and Memory usage.
- **Secure**: Configurable `securityContext` and `podSecurityContext` for run-as-user restrictions and filesystem permissions.
- **Accessible**: Easy access via Ingress or Service (ClusterIP/NodePort/LoadBalancer) with `ttyd` terminal in the browser.
- **Flexible**: extensive configuration options via `values.yaml`.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installing the Chart

To install the chart with the release name `nightingale`:

```bash
# Add the repository
helm repo add nightingale https://rajanagori.github.io/Nightingale
helm repo update

# Install the chart
helm install nightingale nightingale/nightingale --create-namespace -n nightingale
```

## Uninstalling the Chart

To uninstall/delete the `nightingale` deployment:

```bash
helm uninstall nightingale -n nightingale
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Nightingale chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `nameOverride` | string | `""` | Override the name of the chart |
| `fullnameOverride` | string | `""` | Override the full name of the release |
| `replicaCount` | int | `1` | Number of replicas to deploy |
| `image.repository` | string | `ghcr.io/rajanagori/nightingale` | Nightingale image repository |
| `image.tag` | string | `"stable"` | Image tag (defaults to chart appVersion if not set) |
| `image.pullPolicy` | string | `IfNotPresent` | Image pull policy |
| `imagePullSecrets` | list | `[]` | Secrets for pulling private images |
| `serviceAccount.create` | bool | `true` | Create a ServiceAccount |
| `serviceAccount.annotations` | object | `{}` | Annotations for the ServiceAccount |
| `serviceAccount.name` | string | `""` | ServiceAccount name (generated if empty) |
| `podAnnotations` | object | `{}` | Annotations to add to the Pods |
| `podSecurityContext` | object | `{}` | Pod-level security context (fsGroup, etc.) |
| `securityContext` | object | `{}` | Container-level security context (capabilities, runAsUser, etc.) |
| `service.type` | string | `ClusterIP` | Kubernetes Service type (ClusterIP, NodePort, LoadBalancer) |
| `service.port` | int | `80` | Port to expose the service |
| `ingress.enabled` | bool | `false` | Enable Ingress resource |
| `ingress.className` | string | `""` | Ingress class name (e.g., nginx) |
| `ingress.hosts` | list | `[]` | List of ingress hosts and paths |
| `ingress.tls` | list | `[]` | TLS configuration for Ingress |
| `resources` | object | `{}` | CPU/Memory requests and limits (Highly Recommended for prod) |
| `autoscaling.enabled` | bool | `false` | Enable Horizontal Pod Autoscaler |
| `autoscaling.minReplicas` | int | `1` | Minimum replicas for HPA |
| `autoscaling.maxReplicas` | int | `10` | Maximum replicas for HPA |
| `autoscaling.targetCPUUtilizationPercentage` | int | `80` | Target CPU utilization for HPA |
| `livenessProbe` | object | (see values.yaml) | Configuration for liveness probe |
| `readinessProbe` | object | (see values.yaml) | Configuration for readiness probe |
| `nodeSelector` | object | `{}` | Node labels for pod assignment |
| `tolerations` | list | `[]` | Tolerations for pod assignment |
| `affinity` | object | `{}` | Affinity settings for pod assignment |

### Resource Management

It is highly recommended to set resource requests and limits in production to ensure stable performance.

```yaml
resources:
  limits:
    cpu: 200m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 256Mi
```

### Ingress Configuration

To enable Ingress, set `ingress.enabled` to `true` and define hosts:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: nightingale.local
      paths:
        - path: /
          pathType: Prefix
```

### Security

For stricter security, you can configure the contexts:

```yaml
securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
```

> **Note**: As Nightingale is a pentesting container requiring many system tools, applying too strict security contexts (like `readOnlyRootFilesystem`) might break some tools. Test accordingly.

## Post-Installation

After installation, check the `NOTES.txt` output for instructions on how to access your Nightingale instance.

If using **ClusterIP** (default), you can port-forward:
```bash
kubectl port-forward svc/nightingale 8080:80
```
Then access it at `http://localhost:8080`.
