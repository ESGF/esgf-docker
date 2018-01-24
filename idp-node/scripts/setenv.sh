#: ${ESGF_SOLR_PUBLISH_URL:="$ESGF_SOLR_URL"}
#: ${ESGF_SOLR_QUERY_URL:="$ESGF_SOLR_URL"}

#[ -z "$ESGF_SOLR_PUBLISH_URL" ] && {
#    echo "ESGF_SOLR_PUBLISH_URL or ESGF_SOLR_URL must be specified" 1>&2
#    exit 1
#}
#[ -z "$ESGF_SOLR_QUERY_URL" ] && {
#    echo "ESGF_SOLR_QUERY_URL or ESGF_SOLR_URL must be specified" 1>&2
#    exit 1
#}
[ -z "$ESGF_IDP_URL" ] && {
    echo "ESGF_IDP_URL must be specified" 1>&2
    exit 1
}
[ -z "$ESGF_DB_HOST" ] && {
    echo "ESGF_DB_HOST must be specified" 1>&2
    exit 1
}
: ${ESGF_DB_PORT:="5432"}
[ -z "$ESGF_DB_PASSWORD" ] && {
    echo "ESGF_DB_PASSWORD must be specified" 1>&2
    exit 1
}
[ -z "$ESGF_SLCS_URL" ] && {
    echo "ESGF_SLCS_URL must be specified" 1>&2
    exit 1
}

#echo "Using ESGF_SOLR_PUBLISH_URL: $ESGF_SOLR_PUBLISH_URL"
#echo "Using ESGF_SOLR_QUERY_URL: $ESGF_SOLR_QUERY_URL"
echo "Using ESGF_IDP_URL: $ESGF_IDP_URL"
echo "Using ESGF_DB_HOST: $ESGF_DB_HOST"
echo "Using ESGF_DB_PORT: $ESGF_DB_PORT"
echo "Using ESGF_SLCS_URL: $ESGF_SLCS_URL"

# We can't set properties in esgf.properties on the command line, but we can use
# this file to write it
cat <<EOF > /esg/config/esgf.properties
idp.service.endpoint=$ESGF_IDP_URL/esgf-idp/idp/openidServer.htm
idp.security.attribute.service.endpoint=$ESGF_IDP_URL/esgf-idp/saml/soap/secure/attributeService.htm
# postgres connection parameters
db.database=esgcet
db.driver=org.postgresql.Driver
db.protocol=jdbc:postgresql:
db.host=$ESGF_DB_HOST
db.port=$ESGF_DB_PORT
db.managed=no
db.user=dbsuper
db.password=$ESGF_DB_PASSWORD
# short lived certificate server
short.lived.certificate.server=$ESGF_SLCS_URL
EOF

# Create esgf_ats.xml config file using command line varaibles
cat <<EOF > /esg/config/esgf_ats.xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<ats_whitelist xmlns="http://www.esgf.org/whitelist">
    <attribute type="wheel" attributeService="$ESGF_IDP_URL/esgf-idp/saml/soap/secure/attributeService.htm" description="Administrator Group"/>
</ats_whitelist>
EOF

export CATALINA_OPTS="-Xmx256m -server -Xms256m"
