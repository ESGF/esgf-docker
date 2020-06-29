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
{{- with $context.Values.extraLabels }}
{{ toYaml . }}
{{- end }}
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
{{- $overrides := index . 1 -}}
{{- $image := deepCopy $context.Values.image | merge $overrides -}}
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
Produces a volume name for the given volume configuration.
*/}}
{{- define "esgf.data.volumeName" -}}
{{- if .name -}}
{{- .name -}}
{{- else -}}
{{- regexReplaceAll "[^a-zA-Z0-9]+" .mountPath "-" | trimAll "-" -}}
{{- end -}}
{{- end -}}

{{/*
Produces pod volume definitions for the configured data volumes.
*/}}
{{- define "esgf.data.volumes" -}}
{{- range .Values.data.mounts }}
- name: {{ include "esgf.data.volumeName" . | quote }}
  {{ toYaml .volumeSpec | indent 2 | trim }}
{{- end }}
{{- end -}}

{{/*
Produces volume mount definitions for the specified data volumes.

The produced mounts will always be read-only.
*/}}
{{- define "esgf.data.volumeMounts" -}}
{{- range .Values.data.mounts }}
- name: {{ include "esgf.data.volumeName" . | quote }}
  mountPath: {{ .mountPath }}
  readOnly: true
  {{- with (omit (default dict .mountOptions) "readOnly") }}
  {{ toYaml . | indent 2 | trim }}
  {{- end }}
{{- end }}
{{- end -}}
