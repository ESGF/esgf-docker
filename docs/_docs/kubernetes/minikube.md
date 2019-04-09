---
title: Minikube
category: Kubernetes
order: 2.1
---

[Minikube](https://kubernetes.io/docs/getting-started-guides/minikube/) is a tool that runs
a single-node Kubernetes cluster inside a VM on your development machine for testing the
Kubernetes deployment.

## Prerequisites

First, install [Minikube](https://kubernetes.io/docs/getting-started-guides/minikube/)
and the [Helm](https://helm.sh/) CLI.

Then start a Minikube cluster with plenty of RAM. For now, we need to downgrade
the Kubernetes version due to [this bug](https://github.com/kubernetes/kubernetes/issues/61076).
See `minikube get-k8s-versions` for the available versions:

```sh
minikube start --kubernetes-version v1.14.0 --memory 8096 --disk-size 100GB
```

Pods must be able to loop back to themselves via their own service - this is known
as "hairpin mode", and requires the docker bridge network to be in promiscuous
mode:

```sh
minikube ssh -- sudo ip link set docker0 promisc on
```

Install Tiller:

```bash
# Create service account for Tiller
kubectl -n kube-system create serviceaccount tiller
# Grant cluster-admin role to service account
kubectl create clusterrolebinding tiller-cluster-admin \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:tiller
# Start Tiller
helm init --service-account tiller --upgrade
# Wait for Tiller to start
kubectl -n kube-system wait --for condition=ready pods -l "app=helm,name=tiller" --timeout 300s
```

Install the Nginx ingress controller using Helm. Unfortunately, we can't use
`minikube addons enable ingress` because we need an additional flag to enable
SSL passthrough, which is required to use SSL client certificates. By default,
the Nginx ingress controller also uses a `308` response to redirect from `http`
to `https`. While, strictly speaking, `308` is better than `301`, it is a
(relatively) recent standard that breaks `urllib2`, and hence CoG:

```bash
# Update stable Helm channel
helm repo update stable
# Install Nginx Ingress Controller
#   Due to this bug - https://github.com/kubernetes/ingress-nginx/issues/2994 - we need to
#   use the 0.17.x series instead of 0.18.x
#   For Minikube, we use the host networking
helm upgrade ingress stable/nginx-ingress \
  --install \
  --namespace kube-system \
  --set "controller.image.tag=0.17.1" \
  --set "controller.extraArgs.enable-ssl-passthrough=" \
  --set-string "controller.config.http-redirect-code=301" \
  --set controller.hostNetwork=true \
  --set "controller.extraArgs.report-node-internal-ip-address="
# Wait for Nginx Ingress Controller to start
kubectl -n kube-system wait --for condition=ready pods -l "release=ingress" --timeout 300s
```


## Configure and deploy ESGF components

Configuration is very similar to [Docker Compose](../../compose/quick-start/#configure-environment):

```sh
# This should be an empty directory
export ESGF_CONFIG=/path/to/esgf/config
mkdir -p $ESGF_CONFIG
# Create an environment file containing the hostname
cat > "$ESGF_CONFIG/environment" <<EOF
ESGF_HOSTNAME=$(minikube ip).xip.io
EOF
# Generate configuration
./bin/esgf-setup generate-secrets
./bin/esgf-setup generate-test-certificates
./bin/esgf-setup create-trust-bundle
# Deploy the ESGF components
./bin/esgf-setup helm-values minikube | \
  helm upgrade my-node cluster/kubernetes/charts --install -f -
# Wait for the ESGF components to start
kubectl wait --for condition=ready pods -l release=my-node --timeout 600s
```

You can inspect the state of the pods using `kubectl get pods`, or by launching the dashboard
using `minikube dashboard`.

Once all the containers are running, visit `https://$ESGF_HOSTNAME` to see the CoG interface.
Try the following as a basic test of functionality:

  *  Log in with the `rootAdmin` account from CoG (OpenID `https://$ESGF_HOSTNAME/esgf-idp/openid/rootAdmin`)
     using the password from the `my-node-esgf-node-secrets` secret in Kubernetes, or the file
     `$ESGF_CONFIG/secrets/rootadmin-password`
  * Log in with the `rootAdmin` account from the ORP (`https://$ESGF_HOSTNAME/esg-orp`)
  * Check THREDDS is running at `https://$ESGF_HOSTNAME/thredds`
  * Check Solr is running at `https://$ESGF_HOSTNAME/solr`


## Test publication

Publish the test dataset (similar to [Docker Compose](../../compose/publishing/)):

```sh
# Scale up the publisher deployment
$ kubectl scale --replicas=1 deployment my-node-esgf-node-publisher
# Wait for the publisher pod to start and get the pod name
# The first time you scale up is when the image gets pulled, so this might take
# a long time
$ PUBLISHER_POD="$(kubectl get pods -l "release=my-node,component=publisher" -o name | cut -d "/" -f 2)"
$ kubectl wait --for condition=ready pods "$PUBLISHER_POD" --timeout 300s
# Start a shell inside the publisher pod
$ kubectl exec -it "$PUBLISHER_POD" /usr/local/bin/docker-entrypoint.sh bash
# Download the data
[publisher] $ mkdir -p /esg/data/test
[publisher] $ wget -O /esg/data/test/sftlf.nc http://distrib-coffee.ipsl.jussieu.fr/pub/esgf/dist/externals/sftlf.nc
# Fetch a certificate
[publisher] $ fetch-certificate
# Publish the data
[publisher] $ esgprep mapfile --project test /esg/data/test
[publisher] $ esgpublish --project test --map mapfiles/test.test.map --service fileservice
[publisher] $ esgpublish --project test --map mapfiles/test.test.map --service fileservice --noscan --thredds
[publisher] $ esgpublish --project test --map mapfiles/test.test.map --service fileservice --noscan --publish
# Exit the publisher pod
[publisher] $ exit
# Scale the deployment back down to remove the pod
$ kubectl scale --replicas=0 deployment my-node-esgf-node-publisher
```

After allowing time for the data to replicate from the master to the slave, check that search is working at
`https://$ESGF_HOSTNAME/search/testproject/` and that the data is accessible from THREDDS.


## Cleanup

To delete the Minikube cluster, run:

```bash
minikube delete
```
