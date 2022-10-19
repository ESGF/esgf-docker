# Data node configuration

This section describes the most commonly used data node configuration options.
For a full list of available variables, please consult the chart at
[values.yaml](../../deploy/kubernetes/chart/values.yaml).

<!-- TOC depthFrom:2 -->

- [Configuring the available datasets](#configuring-the-available-datasets)
- [Fowarding access logs](#fowarding-access-logs)
- [Enabling demand-based autoscaling](#enabling-demand-based-autoscaling)
- [Using existing THREDDS catalogs](#using-existing-thredds-catalogs)
- [Improving pod startup time for large catalogs](#improving-pod-startup-time-for-large-catalogs)

<!-- /TOC -->

## Configuring the available datasets

By default, the data node uses a catalog-free configuration where the available data is defined simply by
a series of datasets. For each dataset, all files under the specified path will be served using both
OPeNDAP (for NetCDF files) and plain HTTP. The browsable interface and OPeNDAP are provided by
THREDDS and direct file serving is provided by Nginx.

The configuration of the datasets is done using two variables:

  * `data.mounts`: List of volumes to mount into the container. Each item should contain the keys:
    * `mountPath`: The path to mount the volume inside the container
    * `volumeSpec`: A [Kubernetes volume specification](https://kubernetes.io/docs/concepts/storage/volumes/) for
      the volume containing the data
    * `name` (optional): A name for the volume - by default, a name is derived from the `mountPath`
    * `mountOptions` (optional): Options for the volume mount, e.g. `mountPropagation` for `hostPath` volumes
  * `data.datasets`: List of datasets to expose. Each item should contain the keys:
    * `name`: The human-readable name of the dataset, displayed in the THREDDS UI
    * `path`: The URL path part for the dataset
    * `location`: The directory path to the root of the dataset in the container

> **WARNING**
>
> When using `hostPath` volumes, the data must exist at the same path on all cluster nodes where the THREDDS
> or file server pods might be scheduled.
>
> If your data is on a shared filesystem, just mount the filesystem on your cluster nodes as you would
> with any other host.

These variables should be defined in your `values.yaml`, e.g.:

```yaml
data:
  mounts:
    # This uses a hostPath volume to mount /datacentre/archive on the host as /data in the container
    - mountPath: /data
      volumeSpec:
        hostPath:
          path: /datacentre/archive
      mountOptions:
        # mountPropagation is particularly important if the filesystem has automounted sub-mounts
        mountPropagation: HostToContainer

  datasets:
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

## Fowarding access logs

The THREDDS and Nginx file server components can be configured to forward access logs to
[CMCC](https://www.cmcc.it/) for processing in order to produce download statistics for
the federation.

Before enabling this functionality you must first contact CMCC to arrange for the IP addresses
of your Kubernetes nodes, as visible from the internet, to be whitelisted.

> If your Kubernetes nodes are not directly exposed to the internet then they are probably using
> [Network Address Translation (NAT)](https://en.wikipedia.org/wiki/Network_address_translation)
> when accessing resources on the internet.
>
> In this case, the address that you need to give to CMCC is the translated address.

To enable the forwarding of access logs for THREDDS and Nginx file server pods, add the following
to your `values.yaml`:

```yaml
data:
  accessLogSidecar:
    enabled: true
```

Additional variables are available to configure the server to which logs should be forwarded,
however the vast majority of deployments will not need to change these.

## Enabling demand-based autoscaling

Kubernetes allows the number of pods backing a service to be scaled up and down automatically using
a [Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).
This allows the service to respond to spikes in demand by creating more pods to respond to requests.
A Kubernetes `Service` ensures that requests are routed to the new replicas as they become ready.

A HPA can be configured to automatically adjust the number of replicas based on any metrics that are exposed via
the [Metrics API](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/).
By default, this allows scaling based on the CPU or memory usage of the pods backing a service. However
it is possible to integrate other metrics gathering systems, such as [Prometheus](https://prometheus.io/),
to allow scaling based on any of the collected metrics (e.g. network I/O, requests per second).

By default, autoscaling is disabled in the ESGF Helm chart. To enable autoscaling for the THREDDS and
Nginx file server components, the chart allows `HorizontalPodAutoscaler` resources to be defined using
the `data.{thredds,fileServer}.hpa` variables. These variables define the `spec` section of the HPA, except
for the `scaleTargetRef` section which is automatically populated with the correct reference.
For more information about HPA configuration, see the
[Kubernetes HPA Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/).

> **WARNING**
>
> In order to scale based on utilisation (as opposed to absolute value), you must define
> `resources.requests` for the service
> (see [Configuring container resources](#configuring-container-resources) above).

For example, the following configuration would attempt to keep the average CPU utilisation
below 80% of the requested amount by scaling out up to a maximum of 10 replicas:

```yaml
data:
  thredds:
    hpa:
      minReplicas: 1
      maxReplicas: 10
      metrics:
        - type: Resource
          resource:
            name: cpu
            target:
              type: Utilization
              averageUtilization: 80

  fileServer:
    hpa:
      minReplicas: 1
      maxReplicas: 10
      metrics:
        - type: Resource
          resource:
            name: cpu
            target:
              type: Utilization
              averageUtilization: 80
```

## Using existing THREDDS catalogs

The data node can be configured to serve data based on pre-existing THREDDS catalogs, for
example those generated by the ESGF publisher. To do this, you must specify the volume
containing the catalogs using the variable `data.thredds.catalogVolume`. This volume must
be available to all nodes where THREDDS pods might be scheduled and must be able to be
mounted in multiple pods at once, for example a `hostPath` using a shared filesystem.
This variable should contain the keys `volumeSpec` and `mountOptions`, which have the
same meaning as for `data.mounts` above, e.g.:

```yaml
data:
  thredds:
    catalogVolume:
      volumeSpec:
        hostPath:
          path: /path/to/shared/catalogs
      mountOptions:
        mountPropagation: HostToContainer
```

> **NOTE**
>
> You must still configure `data.mounts` and `data.datasets` as above, except in this case the
> datasets should correspond the to the `datasetRoot`s in your THREDDS catalogs.

When the catalogs change, run the Helm chart in order to create new pods which will
load the new catalogs. This will be done using a rolling upgrade with no downtime - the
old pods will continue to serve requests with the old catalogs until new pods are ready.

For large catalogs, you may also need to adjust the startup time for the THREDDS container
as THREDDS must build the catalog cache before it can start serving requests. To do this,
specify `data.thredds.startTimeout`, which specifies the number of seconds to wait for
THREDDS to start before assuming there is a problem and trying again (default `300`):

```yaml
data:
  thredds:
    startTimeout: 3600  # Large catalogs may take an hour or more
```

## Improving pod startup time for large catalogs

Pods in Kubernetes are ephemeral, meaning they do not preserve state across restarts.
This includes the THREDDS caches, meaning that every time a pod starts it will spend time
rebuilding the catalog cache before serving requests, even if the catalogs have not changed.
This is exacerbated by the fact that the catalogs will likely be on network-attached-storage
in order to facilitate sharing across nodes, meaning higher latency for stat and read
operations.

For large catalogs, this can result in THREDDS pods taking an hour or more to start. This is not
merely an inconvenience - in order to benefit from advanced features in Kubernetes such as
recovery from failure and demand-based autoscaling, pods must start quickly in order to begin
taking load as soon as possible. There are two things that can be done to address this problem:

  * Keep a copy of the catalogs on the local disk of each node that may have THREDDS pods scheduled
  * Pre-build the catalog cache (again on the local disk of each node) and use it to seed the cache for new THREDDS pods

In an ESGF deployment, this is acheived by having a
[DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) that runs on
each node. When the Helm chart is run or a new node is added to the cluster, this `DaemonSet`
will syncronise the THREDDS catalogs to each node's local disk and run THREDDS to build the catalog
cache. The THREDDS pods will wait for the `DaemonSet` to finish updating the cache before starting,
using the pre-built cache as a seed for their own local caches. While they are waiting, the old
pods will continue to serve requests using the old catalogs, so the upgrade is zero-downtime.
Using this approach, copying the catalogs to local disk and rebuilding the cache are one-time
operations and the THREDDS pods start much faster (less than one minute for a large catalog at
CEDA in testing).

To enable local caching of catalogs for a deployment, just set `data.thredds.localCache.enabled`:

```yaml
data:
  thredds:
    localCache:
      enabled: true
```
