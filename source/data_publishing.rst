***************
Data Publishing
***************

*Tested with ESGF_VERSION=dev_1.4*

Description
===========

This page instructs on how to use the esgf-publisher Python client to
publish a sample dataset and file to the ESGF **tds** and **index** node
containers. These publishing instructions are meant to be executed inside the
**publisher** container. Additionally, the **postgres** contrainer is needed
to store publishing metadata, and the **orp** container is needed to enforce access
control (for publishing and downloading data).::

  docker-compose up 
  docker exec -it -u 0 publisher /bin/bash

One-Time Setup
==============

When it is first initialized, the TDS main catalog contains references
to its internal test datasets. This catalog must be replaced with the
standard ESGF main catalog (which is mounted onto the container as part
of the Docker distribution)::

  cd /esg/content/thredds
  mv catalog.xml-esgcet catalog.xml

Also, the postgres database must be initialized with the list of models,
experiments found in the file *esgcet_models_table.xml*: ::

  cd /esg/config/esgcet
  source ${CDAT_HOME}/bin/activate esgf-pub 
  esginitialize -c

(this step must actually be repeated any time that file changes).

The test file to be published should already be present at the location:
*/esg/data/test/sftlf.nc* . If not, it can be downloaded as::

  mkdir -p /esg/data/test
  cd /esg/data/test
  wget -O sftlf.nc http://distrib-coffee.ipsl.jussieu.fr/pub/esgf/dist/externals/sftlf.nc

Step 1
======

Generate the mapfile listing the dataset and files to be published:: 

  cd /esg/config/esgcet
  source ${CDAT_HOME}/bin/activate esgf-pub 
  esgprep mapfile --project test /esg/data/test
  ls -l mapfiles/test.test.map

Step 2
======

Publish to the postgres database::
  
  esgpublish --project test --map mapfiles/test.test.map --service fileservice
  esglist_datasets test

Step 3
======

Publish to the TDS::

  esgpublish --project test --map mapfiles/test.test.map --service fileservice --noscan --thredds

Note: this operation will use the credentials contained in the *esg.ini*
file to invoke the TDS re-initialization URL: 

* https://my-node.esgf.org:8443/thredds/admin/debug?Catalogs/reinit .

After the operation completes, the file should be accessible starting
from the TDS main catalog page: 

* http://my-node.esgf.org/thredds/catalog/catalog.html

and downloadable using any openid, password combination that is trusted
by the data-node. The authorization required for downloading the file is
specified inside the **orp** container in the access policy file: */esg/config/esgf_policies_local.xml*
as an XML statement of the form::

   <policy resource=".*test.*" attribute_type="AUTH_ONLY" attribute_value="" action="Read"/>


Step 4
======

Publish to Solr. Note: this step cannot be properly completed until the
ESGF/Docker data stack contains a MyProxy server (or other substitute)
that is able to issue short term X509 certificates for users managed by
the identity provider container. In the meantime, the following
workarounds can be adopted.

Obtain a short-term X509 certificate from any other trusted ESGF
identity provider, and copy it into the **publisher** container in the location
referenced by the file esg.ini::

  cp certificate-file /root/.globus/certificate-file

Then, disable the specific authorization for publishing test data, requiring only
the availability of an X509 certificate. Edit the file: */esg/config/esgf_policies_local.xml*
inside the **orp** container
and insert the following policy statement (as XML)::

  <policy resource=".*test.*" attribute_type="ANY" attribute_value="" action="Write"/>

At this point, you can issue the publishing command::

  esgpublish --project test --map mapfiles/test.test.map --service fileservice --noscan --publish

After about a minute, the dataset and file should be returned when
querying the "slave" Solr index:

* http://my-node.esgf.org/solr/#/datasets/query
* http://my-node.esgf.org/solr/#/files/query

Additionally, they should be returned when initiating a search from the
CoG user interface, if the project has searching enabled:

* https://my-node.esgf.org/search/testproject/
