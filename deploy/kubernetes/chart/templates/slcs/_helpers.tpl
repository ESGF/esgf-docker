{{- define "esgf.slcs.endpoint.authorize" -}}
  {{- printf "https://%s/esgf-slcs/oauth/authorize" .Values.hostname -}}
{{- end -}}

{{- define "esgf.slcs.endpoint.accessToken" -}}
  {{- printf "https://%s/esgf-slcs/oauth/access_token" .Values.hostname -}}
{{- end -}}

{{- define "esgf.slcs.endpoint.certificate" -}}
  {{- printf "https://%s/esgf-slcs/oauth/certificate/" .Values.hostname -}}
{{- end -}}
