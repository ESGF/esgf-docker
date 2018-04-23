---
title: Testing
category: Usage
order: 1.3
---

## Testing

These instructions describe how to test an ESGF node installation. They assume
the ESGF node has been started using `docker-compose` or `docker helm`.

We *recommend* that each developer executes these tests before issuing a pull request into the *devel* branch.
These tests *must* be executed before issuing a pull request into the *master* branch. 
In what follows, replace `$ESGF_HOSTNAME` with the specific hostname assigned to your node.

### Manual Testing

The following procedure can be used to manually test an ESGF Node installation using a browser.

* Solr admin interface: https:/$ESGF_HOSTNAME/solr/#/ . Check you can perform a basic search

* ESGF search API: http:///$ESGF_HOSTNAME/esg-search/search.

* ESGF IdP: https://$ESGF_HOSTNAME/esgf-idp/.

* CoG home project: https://$ESGF_HOSTNAME/projects/testproject/. Check you can login with the local credentials below, and with at least one other external openid:

openid=https://$ESGF_HOSTNAME/esgf-idp/openid/rootAdmin
password=<value from cat $ESGF_CONFIG/secrets/rootadmin-password>
 
* ORP: https://$ESGF_HOSTNAMEg/esg-orp/. Check you can login with the credentials above.

* TDS: https://$ESGF_HOSTNAME/thredds. Check you can browse the catalogs, and download one file after logging in.

* ESGF-Auth web client: https://$ESGF_HOSTNAME/esgf-auth/home/ . Check you can login with the openid and password above, and with at least one other external openid.

* SLCS: https://$ESGF_HOSTNAME/esgf-slcs/admin/. Check you can log in as root administrator using:

username=rootAdmin
password=<value from cat $ESGF_CONFIG/secrets/rootadmin-password>

* Test publishing a test dataset following the instructions at Data Publishing