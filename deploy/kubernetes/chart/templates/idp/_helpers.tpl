{{- define "esgf.idp.endpoint.openid" -}}
  {{- printf "https://%s/esgf-idp/idp/openidServer.htm" .Values.hostname -}}
{{- end -}}

{{- define "esgf.idp.endpoint.attributeService" -}}
  {{- printf "https://%s/esgf-idp/saml/soap/secure/attributeService.htm" .Values.hostname -}}
{{- end -}}

{{- define "esgf.idp.endpoint.registrationService" -}}
  {{- printf "https://%s/esgf-idp/secure/registrationService.htm" .Values.hostname -}}
{{- end -}}
