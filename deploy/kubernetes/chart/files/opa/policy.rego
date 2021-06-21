{{- $opa := .Values.opa -}}
package esgf

default allow = false

allow = true {
    count(violation) == 0
}

{{- range .opa.restrictedPaths }}
violation[{{ .name }}] {
    regex.match("{{ .path }}", input.resource)
    not input.subject.user
}
{{- end }}
