This directory contains a set of script to setup an ESGF node installation
on a cluster of 3 cloud nodes running Docker Engine 1.12+

The ESGF software stack is deployed as follows:

o node1 (acce-build1.dyndns.org): ESGF front-end composed of postgres database, idp, cog application, httpd daemon
o node2 (acce-build2.dyndns.org): ESGF data node composed of TDS and ORP applications
o node3 (acce-build3.dyndns.org): ESGF index node composed of Solr and ESGF search application

The setup scripts must be executed in order, on the appropriate node.

