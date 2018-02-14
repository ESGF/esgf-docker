---
title: Configuration
category: Usage
order: 2
---

Before running `docker-compose up`, the configuration directory pointed to by
the `ESGF_CONFIG` environment variable must have the following structure.
Although you could manually create this structure, the majority of it will usually
be generated using the scripts described in this page.

## Configuration structure

  * `$ESGF_CONFIG`
      * `certificates`
          * `esg-hostcert-bundle.p12`  
            PKCS12-encoded bundle containing host certificate and private key for SAML signing
          * `esg-trust-bundle.jks`  
            JKS-encoded bundle containing trusted CA certificates for Java apps
          * `esg-trust-bundle.pem`  
            PEM-encoded bundle containing trusted CA certificates for Python apps
          * `hostcert`
              * `hostcert.crt`  
                PEM-encoded host certificate, including all intermediate CA certificates, used for SSL
              * `hostcert.key`  
                PEM-encoded private key for host certificate
          * `slcsca`
              * `ca.crt`  
                PEM-encoded certificate for SLCS certificate authority
              * `ca.key`  
                PEM-encoded private key for SLCS CA certificate
      * `secrets`
          * `auth-database-password`  
            Password for database used by esgf-auth app
          * `auth-secret-key`  
            Django secret key used by esgf-auth app
          * `cog-secret-key`  
            Django secret key used by CoG app
          * `database-password`  
            Password for dbsuper user of main ESGF database
          * `database-publisher-password`  
            Password for esgcet user of main ESGF database
          * `java-hostcert-bundle-password`  
            Password for PKCS12-encoded host certificate bundle
          * `java-trust-bundle-password`  
            Password for JKS-encoded trust bundle
          * `rootadmin-password`  
            Password for rootAdmin node admin account
          * `shared-cookie-secret-key`  
            Shared secret for encrypted authorisation cookie
          * `slcs-database-password`  
            Password for database used by SLCS app
          * `slcs-secret-key`  
            Django secret key used by SLCS app


## Generating configuration

For a local test installation with self-signed certificates, the entire structure
described above can be automatically generated. For a production installation,
valid certificates signed by a trusted CA should be obtained for the host certificate
and SLCS CA, and placed into the directory structure at the correct location.

The scripts for generating configuration have been bundled up into the `cedadev/esgf-setup`
container image, meaning that the only requirement on the host system is Docker.

### Generating secrets

To generate random secrets for all the passwords and secret keys required for an
ESGF Docker installation, just run the following commands:

```sh
$ export ESGF_HOSTNAME=local.esgf.org
$ export ESGF_CONFIG=/path/to/empty/config/directory
$ docker run -v "$ESGF_CONFIG":/esg -e ESGF_HOSTNAME cedadev/esgf-setup generate-secrets
```

This will generate the contents of the `secrets` directory from the above structure.
Secret generation will be skipped for any secrets that already exist, so if you
want to use a specific password for the `rootAdmin` account, just create the
file before running the `generate-secrets` script.

### Generating self-signed certificates

<div class="note note-danger" markdown="1">
**NEVER USE SELF-SIGNED CERTIFICATES IN PRODUCTION!**
</div>

To generate self-signed certificates for the host and SLCS CA, just run this
command:

```sh
$ docker run -v "$ESGF_CONFIG":/esg -e ESGF_HOSTNAME cedadev/esgf-setup generate-test-certificates
```

This will generate the `certificates/hostcert` and `certificates/slcsca` directories
in the above structure. Again, in production these directories will need to be
created manually.

### Creating trust bundles

The three trust bundle files, `esg-hostcert-bundle.p12`, `esg-trust-bundle.jks`
and `esg-trust-bundle.pem`, are automatically generated from existing certificates.

`esg-hostcert-bundle.p12` is obviously generated from the host certificate and
private key in `certificates/hostcert`.

The two trust bundles contain the exact same certificates, just in different formats.
First, the certificates from `certificates/esg_trusted_certificates.tar` are
included, if it exists. This tar file can be downloaded from an ESGF distribution
site, and should contain a single directory called `esg_trusted_certificates`
containing all the trusted CAs for the federation. If the SLCS CA is self-signed,
it is also added to the trust bundles so that the installation can trust its own
certificates.

The command to create the trust bundles is:

```sh
$ docker run -v "$ESGF_CONFIG":/esg -e ESGF_HOSTNAME cedadev/esgf-setup create-trust-bundles
```
