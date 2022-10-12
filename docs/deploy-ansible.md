# Deploy ESGF using Ansible

This project provides an [Ansible playbook](https://docs.ansible.com/ansible/latest/index.html)
that will place [Docker containers](https://www.docker.com/) onto specific hosts.

The playbook and associated roles and variables are in [deploy/ansible/](../deploy/ansible/).
Please look at these files to understand exactly what the playbook is doing.

For a complete list of all variables that are available, please look at the defaults for each
of the [playbook roles](../deploy/ansible/roles/). The defaults have extensive comments that
explain how to use these variables. This document describes how to apply some common
configurations.

<!-- TOC depthFrom:2 -->

- [Running the playbook](#running-the-playbook)
- [Local test installation with Vagrant](#local-test-installation-with-vagrant)
- [Configuring the installation](#configuring-the-installation)
    - [Setting the image version](#setting-the-image-version)
    - [Setting the web address](#setting-the-web-address)
    - [Enabling and disabling components](#enabling-and-disabling-components)
    - [Configuring the available datasets](#configuring-the-available-datasets)
    - [Using existing THREDDS catalogs](#using-existing-thredds-catalogs)
    - [Configuring Solr replicas](#configuring-solr-replicas)
    - [Using external Solr instances](#using-external-solr-instances)
    - [Fowarding access logs](#fowarding-access-logs)
- [Testing the service endpoints](#testing-service-endpoints)

<!-- /TOC -->

## Running the playbook

Before attempting to run the playbook, make sure that you have
[installed Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

Next, make a configuration directory - this can be anywhere on your machine that is **not** under
`esgf-docker`. You can also place this directory under version control if you wish - this can be very
useful for tracking changes to the configuration, or even triggering deployments automatically when
configuration changes. If you do, make sure not to commit any plain-text secrets to your
version control repository (e.g. by using an encryption tool such as
[Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)).

In your configuration directory, make an
[inventory file](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)
defining the hosts that you want to deploy to:

```ini
# /my/esgf/config/inventory.ini

[data]
esgf.example.org

[index]
esgf.example.org
```

Currently, ESGF deployments respect the `data` and `index` groups. Hosts in these groups will be
deployed as data and/or index nodes respectively. A host can be in both groups, and will be deployed
as a combined data and index node.

Variables can be overridden on a per-group or per-host basis by placing YAML files in your
configuration directory at `/my/esgf/config/group_vars/[group name].yaml` or
`/my/esgf/config/host_vars/[host name].yml`. See below for some common examples, and consult the
[role defaults](../deploy/ansible/roles/) for a complete list of available variables.

Once you have configured your inventory and host/group variables, you can run the playbook:

```sh
ansible-playbook -i /my/esgf/config/inventory.ini ./deploy/ansible/playbook.yml
```

## Local test installation with Vagrant

This repository includes a [Vagrantfile](./Vagrantfile) that deploys a simple test server using the
Ansible method. This test server is configured to serve data from
[roocs/mini-esgf-data](https://github.com/roocs/mini-esgf-data).

To deploy a test server, first install [VirtualBox](https://www.virtualbox.org/) and
[Vagrant](https://www.vagrantup.com/), then run:

```sh
vagrant up
```

After waiting for the containers to start, the THREDDS interface will be available at http://192.168.100.100.nip.io/thredds.

**NOTE:** The Vagrant installation is known to have problems when run from a Windows host. We do not recommend
installing from Windows.

## Configuring the installation

This section describes the most commonly modified configuration options. For a full list of available
variables, please consult the playbook [role defaults](../deploy/ansible/roles/).

### Setting the image version

By default, the Ansible playbook will use the `latest` tag when specifying Docker images. For production
installations, it is recommended to use an immutable tag (see [Image tags](../README.md#image-tags)).

To set the tag to something other than `latest`, create a file at `/my/esgf/config/group_vars/all.yml`:

```yaml
# /my/esgf/config/group_vars/all.yml

# Use the images that were built for a particular commit
image_tag: a031a2ca
# If using an immutable tag, don't do unnecessary pulls
image_pull: false
```

To use images from a custom registry, e.g. if you need to perform additional security checks:

```yaml
# Set the prefix for the images
image_prefix: registry.example.com/esgf
```

Properties can also be overridden on a per-image basis, e.g.:

```yaml
# Use a different branch for the THREDDS image
thredds_image_tag: my-branch
thredds_image_pull: true
```

### Setting the web address

By default, the web address is the FQDN of the host (i.e. the output of `hostname --fqdn`). This can
be changed on a host-by-host basis using the variable `hostname`. For convenience, this can be set
directly in the inventory file:

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

The Ansible playbook does **not** configure the DNS load-balancing automatically - you will need to
separately configure [Round-robin DNS](https://en.wikipedia.org/wiki/Round-robin_DNS) or use a more
sophisticated service like [AWS Route 53](https://aws.amazon.com/route53/) to do this.

### Enabling and disabling components

As well as defining each node as a data and/or index node using groups, the Ansible playbook allows
individual components to be enabled or disabled using variables. By default, all components for the
node type (as determined by the groups) will be deployed.

The following variables control which components are deployed:

```yaml
thredds_enabled: true/false
fileserver_enabled: true/false
solr_enabled: true/false
search_enabled: true/false
```

### Configuring the available datasets

By default, the data node uses a catalog-free configuration where the available data is defined simply
by a series of datasets. For each dataset, all files under the specified path will be served using both
OPeNDAP (for NetCDF files) and plain HTTP. The browsable interface and OPeNDAP are provided by
THREDDS and direct file serving is provided by Nginx.

The configuration of the datasets is done using two variables:

  * `data_mounts`: List of directories to mount from the host into the data-serving containers. Each item should contain the keys:
    * `host_path`: The path on the host
    * `mount_path`: The path in the container
  * `data_datasets`: List of datasets to expose using the data-serving containers. Each item should contain the keys:
    * `name`: The human-readable name of the dataset, displayed in the THREDDS UI
    * `path`: The URL path part for the dataset
    * `location`: The directory path to the root of the dataset in the container

These variables should be defined in your configuration directory using
`/my/esgf/config/group_vars/data.yml`, e.g.:

```yaml
# /my/esgf/config/group_vars/data.yml

data_mounts:
  # This will mount /datacentre/archive on the host as /data in the containers
  - host_path: /datacentre/archive
    mount_path: /data

data_datasets:
  # This will expose files at /data/cmip6/[path] in the container
  # as http://esgf-data.example.org/thredds/{dodsC,fileServer}/esg_cmip6/[path]
  - name: CMIP6
    path: esg_cmip6
    location: /data/cmip6
  # Similarly, this exposes files at /data/cordex/[path] in the container
  # as http://esgf-data.example.org/thredds/{dodsC,fileServer}/esg_cordex/[path]
  - name: CORDEX
    path: esg_cordex
    location: /data/cordex
```

### Using existing THREDDS catalogs

The data node can be configured to serve data based on pre-existing THREDDS catalogs, for
example those generated by the ESGF publisher. This is done by specifying a single additional
variable - `thredds_catalog_host_path` - pointing to a directory containing the pre-existing
catalogs:

```yaml
thredds_catalog_host_path: /path/to/existing/catalogs
```

> **NOTE**
>
> You must still configure `data_mounts` and `data_datasets` as above, except in this case the
> datasets should correspond the to the `datasetRoot`s in your THREDDS catalogs.

When the catalogs change, run the Ansible playbook in order to restart the containers and
load the new catalogs. THREDDS is configured to use a persistent volume for cache files, meaning
that although the first start may be slow for large catalogs, subsequent restarts should be
much faster (depending how many files have changed).

### Configuring Solr replicas

By default, the Ansible playbook configures local master and slave Solr instances for locally
pulished data and configures the `esg-search` application to talk to them.

However, `esg-search` can also include results from indexes at other sites, which are
replicated locally. Each replica gets it's own Solr instance and the `esg-search` application is
configured to use these replicas.

To configure the available replicas use the variable `solr_replicas`. The value should
be a list in which the following keys are required for each item:

  * `name`: Used in the names of Kubernetes resources for the replica
  * `master_url`: The URL to replicate, including scheme, port and path, e.g.
    `https://esgf-index1.ceda.ac.uk/solr`

For example, the following configures two replicas, and will result in four Solr containers running:

  * `master`
  * `slave`
  * `ceda-index-3`
  * `llnl`

```yaml
solr_replicas:
  - name: ceda-index-3
    master_url: https://esgf-index3.ceda.ac.uk/solr
  - name: llnl
    master_url: https://esgf-node.llnl.gov/solr
```

Additional variables are available to customise behaviour, e.g. poll intervals - please see the
[role defaults for the index role](../deploy/ansible/roles/index/defaults/main.yml).

### Using external Solr instances

If you have existing Solr instances that you do not wish to migrate, or need to run Solr
outside of Docker for persistence or performance reasons, the Ansible playbook can configure the
`esg-search` application to use external Solr instances.

To do this, just disable Solr and set the external URLs to use. For any replicas that are specified,
`esg-search` will be configured to use the `master_url` directly.

> **WARNING**
>
> If you want to use a Solr instance configured using `esgf-ansible` as an external Solr instance,
> you will need to configure the firewall on that host to expose the port  `8984` where the
> master listens.

Example configuration using external Solr instances:

```yaml
# Disable local Solr instances
solr_enabled: false
# Set the external URLs for Solr
solr_master_external_url: http://external.solr:8984/solr
solr_slave_external_url: http://external.solr:8983/solr
# Configure the replicas
# No local containers will be deployed - esg-search will use the master_url directly
solr_replicas:
  - name: ceda-index-3
    master_url: https://esgf-index3.ceda.ac.uk/solr
  - name: llnl
    master_url: https://esgf-node.llnl.gov/solr
```

### Fowarding access logs

ESGF data nodes can be configured to forward access logs to [CMCC](https://www.cmcc.it/)
for processing in order to produce download statistics for the federation.

Before enabling this functionality you must first contact CMCC to arrange for the IP addresses
of your ESGF nodes, as visible from the internet, to be whitelisted.

Then set the following variable to enable the forwarding of access logs:

```yaml
logstash_enabled: true
```

Additional variables are available to configure the server to which logs should be forwarded -
please see the [role defaults for the data role](../deploy/ansible/roles/data/defaults/main.yml) -
however the vast majority of deployments will not need to change these.

## Testing the service endpoints

Once the playbook has successfully then you should see a THREDDS catalog webpage at this URL:

 `http://<data:host_name>/thredds`

And the following should return a JSON response:

 `http://<index:host_name>/esg-search/search?fields=*&type=File&latest=true&format=application%2Fsolr%2Bjson&limit=10&offset=0`

