{{/*
Templates for connecting to databases.
*/}}

{{- define "esgf.database.host" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- template "esgf.component.fullname" (list . "database") -}}
  {{- else -}}
    {{- .Values.database.external.host | required "Specify an external database host" -}}
  {{- end -}}
{{- end -}}

{{- define "esgf.database.port" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "5432" -}}
  {{- else -}}
    {{- .Values.database.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "esgf.database.user" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "dbsuper" -}}
  {{- else -}}
    {{- .Values.database.external.user | required "Specify an external database user" -}}
  {{- end -}}
{{- end -}}

{{- define "esgf.database.password" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.password -}}
  {{- else -}}
    {{- .Values.database.external.password | required "Specify an external database password" -}}
  {{- end -}}
{{- end -}}

{{- define "esgf.database.securityDatabase" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "esgcet" -}}
  {{- else -}}
    {{- .Values.database.external.securityDatabase | required "Specify an external security database name" -}}
  {{- end -}}
{{- end -}}

{{- define "esgf.database.slcsDatabase" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "esgcet" -}}
  {{- else -}}
    {{- .Values.database.external.slcsDatabase | required "Specify an external SLCS database name" -}}
  {{- end -}}
{{- end -}}
