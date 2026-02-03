# Resource Requirements

Below are some recommendations for server resources when running a data node using this deployment.

## For a VM-based data node

**THREDDS:**
* Memory: 4GB minimum, 16GB recommended, 32GB if expecting a lot of usage
* CPU: 1 should be enough

**Nginx File Server:**
* Memory: Depends on expected usage. 1GB should be enough, but with high usage you may need to increase this as far as 32GB
* CPU: 1 should be enoughFor a combined THREDDS / Nginx data node, you can add up the memory needs.
_Keep in mind that THREDDS may eat up the available memory on a node under heavy use. Especially when subsetting larger files._

For Kubernetes nodes, follow the same guidance as above when configuring
[data.thredds.resources](https://github.com/ESGF/esgf-docker/blob/ace917dc33098a06bc853e1d65be6a9fe0844486/deploy/kubernetes/chart/values.yaml#L316)
and [data.fileServer.resources](https://github.com/ESGF/esgf-docker/blob/ace917dc33098a06bc853e1d65be6a9fe0844486/deploy/kubernetes/chart/values.yaml#L366),
but keep in mind that smaller memory limit may be needed if autoscaling is enabled, or using multiple replicas
