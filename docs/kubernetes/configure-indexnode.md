# Index node configuration

This section describes the most commonly used index node configuration options.
For a full list of available variables, please consult the chart at
[values.yaml](../../deploy/kubernetes/chart/values.yaml).

<!-- TOC depthFrom:2 -->

- [Configuring Solr replicas](#configuring-solr-replicas)
- [Using external Solr instances](#using-external-solr-instances)

<!-- /TOC -->

## Configuring Solr replicas

By default, the ESGF Helm chart configures local master and slave Solr instances for locally
pulished data and configures the `esg-search` application to talk to them.

However, `esg-search` can also include results from indexes at other sites, which are
replicated locally and `esg-search` then talks to the local replicas. Each replica gets
it's own Solr instance on the Kubernetes cluster, and the `esg-search` application is
configured to use these replicas.

To configure the available replicas use the variable `index.solr.replicas`. The value should
be a list in which the following keys are required for each item:

  * `name`: Used in the names of Kubernetes resources for the replica
  * `masterUrl`: The URL to replicate, including scheme, port and path, e.g. `https://esgf-index1.ceda.ac.uk/solr`

Other keys a

For example, the following configures two replicas, and will result in four Solr pods:

  * `master`
  * `slave`
  * `ceda-index-1`
  * `llnl`

```yaml
index:
  solr:
    replicas:
      - name: ceda-index-1
        masterUrl: https://esgf-index3.ceda.ac.uk/solr
      - name: llnl
        masterUrl: https://esgf-node.llnl.gov/solr
```

There are several other variables available in the ESGF Helm chart to customise Solr
behaviour - please see the [values.yaml](../../deploy/kubernetes/chart/values.yaml) for a
full list of available variables.

## Using external Solr instances

If you have existing Solr instances that you do not wish to migrate, or need to run Solr
outside of the Kubernetes cluster for persistence or performance reasons, the ESGF Helm chart
can configure the `esg-search` application to use external Solr instances.

To do this, disable Solr and set the external URLs to use. For any replicas that are specified,
`esg-search` will be configured to use the replica directly using the `masterUrl`.

> **WARNING**
>
> If you want to use a Solr instance configured using `esgf-ansible` as an external index
> for publishing, you will need to configure the firewall on that host to expose the port
> `8984` where the master runs.

```yaml
index:
  solr:
    # Disable local Solr instances
    enabled: false
    # Set the external URLs for Solr
    masterExternalUrl: http://external.solr:8984/solr
    slaveExternalUrl: http://external.solr:8983/solr
    # Configure the replicas
    # No local containers will be deployed - esg-search will use the masterUrl directly
    replicas:
      - name: ceda-index-1
        masterUrl: https://esgf-index3.ceda.ac.uk/solr
      - name: llnl
        masterUrl: https://esgf-node.llnl.gov/solr
```
