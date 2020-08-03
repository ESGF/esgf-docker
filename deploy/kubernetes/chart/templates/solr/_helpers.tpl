{{/*
Produce the value for the Solr shardsWhitelist parameter.
*/}}
{{- define "esgf.solr.shardsWhitelist" -}}
{{- $solr := .Values.index.solr -}}
{{- if $solr.localEnabled -}}
{{- include "esgf.component.fullname" (list . "solr" "slave") }}:8983/solr
{{- else -}}
{{- $solr.slaveExternalUrl }}
{{- end -}}
{{- range $solr.replicas -}}
,{{ include "esgf.component.fullname" (list $ "solr" .name) }}:8983/solr
{{- end -}}
{{- end -}}
