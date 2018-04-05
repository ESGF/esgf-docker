#####
## PostgreSQL container with support for:
##
##   * Running as any user, including those not in /etc/passwd
##     This is required by OpenShift's security policies and provided by the
##     PostgreSQL container from the RHSC, but not possible with the postgres
##     image from the Docker library
##
##   * Reading the password from a file instead of an environment variable
##     This is required for Docker's secrets, which cannot be used to populate
##     environment variables
##     The postgres image from the Docker library allows this, but the RHSC does not
#####

# Start from the RedHat Software Collections image, as most of the hard work is already done
FROM centos/postgresql-96-centos7

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Install a pre-start hook to set password variables from file
RUN mkdir -p "${APP_DATA}/src/postgresql-pre-start"
COPY passwords-from-file.sh $APP_DATA/src/postgresql-pre-start/
