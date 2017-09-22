  #!/bin/bash
# Script to generate certificates needed for an ESGF node with a given $ESGF_HOSTNAME
# All certificates are generated in the directory $ESGF_CONFIG/esgfcerts, then moved to the proper location under $ESGF_CONFIG

readonly BASE_DIR_PATH="$(pwd)"
SCRIPT_PARENT_DIR_PATH="$(dirname $0)"; cd "${SCRIPT_PARENT_DIR_PATH}"
readonly SCRIPT_PARENT_DIR_PATH="$(pwd)" ; cd "${BASE_DIR_PATH}"

source "${SCRIPT_PARENT_DIR_PATH}/common"

readonly DEFAULT_VERSION=${ESGF_VERSION-latest}

images_hub="${DEFAULT_IMAGES_HUB}"
esgf_ver="${DEFAULT_VERSION}"

# verify env variables are set
if [ "${ESGF_HOSTNAME}" = "" ] || [ "${ESGF_CONFIG}" = "" ];
then
   echo "All env variables: ESGF_HOSTNAME and ESGF_CONFIG must be set  "
   exit -1
else
   echo "Using ESGF_HOSTNAME=$ESGF_HOSTNAME"
   echo "Using ESGF_CONFIG=$ESGF_CONFIG"
   echo "Using ESGF_VERSION=$esgf_ver"
   echo "Using ESGF_IMAGES_HUB=$images_hub"
fi

# working directory
mkdir -p $ESGF_CONFIG/esgfcerts
cd $ESGF_CONFIG/esgfcerts
cp ../esg/config/tomcat/esg-truststore.ts ./esg-truststore.ts
cp ../httpd/certs/esgf-ca-bundle.crt-orig ./esgf-ca-bundle.crt

# generate host private key hostkey.pem, certificate hostcert.pem
echo ""
echo "Generating host certificate, key for $ESGF_HOSTNAME"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout hostkey.pem -out hostcert.pem -subj "/C=/ST=/L=/O=ESGF/OU=/CN=$ESGF_HOSTNAME"

# convert certificate to pkcs12 format
echo ""
echo "Converting certificate to pkcs12 format"
openssl pkcs12 -export -out hostcert.pkcs12 -in hostcert.pem -inkey hostkey.pem -password pass:changeit

# convert certificate to keystore
echo ""
echo "Converting to keystore format"
rm -f hostcert.jks
keytool -importkeystore -srckeystore hostcert.pkcs12 -srcstoretype pkcs12 -destkeystore hostcert.jks -srcstorepass changeit -deststorepass changeit
# change alias to 'my_esgf_node'
keytool -changealias -v -alias 1 -destalias my_esgf_node -keystore hostcert.jks -storepass changeit

# append to apache httpd cert chain (httpd must trust itself):
cat hostcert.pem >> esgf-ca-bundle.crt

# create certificate hash
# (pointed to by SSL_CERT_DIR, needed by coG for openid authentication)
# IMPORTANT: hashing algorithm MUST be run inside container
echo ""
echo "Generating certificate hash"

cert_hash=`docker run -ti --rm -v $ESGF_CONFIG/esgfcerts/:/tmp/certs/ $images_hub/esgf-node:$esgf_ver openssl x509 -noout -hash -in /tmp/certs/hostcert.pem`
#cert_hash=`openssl x509 -noout -hash -in hostcert.pem`
# must remove the trailing white space i.e. end of line
cert_hash=${cert_hash%%[[:space:]]}
cp hostcert.pem ${cert_hash}.0

# import self-signed certificate into ESGF truststore
echo ""
echo "Importing host certificate into ESGF trust-store"
# remove previous alias from truststore:
keytool -delete -alias my_esgf_node -keystore esg-truststore.ts -storepass changeit
# import apache self-signed cert into truststore
keytool -import -v -trustcacerts -noprompt  -alias my_esgf_node -keypass changeit -file hostcert.pem -keystore esg-truststore.ts -storepass changeit

# copy all certificates to their target location
# apache httpd
cp hostcert.pem $ESGF_CONFIG/httpd/certs/hostcert.pem
cp hostkey.pem $ESGF_CONFIG/httpd/certs/hostkey.pem
cp esgf-ca-bundle.crt $ESGF_CONFIG/httpd/certs/esgf-ca-bundle.crt
# cog, gridftp
cp hostcert.pem $ESGF_CONFIG/grid-security/hostcert.pem
cp hostkey.pem $ESGF_CONFIG/grid-security/hostkey.pem
cp ${cert_hash}.0 $ESGF_CONFIG/grid-security/certificates/${cert_hash}.0
# tomcat
cp esg-truststore.ts $ESGF_CONFIG/esg/config/tomcat/esg-truststore.ts
cp hostcert.jks $ESGF_CONFIG/esg/config/tomcat/keystore-tomcat