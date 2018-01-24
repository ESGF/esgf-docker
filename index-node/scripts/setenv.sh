: ${ESGF_SOLR_PUBLISH_URL:="$ESGF_SOLR_URL"}
: ${ESGF_SOLR_QUERY_URL:="$ESGF_SOLR_URL"}

[ -z "$ESGF_SOLR_PUBLISH_URL" ] && {
    echo "ESGF_SOLR_PUBLISH_URL or ESGF_SOLR_URL must be specified" 1>&2
    exit 1
}
[ -z "$ESGF_SOLR_QUERY_URL" ] && {
    echo "ESGF_SOLR_QUERY_URL or ESGF_SOLR_URL must be specified" 1>&2
    exit 1
}
[ -z "$ESGF_ORP_URL" ] && {
    echo "ESGF_ORP_URL must be specified" 1>&2
    exit 1
}

echo "Using ESGF_SOLR_PUBLISH_URL: $ESGF_SOLR_PUBLISH_URL"
echo "Using ESGF_SOLR_QUERY_URL: $ESGF_SOLR_QUERY_URL"
echo "Using ESGF_ORP_URL: $ESGF_ORP_URL"

# We can't set properties in esgf.properties on the command line, but we can use
# this file to write it
cat <<EOF > /esg/config/esgf.properties
# URL of Solr server for publishing/unpublishing metadata (master solr)
esg.search.solr.publish.url=$ESGF_SOLR_PUBLISH_URL
# URL of Solr server for querying metadata (slave solr)
esg.search.solr.query.url=$ESGF_SOLR_QUERY_URL
# URL of authorization service used to authorize publishing operations
security.authz.service.endpoint=$ESGF_ORP_URL/esg-orp/saml/soap/secure/authorizationService.htm
EOF

export CATALINA_OPTS="-Xmx256m -server -Xms256m"
