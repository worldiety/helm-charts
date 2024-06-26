{{/* vim: set filetype=mustache: */}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "project-template.fullname" -}}
{{- printf "%s-%s" .Values.name .Values.namespace | replace "ä" "ae" |replace "ö" "oe" | replace "ü" "ue" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "project-template.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Replaces the / in the namespace to an -.
*/}}
{{- define "project-template.namespace" -}}
{{- printf "%s" .Values.namespace | replace "/" "-" -}}
{{- end -}}

{{/*
Project Domain

Every application has its own unique domain {NAMESPACE}-{NAME}.{CLUSTER-DOMAIN}, e.g.:
helm-example-1-example-1.delta.k8s-wdy.de
^ NAMESPACE    ^ NAME    ^ CLUSTER-DOMAIN

*/}}
{{- define "project-template.domain" -}}
{{- $clusterdomain := "delta.k8s-wdy.de" -}}
{{- printf "%s-%s.%s" .Values.namespace .Values.name $clusterdomain -}}
{{- end -}}

{{/*
ImagePullSecret name
*/}}
{{- define "project-template.image-pull-secret-name" -}}
{{- $fullName := include "project-template.fullname" . -}}
{{- printf "%s-image-pull-secret-name" $fullName -}}
{{- end -}}

{{/*
ImagePullSecret data
*/}}
{{- define "project-template.image-pull-secret-data" -}}
{{- $registry := .Values.gitlabImage.registry -}}
{{- $registryUser := .Values.gitlabImage.user -}}
{{- $registryPassword := .Values.gitlabImage.password -}}
{{- $registryAuth := printf "%s:%s" $registryUser $registryPassword | b64enc -}}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" $registry $registryUser $registryPassword $registryAuth | b64enc -}}
{{- end -}}

{{/*
Filter custom domains by buildtype

We concatenate "TRUE" for every found domain.
*/}}
{{- define "project-template.filteredcustomdomains" -}}
{{- $buildtype := .Values.buildtype -}}
{{ $customhosts := .Values.customhosts }}
{{range $customhosts }}
{{ if eq .buildtype $buildtype }}
"TRUE"
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Annotations
*/}}
{{- define "project-template.annotations" -}}
# We use this annotation to enforce a regeneration of the pod.
# Source: https://v3.helm.sh/docs/howto/charts_tips_and_tricks/#automatically-roll-deployments
rollme: {{ randAlphaNum 5 | quote }}
{{- end -}}

{{/*
Annotations for noindex and nofollow
*/}}
{{- define "project-template.noindexandnofollow" -}}
nginx.ingress.kubernetes.io/server-snippet: |-
      add_header X-Robots-Tag "noindex, nofollow";
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
wdy.ci.buildtype: {{ .Values.buildtype }}
wdy.owner: wdy
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "project-template.selectorLabels" -}}
app.kubernetes.io/name: {{ include "project-template.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Creates the full env vars secret name.
*/}}
{{- define "project-template.environment-variables-secret-name" -}}
{{- $fullName := include "project-template.fullname" . -}}
{{- printf "%s-env-vars-secret-name" $fullName -}}
{{- end -}}

{{/*
List of environment variables.
*/}}
{{- define "project-template.environment-variables-list"}}
{{- $secretName := include "project-template.environment-variables-secret-name" . -}}
{{- range $key, $val := .Values.environmentVariables }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ $key }}
{{- end}}
{{- end }}

{{/*
Get and validate the PriorityClassName values.
Default values are set in the `values.yaml` of this Helm Chart
and will be overwritten by the `deployment-values.yaml`.
*/}}
{{- define "project-template.get-priorityClassName" -}}
{{- $buildtype := .Values.buildtype -}}
{{- $priorityClassName := get .Values.priorityClasses $buildtype -}}
{{- if empty $priorityClassName }}
{{- fail "No PriorityClassName provided. This is required, use e.g. 'wdy-develop'." -}}
{{- end -}}
{{- if not (hasPrefix "wdy-" $priorityClassName) }}
{{- fail "Only wdy priority classes must be used!" -}}
{{- end -}}
{{- printf "%s" $priorityClassName -}}
{{- end -}}
