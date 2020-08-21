# Configuring a Kubernetes deployment

This section describes the most commonly modified configuration options. For a full list of available
variables, please consult the chart [values.yaml](../../deploy/kubernetes/chart/values.yaml).

<!-- TOC depthFrom:2 -->

- [Setting the image version](#setting-the-image-version)
- [Configuring container resources](#configuring-container-resources)
- [Enabling and disabling components](#enabling-and-disabling-components)
    - [Data node configuration](#data-node-configuration)
    - [Index node configuration](#index-node-configuration)

<!-- /TOC -->

## Setting the image version

By default, the Helm chart will use the `latest` tag when specifying Docker images. For production
installations, it is recommended to use an immutable tag (see [Image tags](../../README.md#image-tags)).

To set the tag to something other than `latest`, set the following variables in your `values.yaml`:

```yaml
image:
  # Use the images that were built for a particular commit
  tag: a031a2ca
  # If using an immutable tag, don't do unnecessary pulls
  pullPolicy: IfNotPresent
```

To use images from a custom registry, e.g. if you need to perform additional security checks:

```yaml
image:
  # Set the prefix for the images
  prefix: registry.example.com/esgf
```

Properties can also be overridden on a per-image basis, e.g.:

```yaml
data:
  # Use a different branch for the THREDDS image
  thredds:
    image:
      tag: my-branch
      pullPolicy: Always
```

## Configuring container resources

When specifying a pod in Kubernetes, you can optionally [specify how much of each resource
a container requires](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).
Most commonly, this will be CPU and memory (RAM), but it is also possible to specify other resources.

The resources for a container are specified as `requests` and `limits`. The `requests` section
should specify the minimum amount of each resource that the container needs to run, and is used
by the scheduler to decide which node to place the pod on and to reserve resources. The
`limits` section specifies the maximum amount of each resource that the container is allowed to
consume, and is enforced by Kubernetes. Each pod is given a
[Quality of Service (QoS) class](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/)
based on whether the `requests` and `limits` are the same or different.

Defining `resources.requests` and `resources.limits` is good practice as it prevents a badly
behaving container from taking out other containers by constraining it. It also allows the
Kubernetes scheduler to make more intelligent decisions about where to schedule pods to ensure
they have the resources they need to run.

The ESGF Helm chart allows the `resources` section to be specified for all the containers it manages.
Please see the [values.yaml](../../deploy/kubernetes/chart/values.yaml) for specific locations. This
example shows the setting of resources for the THREDDS container:

```yaml
data:
  thredds:
    resources:
      requests:
        cpu: 200m
        memory: 4Gi
      limits:
        cpu: 200m
        memory: 4Gi
```

By default, the ESGF Helm chart does not specify any resources, and the pods will be placed
in the `BestEffort` QoS class.

## Enabling and disabling components

The ESGF Helm chart allows components to be enabled or disabled either at the index/data node level
or at the level of an individual component. By default, all components will be deployed.

The following values in `values.yaml` control whether data and index node components will be
deployed. For information on enabling or disabling specific components, see `values.yaml`.

```yaml
data:
  # Enables or disables all data node components, e.g. THREDDS, file server
  enabled: true/false

index:
  # Enables or disables all index node components, e.g. Solr, search
  enabled: true/false
```

### Data node configuration

For more information on configuring a data node, see [Data node configuration](./configure-datanode.md).

### Index node configuration

For more information on configuring an index node, see [Index node configuration](./configure-indexnode.md).
