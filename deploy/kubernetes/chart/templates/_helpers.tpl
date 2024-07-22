{{/*
Expand the name of a component.

The arguments are given to the template as a list where the first element is the top
context and the rest of the elements are components of the name.
*/}}
{{- define "esgf.component.name" -}}
  {{- $context := first . -}}
  {{- $name := rest . | join "-" | kebabcase -}}
  {{- printf "%s-%s" $context.Chart.Name $name | trunc 63 | trimSuffix "-" -}}
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
Common labels for a component. The context should be a list consisting of:

  * Top context
  * Component name
  * Component-specific extra labels (optional)
*/}}
{{- define "esgf.component.labels" -}}
{{- $context := index . 0 -}}
helm.sh/chart: {{ printf "%s-%s" $context.Chart.Name $context.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- if $context.Chart.AppVersion }}
app.kubernetes.io/version: {{ $context.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $context.Release.Service }}
{{ include "esgf.component.selectorLabels" . }}
{{- with $context.Values.globalLabels }}
{{ toYaml . }}
{{- end }}
{{- with (index . 2) }}
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

{{/*
Generate TLS config for ingress.
*/}}
{{- define "esgf.ingress.tls" }}
{{- if .Values.ingress.tls.enabled }}
tls:
  - hosts:
      - {{ .Values.hostname | quote }}
    {{- if .Values.ingress.tls.secretName }}
    secretName: {{ .Values.ingress.tls.secretName }}
    {{- else }}
    secretName: {{ include "esgf.component.fullname" (list . "hostcert") }}
    {{- end }}
{{- end }}
{{- end }}

{{/*
Generate auth config for ingress.
*/}}
{{- define "esgf.ingress.auth" }}
{{- if .Values.auth.enabled }}
nginx.ingress.kubernetes.io/auth-url: http://{{ include "esgf.component.fullname" (list . "auth") }}.{{ .Release.Namespace }}.svc.cluster.local:8080/verify/
{{- if .Values.ingress.authSignin }}
nginx.ingress.kubernetes.io/auth-signin: {{ .Values.ingress.authSignin }}
{{- else }}
nginx.ingress.kubernetes.io/auth-signin: https://$host/login/
{{- end }}
{{- end }}
{{- end }}
