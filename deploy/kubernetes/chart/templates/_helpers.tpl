{{/*
Expand the name of a component.
*/}}
{{- define "esgf.component.name" -}}
  {{- $context := index . 0 -}}
  {{- printf "%s-%s" $context.Chart.Name (index . 1 | kebabcase) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified component name for a named component.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If the release name contains the chart or component name, it is not duplicated.
*/}}
{{- define "esgf.component.fullname" -}}
  {{- $context := index . 0 -}}
  {{- $name := include "esgf.component.name" . -}}
  {{- if contains $context.Release.Name $name -}}
    {{- $name | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "%s-%s" $context.Release.Name $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}

{{/*
Common labels for a component.
*/}}
{{- define "esgf.component.labels" -}}
{{- $context := index . 0 -}}
helm.sh/chart: {{ printf "%s-%s" $context.Chart.Name $context.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- if $context.Chart.AppVersion }}
app.kubernetes.io/version: {{ $context.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $context.Release.Service }}
{{ include "esgf.component.selectorLabels" . }}
{{- end -}}

{{/*
Selector labels for a component.
*/}}
{{- define "esgf.component.selectorLabels" -}}
{{- $context := index . 0 -}}
app.kubernetes.io/name: {{ $context.Chart.Name }}
app.kubernetes.io/instance: {{ $context.Release.Name }}
app.kubernetes.io/component: {{ index . 1 }}
{{- end -}}

{{/*
Produces an image specification.
*/}}
{{- define "esgf.component.image" -}}
{{- $context := index . 0 -}}
{{- $component := index . 1 -}}
{{- $image := mergeOverwrite $context.Values.image $component.image -}}
image: {{ printf "%s/%s:%s" $image.prefix $image.repository $image.tag }}
imagePullPolicy: {{ $image.pullPolicy }}
{{- end -}}

{{/*
Produces an image specification with the correct nesting for use in deployments.
*/}}
{{- define "esgf.deployment.image" -}}
{{- include "esgf.component.image" . | indent 10 | trim -}}
{{- end -}}

{{/*
Produces a volume name from a mount path
*/}}
{{- define "esgf.data.volumeName" -}}
{{- regexReplaceAll "[^a-zA-Z0-9]+" . "-" | trimAll "-" -}}
{{- end -}}

{{/*
Produces volume definitions for the specified data volumes.
*/}}
{{- define "esgf.data.volumes" -}}
{{- range .Values.data.mounts }}
- name: {{ include "esgf.data.volumeName" .mountPath | quote }}
  {{- toYaml .volume | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Produces volume mount definitions for the specified data volumes.
*/}}
{{- define "esgf.data.volumeMounts" -}}
{{- range .Values.data.mounts }}
- name: {{ include "esgf.data.volumeName" .mountPath | quote }}
  readOnly: true
  {{- with (omit . "volume") }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
{{- end -}}
