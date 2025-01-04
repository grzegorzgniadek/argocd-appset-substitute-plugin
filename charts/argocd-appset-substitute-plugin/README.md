# argocd-substitute-plugin



![Version: 1.0.3](https://img.shields.io/badge/Version-1.0.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.0.2](https://img.shields.io/badge/AppVersion-v1.0.2-informational?style=flat-square) 

ArgoCD Substitute Plugin Helm Chart









## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| image.repository | string | `"ghcr.io/grzegorzgniadek/argocd-appset-substitute-plugin"` |  |
| image.tag | string | `"v1.0.2"` |  |
| imagePullPolicy | string | `"Always"` |  |
| port | string | `"4444"` |  |
| replicas | int | `1` |  |
| resources.limits.cpu | string | `"200m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"64Mi"` |  |
| serviceAccount.annotations | object | `{}` |  |
| version | string | `"0.1.3-rc"` |  |