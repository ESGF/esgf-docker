#!/bin/bash

# start Node Manager 
esgf-nm-ctl start
esgf-nm-ctl status

# keep container running
tail -f /esg/log/esgfnmd.out.log
