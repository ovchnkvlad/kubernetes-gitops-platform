{{- define "platform-status.name" -}}
platform-status
{{- end }}

{{- define "platform-status.labels" -}}
app.kubernetes.io/name: {{ include "platform-status.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}

{{- define "platform-status.selectorLabels" -}}
app.kubernetes.io/name: {{ include "platform-status.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
