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


Clone the (esgf-slcs-client-example)[https://github.com/cedadev/esgf-slcs-client-example] repository locally.

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