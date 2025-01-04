# argocd-substitute-plugin



![Version: 0.1.4-rc](https://img.shields.io/badge/Version-0.1.4--rc-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.1.3-rc](https://img.shields.io/badge/AppVersion-v0.1.3--rc-informational?style=flat-square) 

ArgoCD Substitute Plugin Helm Chart









## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| image.repository | string | `"ghcr.io/grzegorzgniadek/argocd-appset-substitute-plugin"` |  |
| image.tag | string | `"v0.1.3-rc"` |  |
| imagePullPolicy | string | `"Always"` |  |
| port | string | `"4444"` |  |
| replicas | int | `1` |  |
| resources.limits.cpu | string | `"200m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"10m"` |  |
| resources.requests.memory | string | `"64Mi"` |  |
| serviceAccount.annotations | object | `{}` |  |
| version | string | `"0.1.3-rc"` |  |