# argocd-substitute-plugin



![Version: 1.3.0](https://img.shields.io/badge/Version-1.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.2.0](https://img.shields.io/badge/AppVersion-v1.2.0-informational?style=flat-square) 

ArgoCD Substitute Plugin Helm Chart









## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonMetaLabels | object | `{}` |  |
| controller.affinity | object | `{}` |  |
| controller.clusterRoleNameOverride | string | `""` |  |
| controller.command[0] | string | `"/plugin"` |  |
| controller.configMapOverrideName | string | `""` |  |
| controller.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| controller.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| controller.deploymentAnnotations | object | `{}` |  |
| controller.dnsConfig | object | `{}` |  |
| controller.emptyDir.sizeLimit | object | `{}` |  |
| controller.env | list | `[]` |  |
| controller.extraArgs | object | `{}` |  |
| controller.extraConfigmapLabels | object | `{}` |  |
| controller.extraConfigmapMounts | list | `[]` |  |
| controller.extraHostPathMounts | list | `[]` |  |
| controller.extraInitContainers | list | `[]` |  |
| controller.extraSecretMounts | list | `[]` |  |
| controller.extraVolumeMounts | list | `[]` |  |
| controller.extraVolumes | list | `[]` |  |
| controller.fullnameOverride | string | `""` |  |
| controller.hostAliases | list | `[]` |  |
| controller.image.digest | string | `""` |  |
| controller.image.pullPolicy | string | `"IfNotPresent"` |  |
| controller.image.repository | string | `"ghcr.io/grzegorzgniadek/argocd-appset-substitute-plugin"` |  |
| controller.image.tag | string | `"v1.2.0"` |  |
| controller.imagePullSecrets | list | `[]` |  |
| controller.livenessProbe.initialDelaySeconds | int | `15` |  |
| controller.livenessProbe.periodSeconds | int | `20` |  |
| controller.name | string | `"controller"` |  |
| controller.nodeSelector | object | `{}` |  |
| controller.persistentVolume.enabled | bool | `false` |  |
| controller.podAnnotations | object | `{}` |  |
| controller.podAntiAffinity | object | `{}` |  |
| controller.podLabels | object | `{}` |  |
| controller.port | string | `"4535"` |  |
| controller.priorityClassName | string | `""` |  |
| controller.readinessProbe.initialDelaySeconds | int | `5` |  |
| controller.readinessProbe.periodSeconds | int | `10` |  |
| controller.releaseNamespace | bool | `false` |  |
| controller.replicaCount | int | `1` |  |
| controller.resources.limits.cpu | string | `"200m"` |  |
| controller.resources.limits.memory | string | `"128Mi"` |  |
| controller.resources.requests.cpu | string | `"10m"` |  |
| controller.resources.requests.memory | string | `"64Mi"` |  |
| controller.schedulerName | string | `""` |  |
| controller.secret.token | string | `""` |  |
| controller.securityContext.runAsNonRoot | bool | `true` |  |
| controller.service.additionalPorts | list | `[]` |  |
| controller.service.annotations | object | `{}` |  |
| controller.service.clusterIP | string | `""` |  |
| controller.service.enabled | bool | `true` |  |
| controller.service.externalIPs | list | `[]` |  |
| controller.service.externalTrafficPolicy | string | `""` |  |
| controller.service.labels | object | `{}` |  |
| controller.service.loadBalancerIP | string | `""` |  |
| controller.service.loadBalancerSourceRanges | list | `[]` |  |
| controller.service.servicePort | int | `80` |  |
| controller.service.sessionAffinity | string | `"None"` |  |
| controller.service.type | string | `"ClusterIP"` |  |
| controller.sidecarContainers | object | `{}` |  |
| controller.sidecarTemplateValues | object | `{}` |  |
| controller.startupProbe.enabled | bool | `false` |  |
| controller.startupProbe.failureThreshold | int | `30` |  |
| controller.startupProbe.periodSeconds | int | `5` |  |
| controller.startupProbe.timeoutSeconds | int | `10` |  |
| controller.tolerations | list | `[]` |  |
| controller.topologySpreadConstraints | list | `[]` |  |
| rbac.create | bool | `true` |  |
| serviceAccounts.controller.annotations | object | `{}` |  |
| serviceAccounts.controller.create | bool | `true` |  |
| serviceAccounts.controller.labels | object | `{}` |  |
| serviceAccounts.controller.name | string | `""` |  |