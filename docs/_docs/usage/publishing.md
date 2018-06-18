---
title: Data Publishing
category: Usage
order: 1.4
---

## Test publication

These instructions demonstrate the use of the `esgf-publisher` container to publish
a sample dataset. It assumes that you have a running ESGF node - see
[Quick Start](../quick-start/).

### One time setup

Before running the publication, ensure that the test dataset exists in `ESGF_DATA`:

```sh
mkdir -p "$ESGF_DATA/test"
wget -O "$ESGF_DATA/test/sftlf.nc" http://distrib-coffee.ipsl.jussieu.fr/pub/esgf/dist/externals/sftlf.nc
```

### Start a publisher container instance

For an ad-hoc publish, create an instance of the publisher container to use:

```sh
docker-compose run esgf-publisher bash
```

This should open a bash shell inside a running publisher container that is already
pre-configured with database access and volumes. It will also ensure that `esginitialize`
is run.

All the remaining commands are executed in this shell.

### Fetch a certificate

This step fetches a certificate from the SLCS that is later used when publishing
to Solr. You should enter the username and password of a user on your ESGF node
who has the correct permissions for the project you are publishing to:

```sh
fetch-certificate
> [INFO] Fetching short-lived certificate from https://local.esgf.org/esgf-slcs/onlineca/certificate/
> Username: rootAdmin
> Password: ***
> [INFO]   Generating private key and CSR
> [INFO]   Fetching certificate
> [INFO] Complete
```

### Generate map files

```sh
esgprep mapfile --project test /esg/data/test
ls -l mapfiles
```

### Publish to the PostgreSQL database

```sh
esgpublish --project test --map mapfiles/test.test.map --service fileservice
esglist_datasets test
```

### Publish to the TDS

```sh
esgpublish --project test --map mapfiles/test.test.map --service fileservice --noscan --thredds
```

After the operation completes, the file should be accessible starting from the TDS
main catalog page, `https://${ESGF_HOSTNAME}/thredds/catalog/catalog.html`, and
downloadable using any openid, password combination that is trusted by the data-node.

The authorization required for downloading the file is specified inside the orp
container in the access policy file: `/esg/config/esgf_policies_local.xml` as an
XML statement of the form:

```xml
<policy resource=".*test.*" attribute_type="AUTH_ONLY" attribute_value="" action="Read"/>
```

### Publish to Solr

```sh
esgpublish --project test --map mapfiles/test.test.map --service fileservice --noscan --publish
```

After about a minute, the dataset and file should be returned when querying Solr:

  * `https://${ESGF_HOSTNAME}/solr/index.html#/datasets/query`
  * `https://${ESGF_HOSTNAME}/solr/index.html#/files/query`

Additionally, they should be returned when initiating a search from the CoG user
interface, if the project has searching enabled: `https://${ESGF_HOSTNAME}/search/testproject/`.
