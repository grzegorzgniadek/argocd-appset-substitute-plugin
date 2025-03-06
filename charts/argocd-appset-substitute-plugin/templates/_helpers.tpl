{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "argocd-appset-substitute-plugin.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "argocd-appset-substitute-plugin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create labels for argocd-appset-substitute-plugin
*/}}
{{- define "argocd-appset-substitute-plugin.common.matchLabels" -}}
app.kubernetes.io/name: {{ include "argocd-appset-substitute-plugin.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create unified labels for argocd-appset-substitute-plugin components
*/}}
{{- define "argocd-appset-substitute-plugin.common.metaLabels" -}}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: {{ include "argocd-appset-substitute-plugin.chart" . }}
{{- with .Values.commonMetaLabels}}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "argocd-appset-substitute-plugin.controller.labels" -}}
{{ include "argocd-appset-substitute-plugin.controller.matchLabels" . }}
{{ include "argocd-appset-substitute-plugin.common.metaLabels" . }}
{{- end -}}

{{- define "argocd-appset-substitute-plugin.controller.matchLabels" -}}
app.kubernetes.io/component: {{ .Values.controller.name }}
{{ include "argocd-appset-substitute-plugin.common.matchLabels" . }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "argocd-appset-substitute-plugin.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified ClusterRole name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "argocd-appset-substitute-plugin.clusterRoleName" -}}
{{- if .Values.controller.clusterRoleNameOverride -}}
{{ .Values.controller.clusterRoleNameOverride | trunc 63 | trimSuffix "-" }}
{{- else -}}
{{ include "argocd-appset-substitute-plugin.controller.fullname" . }}
{{- end -}}
{{- end -}}


{{/*
Create a fully qualified argocd-appset-substitute-plugin controller name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "argocd-appset-substitute-plugin.controller.fullname" -}}
{{- if .Values.controller.fullnameOverride -}}
{{- .Values.controller.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.controller.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.controller.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Get KubeVersion removing pre-release information.
*/}}
{{- define "argocd-appset-substitute-plugin.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version (regexFind "v[0-9]+\\.[0-9]+\\.[0-9]+" .Capabilities.KubeVersion.Version) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "argocd-appset-substitute-plugin.deployment.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for rbac.
*/}}
{{- define "rbac.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1" }}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the controller component
*/}}
{{- define "argocd-appset-substitute-plugin.serviceAccountName.controller" -}}
{{- if .Values.serviceAccounts.controller.create -}}
    {{ default (include "argocd-appset-substitute-plugin.controller.fullname" .) .Values.serviceAccounts.controller.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.controller.name }}
{{- end -}}
{{- end -}}

{{/*
Define the prometheus.namespace template if set with forceNamespace or .Release.Namespace is set
*/}}
{{- define "argocd-appset-substitute-plugin.namespace" -}}
  {{- default .Release.Namespace .Values.forceNamespace -}}
{{- end }}

{{/*
Define template prometheus.namespaces producing a list of namespaces to monitor
*/}}
{{- define "argocd-appset-substitute-plugin.namespaces" -}}
{{- $namespaces := list }}
{{- if and .Values.rbac.create .Values.controller.useExistingClusterRoleName }}
  {{- if .Values.controller.namespaces -}}
    {{- range $ns := join "," .Values.controller.namespaces | split "," }}
      {{- $namespaces = append $namespaces (tpl $ns $) }}
    {{- end -}}
  {{- end -}}
  {{- if .Values.controller.releaseNamespace -}}
    {{- $namespaces = append $namespaces (include "argocd-appset-substitute-plugin.namespace" .) }}
  {{- end -}}
{{- end -}}
{{ mustToJson $namespaces }}
{{- end -}}

{{/*
Define the prometheus.namespace template if set with forceNamespace or .Release.Namespace is set
*/}}
{{- define "argocd-appset-substitute-plugin.controller.secret.token" -}}
{{- if .Values.controller.secret.token -}}
    {{- .Values.controller.secret.token | b64enc | trim -}}
{{- else -}}
  {{- $password := randAlphaNum 24 | nospace | b64enc | trim -}}
  {{- $password -}}
{{- end -}}
{{- end -}}
