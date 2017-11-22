.. _testing_guide:

*************
Testing Guide
*************

This document contains a list of tests that need to be executed to assert that a given ESGF/Docker release is fully functioning.

We **recommend** that each developer executes these tests before merging his/her changes into the *integration* branch for that release.

These tests **must** be executed before the *integration* branch is merged into the alpha/beta/rc/final branch of any release.

In what follows, replace *my-node.esgf.org* with your choice for $ESGF_HOSTNAME:

* Docker visualizer tool: http://my-node.esgf.org:8080/. Check all containers are up and running. Only when running with Docker Swarm on a multi-host environment - not when using Docker compose.
* Solr admin interface: https://my-node.esgf.org/solr/#/. Check you can perform a basic search.
* ESGF search API: http://my-node.esgf.org/esg-search/search.
* ESGF IdP: https://my-node.esgf.org/esgf-idp/.

   * Note that (for some yet unknow reason) the IdP may take up to 5 minutes to start properly, before which it looks like its URL is not found..

* CoG home project: https://my-node.esgf.org/projects/testproject/. Check you can login with the local credentials below,
  and with at least one other external openid:

   * openid=https://my-node.esgf.org/esgf-idp/openid/rootAdmin
   * password=changeit

* ORP: https://my-node.esgf.org/esg-orp/. Check you can login with the credentials above.
* TDS: https://my-node.esgf.org/thredds. Check you can browse the catalogs, and download one file after logging in.
* ESGF-Auth web client: https://my-node.esgf.org/esgf-auth/home/ . Check you can login with the openid and password above, 
  and with at least one other external openid.
* SLCS: https://my-node.esgf.org/esgf-slcs/admin/. Check you can log in as root administrator using:

  * username=rootAdmin
  * password=changeit

* Test publishing a test dataset following the instructions at :ref:`data_publishing`.

