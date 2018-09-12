---
title: Configuration
category: Docker Compose
order: 1.2
---

The ESGF Docker containers are configured using a combination of environment
variables and files from a configuration directory with a particular structure.
As a general rule, environment variables are used to connect the deployed
components together, and are wired up by the Docker Compose file. The contents
of the configuration directory is used for external configuration such as
secrets, certificates and configuration of external services.

Before starting the ESGF Docker containers, the configuration directory pointed to by
the `ESGF_CONFIG` environment variable must have a particular structure as
described on this page. Many of these files are optional, and sensible defaults are
built into the containers. Others are required for a successful deployment.

For a local test installation with self-signed certificates, the entire configuration
structure can be generated. For a production installation, some parts will need to be
created manually, but some parts will still need to be generated.

The utilities for generating configuration have been bundled into the `esgfhub/setup`
container image, meaning that the only requirement on the host system is Docker.

## Required structure

```bash
$ESGF_CONFIG
|   # REQUIRED
|   # Environment variables for the deployment
├── environment
|
|   # OPTIONAL
|   # YAML file containing information about the remote Solr shards to deploy
├── solr_shards.yaml
|
|   # OPTIONAL
|   # Configuration overrides for esgf-auth
├── auth
|   |   # OPTIONAL
|   |   # OAuth2 credentials
|   |   #   By default, esgf-auth has no OAuth2 credentials for any sites
│   ├── esgf_oauth2.json
|   └── # ... other advanced files (see container) ...
|
|   # REQUIRED
|   # Certificates for the deployment
├── certificates
|   |   # GENERATED
|   |   # PEM-encoded bundle of trusted certificates
│   ├── esg-trust-bundle.pem
|   |   # OPTIONAL
|   |   # Tarball of trusted certificates to include in trust bundle,
|   |   # as downloaded from an ESGF distribution site
│   ├── esg_trusted_certificates.tar
|   |   # REQUIRED
|   |   # PEM-encoded SSL certificate and key
|   |   #   hostcert.crt should contain the host certificate AND CHAIN
|   |   #   Self-signed certificates for testing can be generated
│   ├── hostcert
│   │   ├── hostcert.crt
│   │   └── hostcert.key
|   |   # REQUIRED for esgf-slcs
|   |   # PEM-encoded CA certificate and key for SLCS
|   |   #    Self-signed certificates
│   └── slcsca
│       ├── ca.crt
│       └── ca.key
|
|   # OPTIONAL
|   # Configuration overrides for /esg/config
|   #   A utility exists to download static files from an ESGF distibution site
├── config
│   ├── esgf_ats_static.xml
│   ├── esgf_cogs.xml
│   ├── esgf_endpoints.xml
│   ├── esgf_idp_static.xml
│   ├── esgf_known_providers.xml
│   ├── esgf_search_aliases.xml
│   └── # ... other advanced files (see container) ...
|
|   # OPTIONAL
|   # Configuration overrides for /esg/config/esgcet
├── publisher
|   └── # ... config files ...
|
|   # REQUIRED
|   # Deployment secrets, i.e. passwords and secret keys
|   #   Random secrets can be generated, or files can be populated manually
|   #   for integratation with existing components (or a combination of both)
├── secrets
│   ├── auth-database-password
│   ├── auth-secret-key
│   ├── cog-database-password
│   ├── cog-secret-key
│   ├── esgcet-database-password
│   ├── rootadmin-password
│   ├── security-database-password
│   ├── shared-cookie-secret-key
│   ├── slcs-database-password
│   └── slcs-secret-key
|
|   # OPTIONAL
|   # Configuration overrides for esgf-tds (advanced)
|   #   Only overrides THREDDS configuration - catalog is controlled by publisher
└── thredds
    ├── threddsConfig.xml
    └── # ... other files (see container) ...
```

## Configuration utilities

<div class="note note-warning" markdown="1">
The following sections assume that the `ESGF_CONFIG` environment variable
has been exported, as in the [Quick Start](../quick-start/).
</div>

### Generating secrets

The `generate-secrets` utility can be used to generate random secrets for passwords
and secret keys for the ESGF components:

```sh
./bin/esgf-setup generate-secrets
```

This will generate the `secrets` directory in the above structure.

<div class="note note-info" markdown="1">
Secret generation will be skipped for any secrets that already exist, so if you
need to use specific passwords and secret keys in order to integrate with
pre-existing services, just create the relevant file before running the
`generate-secrets` script.
</div>

### Generating self-signed test certificates

<div class="note note-danger" markdown="1">
**NEVER USE SELF-SIGNED CERTIFICATES IN PRODUCTION!**
</div>

To generate self-signed test certificates for the host and SLCS CA, use the
`generate-test-certificates` utility:

```sh
./bin/esgf-setup generate-test-certificates
```

This will generate the `certificates/hostcert` and `certificates/slcsca` directories
in the above structure and populate them with self-signed certificates.

<div class="note note-warning">
In production these directories will need to be created manually and populated with
genuine certificates issued by a trusted certificate authority.
</div>

### Fetching static configuration files

By default, an ESGF Docker deployment will be self-contained, i.e. it does not
attempt to participate in a federation. In order to participate in a federation,
details of other federation members need to be specified via a set of XML files,
and the certificates for the federation need to be trusted (configuration of
Solr shards is more complex, and is [addressed later](#solr-replica-shard-configuration)).

ESGF Docker allows individual configuration files to be overridden in containers
by dropping files into the optional directories under `$ESGF_CONFIG`. Any files
in these directories will override the default files inside the container.

A utility is provided to download known static configuration files:

```sh
./bin/esgf-setup fetch-static-configs [PROFILE]
```

This command will populate the `config` directory in the above structure with the
following files from the [esgf-config repository](https://github.com/ESGF/esgf-config):

  * `esgf_ats_static.xml`
  * `esgf_cogs.xml`
  * `esgf_endpoints.xml`
  * `esgf_idp_static.xml`
  * `esgf_known_providers.xml`
  * `esgf_search_aliases.xml`

The optional `PROFILE` argument specifies the directory in the repository to use,
and defaults to `esgf-prod`.

It will also download `esg_trusted_certificates.tar`, the ESGF trusted certificates, from
an ESGF distribution site and place it into the `certificates` directory of the
configuration structure.

### Creating the trust bundle

The trust bundle `esg-trust-bundle.pem` is automatically generated from existing
certificates using the `create-trust-bundle` utility.

First, the certificates from `certificates/esg_trusted_certificates.tar` are
included, if it exists. This tar file should contain a single directory called
`esg_trusted_certificates` containing all the trusted CA certificates for the
deployment, and can be downloaded from an ESGF distribution site (see
[Fetching static configuration files](#fetching-static-configuration-files) above).

If the SLCS CA or host certificate are self-signed, they are also added to the
trust bundle so that the installation can trust its own certificates.

The command to create the trust bundle is:

```sh
./bin/esgf-setup create-trust-bundle
```


## Solr replica shard configuration

Rather than running all the Solr replica shards in one place using separate ports, as in a
"traditional" ESGF deployment, ESGF Docker uses a separate Docker container for each
replica shard.

The deployed Solr replica shards are configured by placing a `solr_shards.yaml` file at
`$ESGF_CONFIG/solr_shards.yaml`. This file has the following structure:

```yaml
# YAML list of the shards
shards:
  - url: http://esgf.remote.site/solr  # REQUIRED - The URL to replicate
    name: remote-site  # OPTIONAL - The service name to use, derived from URL if not given
    replicationInterval: "06:00:00"  # OPTIONAL - The replication interval, default 01:00:00

  - url: "..."
```

The `./bin/esgf-compose` command ensures that the Docker Compose configuration for the
replica shards is correctly passed to `docker-compose`.

<div class="note note-warning" markdown="1">
Remember to use `./bin/esgf-compose` whenever you would normally use `docker-compose`.
This ensures that the shard configurations are included in the Docker Compose configuration
that is used.
</div>

<div class="note note-info" markdown="1">
To see the generated Docker Compose configuration, you can use the command `./bin/esgf-setup compose-file`.
`./bin/esgf-compose` uses this command to generate the Docker Compose configuration before passing it
to `docker-compose` automatically, so it is not normally necessary to use it directly.
</div>
