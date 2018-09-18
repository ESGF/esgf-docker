#!/bin/sh

#####
## This script allows the setting of password environment variables from files
## in order to support Docker secrets
#####

PASSWORD_VARS=( POSTGRESQL_PASSWORD POSTGRESQL_ADMIN_PASSWORD POSTGRESQL_MIGRATION_ADMIN_PASSWORD )

for var in "${PASSWORD_VARS[@]}"; do
    # If the variable is already set, there is nothing to do
    [ -z "${!var:-}" ] || continue
    # If the filevar is not set, there is nothing to do
    filevar="${var}_FILE"
    [ -z "${!filevar:-}" ] && continue
    # If the file referenced by filevar doesn't exist, do nothing
    filepath="${!filevar}"
    [ -f "${filepath}" ] || continue
    # If we get this far, read the password from the file
    export "$var"="$(< "${filepath}")"
done
