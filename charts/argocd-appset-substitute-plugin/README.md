# argocd-substitute-plugin



![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square) 

ArgoCD Substitute Plugin Helm Chart









## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| image.repository | string | `"ghcr.io/grzegorzgniadek/argocd-appset-substitute-plugin"` |  |
| image.tag | string | `"1.0.0"` |  |
| imagePullPolicy | string | `"Always"` |  |
| port | string | `"4444"` |  |
| replicas | int | `1` |  |
| resources.limits.cpu | string | `"200m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"64Mi"` |  |
| serviceAccount.annotations | object | `{}` |  |