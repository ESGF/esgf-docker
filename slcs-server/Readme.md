# docker-entrypoint Usage


```
docker run -it --rm esgfhub/slcs-server
usage: docker-entrypoint.py [-h] -sn my-node.esgf.org -ds another -su
                            http://my-cdn.esgf.org/slcs-static/
                            [-up slcs-admin] [-xf] -sdn esgf_slcs_server -sdu
                            db_user -sdh slcsdb.esgf.org [-sdp 5432]
                            [-sde django.db.backends.postgresql] -udn
                            esgf_slcs_server -udu db_user -udh slcsdb.esgf.org
                            [-udt user] [-uds esgf_security] [-udp 5432]
                            [-ude django.db.backends.postgresql]
                            [-se no-reply@my-node.esgf.org]
                            [-ccf /usr/local/esgf-slcs-server/conf/ca/08bd99c7.0 [/usr/local/esgf-slcs-server/conf/ca/08bd99c7.0 ...]]
                            [-dd]
                            [-da John Doe,john@example.com [Mary,mary@example.com ...]]

Start an ESGF SLCS instance.

optional arguments:
  -h, --help            show this help message and exit
  -sn my-node.esgf.org, --server-name my-node.esgf.org
                        The Fully Qualified Domain Name of the SLCS server.
                        (default: None)
  -ds another, --django-superuser another
                        The user in UserDB that should be given django
                        superuser permissions. (default: None)
  -su http://my-cdn.esgf.org/slcs-static/, --static-url http://my-cdn.esgf.org/slcs-static/
                        The URL used when retrieving static files. (default:
                        None)
  -se no-reply@my-node.esgf.org, --server-email no-reply@my-node.esgf.org
                        The email address used when sending emails. Defaults
                        to no-reply@[--server-name]. (default: None)
  -ccf /usr/local/esgf-slcs-server/conf/ca/08bd99c7.0 [/usr/local/esgf-slcs-server/conf/ca/08bd99c7.0 ...], --cacert-chain-filepaths /usr/local/esgf-slcs-server/conf/ca/08bd99c7.0 [/usr/local/esgf-slcs-server/conf/ca/08bd99c7.0 ...]
                        List of PEM-encoded certificate files corresponding to
                        CA trustroot files to be returned in the certificate
                        issuing response. These are concatenated with the new
                        issued certificate. This setting is optional and may
                        be useful where the clients trust roots do not contain
                        the complete chain of trust from the newly issued cert
                        and a root certificate. This option does not apply if
                        the CA for this service is itself a root CA. (default:
                        None)
  -dd, --django-debug   Enable Django debug mode. (default: False)
  -da John Doe,john@example.com [Mary,mary@example.com ...], --django-admin John Doe,john@example.com [Mary,mary@example.com ...]
                        https://docs.djangoproject.com/en/1.10/ref/settings/#a
                        dmins (default: [])

Proxy Settings:
  Settings used when SLCS is operating behind a proxy.

  -up slcs-admin, --url-prefix slcs-admin
                        Should be set when slcs is behind a proxy where all
                        requests are being forwarded from the proxy to slcs.
                        For example, if httpd is being used to proxy all
                        requests for https://my-node.esgf.org/slcs-admin to
                        the slcs application, then this option should be set
                        to 'slcs-admin'. See https://docs.pylonsproject.org/pr
                        ojects/waitress/en/latest/#using-url-prefix-to-
                        influence-script-name-and-path-info. (default: None)
  -xf, --use-x-forwarded-host
                        Enables ALLOWED_HOSTS to match against the
                        X_FORWARDED_HOST HTTP header instead of the HTTP HOST
                        header. See https://docs.djangoproject.com/en/1.9/ref/
                        settings/#use-x-forwarded-host (default: False)

SLCS Database Settings:
  Settings used for connecting to the SLCS database.

  -sdn esgf_slcs_server, --slcs-database-name esgf_slcs_server
                        The SLCS database name. (default: None)
  -sdu db_user, --slcs-database-user db_user
                        The SLCS database user. (default: None)
  -sdh slcsdb.esgf.org, --slcs-database-host slcsdb.esgf.org
                        The SLCS database host. (default: None)
  -sdp 5432, --slcs-database-port 5432
                        The SLCS database port. (default: 5432)
  -sde django.db.backends.postgresql, --slcs-database-engine django.db.backends.postgresql
                        The engine to use for the SLCS database. (default:
                        django.db.backends.postgresql)

User Database Settings:
  Settings used for connecting to the User database.

  -udn esgf_slcs_server, --user-database-name esgf_slcs_server
                        The User database name. (default: None)
  -udu db_user, --user-database-user db_user
                        The User database user. (default: None)
  -udh slcsdb.esgf.org, --user-database-host slcsdb.esgf.org
                        The User database host. (default: None)
  -udt user, --user-database-table user
                        The name of the User table (default: user)
  -uds esgf_security, --user-database-schema esgf_security
                        The name of the schema that contains the User table
                        (default: esgf_security)
  -udp 5432, --user-database-port 5432
                        The User database port. (default: 5432)
  -ude django.db.backends.postgresql, --user-database-engine django.db.backends.postgresql
                        The engine to use for the User database. (default:
                        django.db.backends.postgresql)
```

# Getting a Certificate Using esgf-slcs-client-example

Setup your environment as described in the [wiki](https://github.com/ESGF/esgf-docker/wiki).  

Take care to set the environment variables:

```
export ESGF_HOSTNAME=<Name of node>
export ESGF_CONFIG=/path/to/config/dir
export ESGF_DATA=/path/to/data/dir
export ESGF_VERSION=<ESGF Version>
````

From the `esgf-docker` directory run `docker compose up -d` to start the index node.

Once all of the services start up successfully, from the `slcs-server` directory run `docker compose up -d`.

This will start the services needed for the SLCS Server. Once they are up and running you can navigate to `https://$ESGF_HOSTNAME/slcs/admin` to access the Django administration page for SLCS.

Login as the `rootAdmin` user and click to add an application. Take note of the `Client id` and the `Client secret` then fill out the following properties:

```
User: 1 (rootAdmin)
Redirect uris: http://127.0.0.1:5000/oauth_callback
Client Type: public
Authorization grant type: Authorization Code
Name: esgf-slcs-client-example
```

Click save.


Clone the [esgf-slcs-client-example](https://github.com/cedadev/esgf-slcs-client-example) repository locally.

Modify the settings on lines 17-19 in `esgf_slcs_client_example.py` to match the settings for your installation. For example:

```
esgf_slcs_server = 'https://my-node.esgf.org/slcs'
client_id = "pUM8eOYwhgUCThK136l3RryvyTUkIQ5JgLUywVNh"
client_secret = "Lo5Fm31o5yQ1ZUXEgnc8vNFSdHuoTmDchj39V1Ka6oZ5nxnUUv6bxpBFFGIK7ylEjNnn7PxcEeRcV45Y7880LOqddWQPB1oxJ7lc1aDs7VPzOGgtXQWbVdmO1e5EPuvJ"
```

Also change the `redirect_uri` on line 37 to `redirect_uri = "http://127.0.0.1:5000/oauth_callback"`.

Run `esgf_slcs_client_example.py` and navigate to `http://127.0.0.1:5000`.

You should be greeted with a page with a few links. If you click `Get an OAuth token` you should be redirected and asked to authorize access for SLCS (you may be prompted for credentials as well).

Once you authorize access, you can click on `Get a user certificate` to get a certificate.
