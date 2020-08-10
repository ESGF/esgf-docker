{{/*
Produce the value for the Solr shardsWhitelist parameter.
*/}}
{{- define "esgf.solr.shardsWhitelist" -}}
{{- $solr := .Values.index.solr -}}
{{- if $solr.enabled -}}
{{- include "esgf.component.fullname" (list . "solr" "slave") }}:8983/solr
{{- range $solr.replicas -}}
,{{ include "esgf.component.fullname" (list $ "solr" .name) }}:8983/solr
{{- end -}}
{{- else -}}
{{- $solr.slaveExternalUrl -}}
{{- range $solr.replicas -}}
,{{- .masterUrl | required "Replica masterUrl is required" -}}
{{- end -}}
{{- end -}}
{{- end -}}
