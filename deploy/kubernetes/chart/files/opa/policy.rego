package esgf

default allow = false

allow = true {
    count(violation) == 0
}

has_group(name) {
    some i
    input.subject.groups[i] == name
}

{{- range .Values.opa.restrictedPaths }}
violation["{{ .name }}"] {
    regex.match("{{ .path }}", input.resource)
    not has_group("{{ .group }}")
}
{{- end }}
