#!/bin/bash
# script to start vsftp as part of ESGF services

# start vsftp service
service vsftpd restart

# keep container running
tail -f /dev/null
