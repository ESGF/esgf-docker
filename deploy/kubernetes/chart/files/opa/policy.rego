package esgf

default allow = true

allow {
    regex.match("^/thredds/(fileServer|dodsC)/esg_cordex/.*", input.resource)
    input.subject.groups[_] = "/cordex_research"
}

allow {
    regex.match("^/esg-search/ws/publish", input.resource)
    input.subject.groups[_] = "/cordex_research/publish"
}

allow {
    regex.match("^/login/.*", input.resource)
}

allow {
    regex.match("^/esg-search/.*", input.resource)
}

allow {
    regex.match("^/thredds/.*", input.resource)
}


#allow = true {                                      # allow is true if...
#    count(violation) == 0                           # there are zero violations.
#}

#violation["cordex"] {
#    regex.match("^/thredds/(fileServer|dodsC)/esg_cordex/.*", input.resource)
#    input.subject.name == "wtucker"
#}

#violation["cordex_publish"] {
#    regex.match("^/esg-search/ws/publish", input.resource)
#    input.subject.groups[_] = "/cordex_research/publish"
#}

