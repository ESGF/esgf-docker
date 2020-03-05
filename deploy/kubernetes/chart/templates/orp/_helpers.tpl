{{- define "esgf.orp.endpoint.authorizationService" -}}
  {{- printf "https://%s/esg-orp/saml/soap/secure/authorizationService.htm" .Values.hostname -}}
{{- end -}}
