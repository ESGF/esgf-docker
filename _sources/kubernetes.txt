*******************
Kubernetes for ESGF
*******************

This document contains preliminary instructions on how to manage ESGF service containers with Kubernetes.

Currently, the following ESGF services can be started through Kubernetes:

* Solr

* ESGF Index Node (i.e. the search web application)


Setup
=====

Before using Kubernetes, you need to have a Kubernetes cluster, and the kubectl command-line tool must be configured to communicate with your cluster.
For example, you can install *minikube* and *kubectl* on a Mac laptop, then start a Kubernetes cluster as follows::

  minikube start --vm-driver=xhyve

  kubectl config use-context minikube

All Kubernetes files to follow this tutorial are contained in the *kubernetes* sub-dirctory.


Solr
====

To start a pod that contains the *esgf-solr* container::

  kubectl create -f solr-deployment.yaml

The *esgf-solr* container includes the ESGF solr master instance (port 8984) and slave instance (port 8983).
The Solr indexes are written to a Kubernetes PersistentVolume that is mounted into the location */esg/solr-index* inside the container.
The configuration file above also includes a Kubernetes service which makes the two Solr instances available
within the cluster at the URLs *http://esgf-solr:8984/* and *http://esgf-solr:8983/*, respectively.

To inspect the Kubernetes deployment::

  kubectl get pods -l app=solr
  kubectl describe deployment esgf-solr
  kubectl describe service esgf-solr

To test that the two Solr instances are working, enter the container and query localhost::

  kubectl exec -it esgf-solr-<pod hash-id> -- /bin/bash
  /]# curl 'http://localhost:8983/solr/datasets/select?q=*%3A*&wt=json&indent=true'
  /]# curl 'http://localhost:8984/solr/datasets/select?q=*%3A*&wt=json&indent=true'


Index Node
==========

To start a pod that contains the ESGF Index Node (i.e. the ESGF search web application running within Tomcat)::

  kubectl create -f index-node-deployment.yaml 

The *esgf-index-node* container mounts an archive file that contains all the necessary configuration files, and that is expanded into the location 
*/esg/config* inside the container. The web application connects to the Solr indexes exposed by the Solr service 
at the URLs *http://esgf-solr:8984/* and *http://esgf-solr:8983/*.
This deployment also includes its own service which exposes the web application at the URL *http://esgf-index-node:8080/esg-search/search* to other containers in the cluster.

To inspect the Kubernetes deployment::

  kubectl get pods -l app=index-node
  kubectl describe deployment esgf-index-node
  kubectl describe service esgf-index-node

To test that the ESGF web app is working, connect inside the container and query localhost::

  kubectl exec -it esgf-index-node-<pod hash-id> -- /bin/bash
  /]# curl 'http://localhost:8080/esg-search/search'
  /]# curl -k 'https://localhost:8443/esg-search/search'


Cleanup
=======

To clean up all pods, services and deployments::

  kubectl delete deployment,svc esgf-solr esgf-index-node
