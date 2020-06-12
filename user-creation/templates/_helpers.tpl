{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "user-creation.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "user-creation.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "user-creation.labels" -}}
helm.sh/chart: {{ include "user-creation.chart" . }}
{{ include "user-creation.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "user-creation.selectorLabels" -}}
app.kubernetes.io/name: {{ include "user-creation.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

