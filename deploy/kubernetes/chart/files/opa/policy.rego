package esgf

default allow = false

# Determine access to the resource
allow = true {
    allowed_hosts[resource_host]
    count(violation) == 0
}

# Check that the user belongs to a certain group
has_group(name) {
    some i
    input.subject.groups[i] == name
}

# Separate parts of a resource URL, if applicable
parts := regex.find_all_string_submatch_n("^(?:(?:http|https|ftp):\/\/([^\/ ]*))?(\/.*)", input.resource, -1)
resource_host := parts[_][1]
resource_path := parts[_][2]

# Declare all allowed resource hosts
allowed_hosts := {
    "{{ .Values.hostname }}",
}

# Check requested path against restricted paths
{{- range .Values.opa.restrictedPaths }}
violation["{{ .name }}"] {
    regex.match("{{ .path }}", resource_path)
    not has_group("{{ .group }}")
}
{{- end }}
