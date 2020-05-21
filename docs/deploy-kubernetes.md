# Deploy ESGF using Kubernetes

This project provides a [Helm chart](https://helm.sh/docs/topics/charts/) to deploy ESGF resources
on a [Kubernetes](https://kubernetes.io/) cluster.

The chart is in [deploy/kubernetes/chart](../deploy/kubernetes/chart/). Please look at the files to
understand exactly what resources are being created.

For a complete list of all the variables that are available, please look at the
[values.yaml for the chart](../deploy/kubernetes/chart/values.yaml). The defaults there have extensive
comments that explain how to use these variables. This document describes how to apply some common
configurations.

## Installing/upgrading ESGF

Before attempting to install the ESGF Helm chart, you must have the following:

  * A Kubernetes cluster with an
    [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) enabled
  * [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed and configured to talk
    to your cluster
  * [Helm](https://helm.sh/docs/intro/install/) installed

Next, make a configuration directory - this can be anywhere on your machine that is **not** under
`esgf-docker`. You can also place this directory under version control if you wish - this can be very
useful for tracking changes to the configuration, or even triggering deployments automatically when
configuration changes.

In your configuration directory, make a new YAML file called `values.yaml` and override any variables to fit
your deployment. The only required variable is `hostname`, which should be the DNS name at which your
ESGF deployment will be available:

```yaml
hostname: esgf.example.org
```

> **NOTE:** The Helm chart does not create a DNS entry for the hostname. This must be separately configured
> to point to the ingress controller for your Kubernetes cluster.

Once you have configured your `values.yaml`, you can install or upgrade ESGF using the Helm chart. If no
namespace is specified, it will use the default namespace for your `kubectl` configuration:

```sh
helm upgrade -i [-n <namespace>] -f /my/esgf/config/values.yaml --wait esgf ./deploy/kubernetes/chart
```

## Local test installation with Minikube

For local test deployments, you can use [Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/)
with data from [roocs/mini-esgf-data](https://github.com/roocs/mini-esgf-data):

```sh
# Start the minikube cluster
minikube start
# Enable the ingress addon
minikube addons enable ingress
# Install the test data
minikube ssh "curl -fsSL https://github.com/roocs/mini-esgf-data/tarball/master | sudo tar -xz --strip-components=1 -C / --wildcards */test_data"
```

Configure the chart to serve the test data (see [minikube-values.yaml](../deploy/kubernetes/minikube-values.yaml)),
using a `nip.io` domain pointing to the Minikube server:

```sh
helm install esgf ./deploy/kubernetes/chart/ \
  -f ./deploy/kubernetes/minikube-values.yaml \
  --set hostname="$(minikube ip).nip.io"
```

Once the containers have started, the THREDDS interface will be available at `http://$(minikube ip).nip.io/thredds`.

## Configuring the installation

This section describes the most commonly modified configuration options. For a full list of available
variables, please consult the chart [values.yaml](../deploy/kubernetes/chart/values.yaml).

### Setting the version

By default, the Helm chart will use the `latest` tag when specifying Docker images. For production
installations, it is recommended to use an immutable tag (see [Image tags](../README.md#image-tags)).

To set the tag to something other than `latest`, set the following variables in your `values.yaml`:

```yaml
image:
  # Use the images that were built for a particular commit
  tag: a031a2ca
  # If using an immutable tag, don't do unnecessary pulls
  pullPolicy: IfNotPresent
```

### Configuring the available datasets

The data node uses a catalog-free configuration where the available data is defined simply by a
series of datasets. For each dataset, all files under the specified path will be served using both
OPeNDAP (for NetCDF files) and plain HTTP. The browsable interface and OPeNDAP are provided by
THREDDS and direct file serving is provided by Nginx.

The configuration of the datasets is done using two variables:

  * `data.mounts`: List of volumes to mount into the container. Each item should contain the keys:
    * `mountPath`: The path to mount the volume inside the container
    * `volume`: A [Kubernetes volume specification](https://kubernetes.io/docs/concepts/storage/volumes/)
    * Any additional keys are set as options on the volume mount, e.g. `mountPropagation` for `hostPath` volumes
  * `data.datasets`: List of datasets to expose. Each item should contain the keys:
    * `name`: The human-readable name of the dataset, displayed in the THREDDS UI
    * `path`: The URL path part for the dataset
    * `location`: The directory path to the root of the dataset in the container

> **WARNING**
>
> When using `hostPath` volumes, the data must exist at the same path on all cluster hosts where the THREDDS
> or file server pods might be scheduled.
>
> If your data is on a shared filesystem, just mount the filesystem on your cluster nodes as you normally would.

These variables should be defined in your `values.yaml`, e.g.:

```yaml
data:
  mounts:
    # This uses a hostPath volume to mount /datacentre/archive on the host as /data in the container
    - mountPath: /data
      # mountPropagation is particularly important if the filesystem has automounted sub-mounts
      mountPropagation: HostToContainer
      volume:
        hostPath:
          path: /datacentre/archive

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
