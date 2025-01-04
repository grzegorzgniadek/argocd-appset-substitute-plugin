# argocd-appset-substitute-plugin
[![Release Container](https://github.com/grzegorzgniadek/argocd-appset-substitute-plugin/actions/workflows/release-container.yaml/badge.svg?branch=master)](https://github.com/grzegorzgniadek/argocd-appset-substitute-plugin/releases) [![Release Charts](https://github.com/grzegorzgniadek/argocd-appset-substitute-plugin/actions/workflows/release-charts.yaml/badge.svg?branch=master)](https://github.com/grzegorzgniadek/argocd-appset-substitute-plugin/releases)
[![App Version](https://img.shields.io/github/v/tag/grzegorzgniadek/argocd-appset-substitute-plugin?sort=semver&filter=v*&label=App%20Version&color=darkgreen)](https://github.com/grzegorzgniadek/argocd-appset-substitute-plugin/tags) [![Chart Version](https://img.shields.io/github/v/tag/grzegorzgniadek/argocd-appset-substitute-plugin?sort=semver&filter=argocd*&label=Chart%20Version&color=darkgreen)](https://github.com/grzegorzgniadek/argocd-appset-substitute-plugin/tags) 
[![Go report card](https://goreportcard.com/badge/github.com/grzegorzgniadek/argocd-appset-substitute-plugin)](https://goreportcard.com/report/github.com/grzegorzgniadek/argocd-appset-substitute-plugin) [![Apache 2.0 license](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/license/apache-2-0)

ArgoCD plugin for variable substitution in ApplicationSet

## Supported Kubernetes versions

argocd-appset-substitute-plugin has been developed for and tested with Kubernetes 1.28.

## How it works

When Custom resource is created, controller takes secret keys and values and creates new secret as outputSecretName


## Architecture and components

- a `Deployment` to run interpolator's controller,

```bash
$ kubectl top pods
NAME                                               CPU(cores)   MEMORY(bytes)   
argocd-substitute-plugin-59db98964b-ljpvt              1m           6Mi
```

## Installation

1. Install argocd-appset-substitute-plugin's Helm chart from [charts](https://grzegorzgniadek.github.io/argocd-appset-substitute-plugin/) repository:

```bash
helm upgrade --install \
    --namespace argocd \
     argocd-substitute-plugin argocd-substitute-plugin \
     --repo https://grzegorzgniadek.github.io/argocd-appset-substitute-plugin
```

## Installation with plain YAML files

You can use Helm to generate plain YAML files and then deploy these YAML files with `kubectl apply` or whatever you want:

```bash
helm template --namespace argocd \
     argocd-substitute-plugin argocd-substitute-plugin \
     --repo https://grzegorzgniadek.github.io/argocd-appset-substitute-plugin \
     > /tmp/plugin.yaml
kubectl apply -f /tmp/plugin.yaml --namespace argocd
```

## Configuration and customization

You can see the full list of parameters (along with their meaning and default values) in the chart's [values.yaml](https://github.com/grzegorzgniadek/argocd-appset-substitute-plugin/blob/master/charts/argocd-appset-substitute-plugin/values.yaml) file.


#### Customize resources

```bash
helm upgrade --install \
     --namespace argocd  \
     argocd-substitute-plugin argocd-substitute-plugin \
     --repo https://grzegorzgniadek.github.io/argocd-appset-substitute-plugin \
     --set port=8000
```

## Use sample resource
```bash
kubectl apply -f https://raw.githubusercontent.com/grzegorzgniadek/argocd-appset-substitute-plugin/refs/heads/master/examples/applicationset.yaml
kubectl apply -f https://raw.githubusercontent.com/grzegorzgniadek/argocd-appset-substitute-plugin/refs/heads/master/examples/configmap.yaml
kubectl apply -f https://raw.githubusercontent.com/grzegorzgniadek/argocd-appset-substitute-plugin/refs/heads/master/examples/secret.yaml
```

## Delete sample resource
```bash
kubectl delete -f https://raw.githubusercontent.com/grzegorzgniadek/argocd-appset-substitute-plugin/refs/heads/master/examples/applicationset.yaml
kubectl delete -f https://raw.githubusercontent.com/grzegorzgniadek/argocd-appset-substitute-plugin/refs/heads/master/examples/configmap.yaml
kubectl delete -f https://raw.githubusercontent.com/grzegorzgniadek/argocd-appset-substitute-plugin/refs/heads/master/examples/secret.yaml
```
