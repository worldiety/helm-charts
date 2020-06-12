{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "project-template.fullname" -}}
{{- printf "%s-%s" .Values.name .Values.namespace -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "project-template.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Project Domain

Every application has its own unique domain {NAME}-{NAMESPACE}.{CLUSTER-DOMAIN}, e.g.:
example-1-helm-example-1.delta.k8s-wdy.de
^ NAME    ^ NAMESPACE    ^ CLUSTER-DOMAIN

*/}}
{{- define "project-template.domain" -}}
{{- $clusterdomain := "delta.k8s-wdy.de" -}}
{{- printf "%s-%s.%s" .Values.name .Values.namespace $clusterdomain -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "project-template.labels" -}}
helm.sh/chart: {{ include "project-template.chart" . }}
{{ include "project-template.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
wdy.app: {{ .Values.name }}
wdy.contact: {{ .Values.contact.name | replace " " "_" }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "project-template.selectorLabels" -}}
app.kubernetes.io/name: {{ include "project-template.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}