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
In what follows, replace `my-node.esgf.org` with the specific hostname assigned to your node.

### Manual Testing

The following procedure can be used to manually test an ESGF node installation using a browser.

* `CoG` home project: 
	* <https://my-node.esgf.org/projects/testproject/>
	* Check you can login with the local credentials below, and with at least one other external openid:
		* openid=https://my-node.esgf.org/esgf-idp/openid/rootAdmin
		* password=<value from cat $ESGF_CONFIG/secrets/rootadmin-password>

* `Solr` admin interface: 
	* <https://my-node.esgf.org/solr/#/>
	* Check you can perform a basic search.

* `ESGF search` API: 
	* <http://my-node.esgf.org/esg-search/search>

* `ESGF IdP`: 
	* <https://my-node.esgf.org/esgf-idp/>
 
* `ESGF ORP`: 
	* <https://my-node.esgf.org/esg-orp/>
	* Check you can login with the credentials above.

* `TDS`: 
	* <https://my-node.esgf.org/thredds> 
	* Check you can browse the catalogs, and download one file after logging in.

* `ESGF-Auth` web client: 
	* <https://my-node.esgf.org/esgf-auth/home/>
	* Check you can login with the openid and password above, and with at least one other external openid.

* `SLCS`: 
	* <https://my-node.esgf.org/esgf-slcs/admin/> 
	* Check you can log in as root administrator using:
		* username=rootAdmin
		* password=<value from cat $ESGF_CONFIG/secrets/rootadmin-password>

* Test publishing a test dataset following the instructions at [Data Publishing](/usage/publishing/)

### Automatic Testing

The following process can be used to automatically execute some basic tests versus an ESGF node installation.

TO BE COMPLETED.