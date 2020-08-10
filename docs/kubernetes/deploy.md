# Deploy ESGF using Kubernetes

This project provides a [Helm chart](https://helm.sh/docs/topics/charts/) to deploy ESGF resources
on a [Kubernetes](https://kubernetes.io/) cluster.

The chart is in [deploy/kubernetes/chart](../../deploy/kubernetes/chart/). Please look at the
files to understand exactly what resources are being created.

For a complete list of all the variables that are available, please look at the
[values.yaml for the chart](../../deploy/kubernetes/chart/values.yaml). The defaults there have
extensive comments that explain how to use these variables. This documentation describes how to
apply some common configurations.

<!-- TOC depthFrom:2 -->

- [Installing/upgrading ESGF](#installingupgrading-esgf)
- [Local test installation with Minikube](#local-test-installation-with-minikube)
- [Configuring the installation](#configuring-the-installation)

<!-- /TOC -->

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

> **NOTE**
>
> The Helm chart does not create a DNS entry for the hostname. This must be separately configured
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

Configure the chart to serve the test data (see
[minikube-values.yaml](../../deploy/kubernetes/minikube-values.yaml)), using a `nip.io`
domain pointing to the Minikube server:

```sh
helm install esgf ./deploy/kubernetes/chart/ \
  -f ./deploy/kubernetes/minikube-values.yaml \
  --set hostname="$(minikube ip).nip.io"
```

Once the containers have started, the THREDDS interface will be available at `http://$(minikube ip).nip.io/thredds`.

## Configuring the installation

See [Configuring a Kubernetes deployment](./configure.md).
