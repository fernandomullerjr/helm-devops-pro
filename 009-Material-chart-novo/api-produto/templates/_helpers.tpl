{{/* Nome do Service do MongoDB */}}
{{- define "mongodb.serviceName" -}}
{{ .Release.Name }}-mongodb
{{- end -}}