# Deploy ESGF using Ansible

This project provides an [Ansible playbook](https://docs.ansible.com/ansible/latest/index.html)
that will place [Docker containers](https://www.docker.com/) onto specific hosts.

The playbook and associated roles and variables are in [deploy/ansible/](../deploy/ansible/). Please look at
these files to understand exactly what the playbook is doing.

For a complete list of all variables that are available, please look at the defaults for each
of the [playbook roles](../deploy/ansible/roles/). The defaults have extensive comments that
explain how to use these variables. This document describes how to apply some common
configurations.

## Running the playbook

Before attempting to run the playbook, make sure that you have
[installed Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

Next, make a configuration directory - this can be anywhere on your machine that is **not** under
`esgf-docker`. You can also place this directory under version control if you wish - this can be very
useful for tracking changes to the configuration, or even triggering deployments automatically when
configuration changes.

In your configuration directory, make an
[inventory file](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)
defining the hosts that you want to deploy to:

```ini
# /my/esgf/config/inventory.ini

[data]
esgf.example.org
```

Currently, ESGF deployments only respect the `data` group. Hosts in this group will be deployed as data nodes.

Variables can be overridden on a per-group or per-host basis by placing YAML files at
`/my/esgf/config/group_vars/[group name].yaml` or `/my/esgf/config/host_vars/[host name].yml`. See below
for some common examples, and consult the [role defaults](../deploy/ansible/roles/) for a complete list
of available variables.

Once you have configured your inventory and host/group variables, you can run the playbook:

```sh
ansible-playbook -i /my/esgf/config/inventory.ini ./deploy/ansible/playbook.yml
```

## Configuring the installation

This section describes the most commonly modified configuration options. For a full list of available
variables, please consult the playbook [role defaults](../deploy/ansible/roles/).

### Setting the version

By default, the Ansible playbook will use the `latest` tag when specifying Docker images. For production
installations, it is recommended to use an immutable tag (see [Image tags](../README.md#image-tags)).

To set the tag to something other than `latest`, create a file at `/my/esgf/config/group_vars/all.yml`:

```yaml
# /my/esgf/config/group_vars/all.yml

image_defaults:
  # Use the images that were built for a particular commit
  tag: a031a2ca
  # If using an immutable tag, don't do unnecessary pulls
  pull: false
```

### Setting the web address

By default, the web address is the FQDN of the host (i.e. the output of `hostname --fqdn`). This can
be changed on a host-by-host basis using the variable `hostname`. For convenience, this can be set directly
in the inventory file:

```ini
# /my/esgf/config/inventory.ini

[data]
esgf-data01.example.org  hostname=esgf-data.example.org
```

It is even possible to provision multiple hosts with the same `hostname` and use DNS load-balancing to
distribute the load across those hosts:

```ini
# /my/esgf/config/inventory.ini

[data]
esgf-data[01:10].example.org  hostname=esgf-data.example.org

# Or ....
esgf-data01.example.org  hostname=esgf-data.example.org
esgf-data02.example.org  hostname=esgf-data.example.org
```

The Ansible playbook does **not** configure the DNS load-balancing automatically - you will need to separately
configure [Round-robin DNS](https://en.wikipedia.org/wiki/Round-robin_DNS) or a more sophisticated service like
[AWS Route 53](https://aws.amazon.com/route53/) to do this.

### Configuring the available datasets

The Docker-based data node uses a catalog-free configuration to serve data - the available data is defined simply
by a series of datasets, under which all files will be served using both OPeNDAP (for NetCDF files) and plain
HTTP. The browsable interface and OPeNDAP are provided by THREDDS and, direct file serving is provided by Nginx.

The configuration of the datasets is done using two variables:

  * `data.mounts`: List of directories to mount from the host into the container. Each item should contain
    the keys:
    * `hostPath`: The path on the host
    * `mountPath`: The path in the container
  * `data.datasets`: List of datasets to expose via THREDDS/Nginx. Each item should contain the keys:
    * `name`: The human-readable name of the dataset, displayed in the THREDDS UI
    * `path`: The URL path part for the dataset
    * `location`: The directory path to the root of the dataset

These variables should be defined in your configuration directory using `/my/esgf/config/group_vars/data.yml`, e.g.:

```yaml
# /my/esgf/config/group_vars/data.yml

data:
  mounts:
    # This will mount /datacentre/archive on the host as /data in the containers
    - hostPath: /datacentre/archive
      mountPath: /data

  datasets:
    # This will expose files at /data/cmip6/[path]
    # as http://esgf-data.example.org/thredds/{dodsC,fileServer}/esg_cmip6/[path]
    - name: CMIP6
      path: esg_cmip6
      location: /data/cmip6
    # Similarly, this exposes files at /data/cordex/[path]
    # as http://esgf-data.example.org/thredds/{dodsC,fileServer}/esg_cordex/[path]
    - name: CORDEX
      path: esg_cordex
      location: /data/cordex
```
