#!/bin/sh
# Example crontab script to periodically harvest metadata from Solr repeaters
# Install as: 
# 0 0,4,8,12,16,20 * * * /usr/local/bin/solr_cloud_crontab.sh > /tmp/solr_cloud_crontab.log 2>&1

cd /usr/local/src/esgfpy-publish
export PYTHONPATH=.
python esgfpy/harvest/harvester.py 'http://esgf-node.jpl.nasa.gov:8983/solr' 'http://esgf-cloud.jpl.nasa.gov:8983/solr' --query 'index_node:esgf-node.jpl.nasa.gov'
python esgfpy/harvest/harvester.py 'http://esgf-node.jpl.nasa.gov:8985/solr' 'http://esgf-cloud.jpl.nasa.gov:8983/solr' --query 'index_node:esgdata.gfdl.noaa.gov'
python esgfpy/harvest/harvester.py 'http://esgf-node.jpl.nasa.gov:8986/solr' 'http://esgf-cloud.jpl.nasa.gov:8983/solr' --query 'index_node:esgf-data.dkrz.de'
python esgfpy/harvest/harvester.py 'http://esgf-node.jpl.nasa.gov:8987/solr' 'http://esgf-cloud.jpl.nasa.gov:8983/solr' --query 'index_node:esg-dn1.nsc.liu.se'
python esgfpy/harvest/harvester.py 'http://esgf-node.jpl.nasa.gov:8988/solr' 'http://esgf-cloud.jpl.nasa.gov:8983/solr' --query 'index_node:esgf-node.ipsl.upmc.fr'
python esgfpy/harvest/harvester.py 'http://esgf-node.jpl.nasa.gov:8989/solr' 'http://esgf-cloud.jpl.nasa.gov:8983/solr' --query 'index_node:esgf-index1.ceda.ac.uk'
python esgfpy/harvest/harvester.py 'http://esgf-node.jpl.nasa.gov:8990/solr' 'http://esgf-cloud.jpl.nasa.gov:8983/solr' --query 'index_node:pcmdi.llnl.gov'
python esgfpy/harvest/harvester.py 'http://esgf-node.jpl.nasa.gov:8991/solr' 'http://esgf-cloud.jpl.nasa.gov:8983/solr' --query 'index_node:esgf.nccs.nasa.gov'
