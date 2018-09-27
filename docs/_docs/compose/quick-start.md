---
title: Quick Start
category: Docker Compose
order: 1.1
---

This page describes the steps required to launch a test environment using
[Docker Compose](https://docs.docker.com/compose/) that is:

  * A full, self-contained node (all components deployed and wired to talk to each other)
  * Not part of a federation
  * Using self-signed certificates

## Pre-requisites

The only pre-requisites are a Bash shell and recent versions of Docker Engine and
Docker Compose on the host system.

## Configure environment

First, clone the `esgf-docker` repository:

```sh
git clone https://github.com/ESGF/esgf-docker.git
cd esgf-docker
```

Next, create an empty directory to store the configuration for the deployment and set
the `ESGF_CONFIG` environment variable to point to it:

```sh
export ESGF_CONFIG=/path/to/config/directory
mkdir -p $ESGF_CONFIG
```

Create an `environment` file in `ESGF_CONFIG` that configures the required environment
variables for the deployment. In this case, only the hostname and data directory are
required:

```sh
cat > "$ESGF_CONFIG/environment" <<EOF
ESGF_HOSTNAME=local.esgf.org
ESGF_DATA=/path/to/data/directory
EOF
```

The hostname should be a DNS name that resolves to the **non-loopback address**
of the current machine (i.e. **not** `127.0.0.1`). This is because the containers
make HTTP calls to `ESGF_HOSTNAME`, so it **cannot** be `localhost` or any other
DNS name that has been configured to resolve to `127.0.0.1`, as that would cause
the container to try to contact itself.

<div class="note note-warning" markdown="1">
The Java SSL implementation does not like IP addresses as hostnames, so `ESGF_HOSTNAME`
**must** be a domain name and not an IP address.

To create a domain name to IP mapping on the local machine, just add an entry to
`/etc/hosts` on Linux, or `/private/etc/hosts` on Mac. Alternatively, you can
use an [xip.io](http://xip.io/) domain, which are of the form `<ip address>.xip.io`.
</div>

<div class="note note-info" markdown="1">
To find out the IP addresses of the current machine, use either `ifconfig` or `ip addr`
depending on which command is available.
</div>

<div class="note note-warning" markdown="1">
On a Mac, the Docker daemon can only mount files in your home directory into containers.
This means you need to make sure that the `ESGF_CONFIG` and `ESGF_DATA` directories are
in your home directory.
</div>

## Generate configuration

Once you have exported the environment variables, run the following commands to
generate deployment secrets, self-signed certificates and the trusted certificate
bundle:

```sh
./bin/esgf-setup generate-secrets
./bin/esgf-setup generate-test-certificates
./bin/esgf-setup create-trust-bundle
```

If you experience permissions issues you can run:

```sh
chmod +r "${ESGF_CONFIG}/certificates/hostcert/hostcert.key"
chmod +r "${ESGF_CONFIG}/certificates/slcsca/ca.key"
```

## Launch containers

After generating the configuration, you are ready to launch the containers using
Docker Compose:

```sh
./bin/esgf-compose up -d
```

This will pull all the images from Docker Hub (unless they are already available
locally) and launch the containers in order.

Once all the containers are running normally, navigate to `https://$ESGF_HOSTNAME`
in a browser and you should see the CoG interface. You can view the container
logs using commands of the form:

```sh
./bin/esgf-compose logs [-f] esgf-{cog,search,idp,orp,slcs,...}
```

where the optional `-f` means "follow", as in `tail -f`.

Try to log in with the OpenID `https://$ESGF_HOSTNAME/esgf-idp/openid/rootAdmin`.
To find the `rootAdmin` password that was randomly generated for you, run the
following command:

```sh
echo "$(cat "$ESGF_CONFIG/secrets/rootadmin-password")"
```

## Stop containers

To stop the containers:

```sh
./bin/esgf-compose stop
```

To remove all the containers and associated data volumes:

```sh
./bin/esgf-compose down -v
```
