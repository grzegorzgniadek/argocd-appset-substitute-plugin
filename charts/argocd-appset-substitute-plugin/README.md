# argocd-substitute-plugin



![Version: 0.5.0](https://img.shields.io/badge/Version-0.5.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.2.0-rc](https://img.shields.io/badge/AppVersion-v0.2.0--rc-informational?style=flat-square) 

ArgoCD Substitute Plugin Helm Chart









## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| image.repository | string | `"ghcr.io/grzegorzgniadek/argocd-appset-substitute-plugin"` |  |
| image.tag | string | `"v0.2.0-rc"` |  |
| imagePullPolicy | string | `"Always"` |  |
| port | string | `"4444"` |  |
| replicas | int | `1` |  |
| resources.limits.cpu | string | `"200m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"64Mi"` |  |
| serviceAccount.annotations | object | `{}` |  |