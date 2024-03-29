# esgf-docker

This repository contains the `Dockerfile`s and associated deployment artifacts for building
and running the ESGF stack as Docker images.

Images are built automatically for every commit that modifies the `images` directory and pushed
to Docker Hub under the [esgfdeploy organisation](https://hub.docker.com/u/esgfdeploy).

The ESGF stack can be deployed in one of two ways:

  * Using Ansible to deploy and configure containers on specific hosts
  * Using Helm to deploy containers to a Kubernetes cluster

The Kubernetes deployment is recommended if possible, but we recognise that not all sites will
be comfortable configuring and maintaining a Kubernetes cluster. However Ansible-based deployments
will not benefit from many features provided by Kubernetes, including:

  * Zero downtime upgrades
  * Health checks providing increased resilience
  * Automatic scaling and load-balancing
  * Aggregated logging and metrics

## Current status

This project is under heavy active development, with the implementation depending on the ESGF
Future Architecture discussions.

Currently, data and index nodes are implemented but **without** authentication.

The data node uses THREDDS to serve catalog and OPeNDAP endpoints, but uses Nginx for direct file
serving which should be more performant than THREDDS.

The data node is capable of using existing catalogs from the current publisher to specify the
available data, however it is designed primarily to use a catalog-free configuration which utilises
[datasetScan elements](https://www.unidata.ucar.edu/software/tds/current/reference/DatasetScan.html),
to serve all files under a given dataset root. This will work with the next-generation publisher
being developed at LLNL that does not rely on THREDDS catalogs for publishing metadata.

## Image tags

Each image that is built for ESGF Docker is given several tags. Some of these are immutable, which
means they refer to a fixed version of the image for all time, and some are mutable which means
that the underlying image will change over time.

ESGF Docker will apply the following tags when building images:

  * Mutable tags
    * `latest`: the latest build for the `master` branch
    * `<slugified-branch-name>`: the latest build for the given branch name, as a slug, e.g.
      for the branch `issue/112/nginx-data-node` use `issue-112-nginx-data-node`
  * Immutable tags
    * The short Git hash for the commit that triggered the build, e.g. `d65ca162`, `a031a2ca`
    * The tag name for any tagged releases

By default, both the Ansible and Kubernetes installations use the `latest` tag when specifying
Docker images, which is a mutable tag.

For production installations it is recommended to use an immutable tag, either for a tagged
release or a particular commit, in order to avoid unexpected code changes or differences in
the container image between load-balanced nodes.

You can check the [available tags on Docker Hub](https://hub.docker.com/r/esgfdeploy/thredds/tags).
All the ESGF Docker images are built together, so any given tag will be available for all images.

## Making a deployment

Whether deploying ESGF using Kubernetes or Ansible, the first step is to clone the repository:

```sh
git clone https://github.com/ESGF/esgf-docker.git
cd esgf-docker
```

Then follow the deployment guide for your chosen deployment method:

  * [Deploy ESGF using Ansible](./docs/deploy-ansible.md)
  * [Deploy ESGF to Kubernetes using Helm](./docs/kubernetes/deploy.md)
