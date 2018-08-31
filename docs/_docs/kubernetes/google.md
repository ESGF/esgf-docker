---
title: Google Kubernetes Engine
category: Kubernetes
order: 2.1
---

This page describe the process for deploying ESGF on
[Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/).

## Prerequisites

First, ensure that you have installed and configured the
[Google Cloud SDK](https://cloud.google.com/sdk/) and [Helm](https://helm.sh/) on
the machine you are deploying from.

The [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) tool is also required,
and can be installed using `gcloud`:

```bash
gcloud components install kubectl
```

If you have not already done so, check out the ESGF Docker repository and ensure that it is
your current working directory:

```bash
git clone https://github.com/ESGF/esgf-docker.git
cd esgf-docker
```

## Creating a cluster

Use the following command to create a Kubernetes cluster. See the GKE documentation for
the full range of options:

```bash
gcloud container clusters create --cluster-version 1.10 esgf-node
```

This command will create a GKE Kubernetes cluster and configure `kubectl` to point to it.

Next, install Tiller:

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

### Install Nginx Ingress Controller

Unlike the [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/), the GCP
[L7 load-balancer](https://cloud.google.com/load-balancing/docs/https/) that handles `Ingress`
resources by default in GKE cannot be configured to allow the SSL-passthrough required
for SSL client certificate authentication. Due to an incompatibility in `urllib2`, we also
need to use `301` rather than `308` for redirects.

Fortunately, GCP also provides an
[L4 load-balancer](https://cloud.google.com/load-balancing/docs/network/)
which can be accessed from GKE using `Service`s with `type: LoadBalancer`. However, we still want to be
able to use `Ingress` resources as with other clusters. To do this, we install the Nginx Ingress
Controller behind an L4 load-balancer to route traffic to the relevant Kubernetes services.

```bash
# Update stable Helm channel
helm repo update stable
# Install Nginx Ingress Controller
#   Due to this bug - https://github.com/kubernetes/ingress-nginx/issues/2994 - we need to
#   use the 0.17.x series instead of 0.18.x
helm upgrade ingress stable/nginx-ingress \
  --install \
  --namespace kube-system \
  --set "controller.image.tag=0.17.1" \
  --set "controller.extraArgs.enable-ssl-passthrough=" \
  --set-string "controller.config.http-redirect-code=301"
# Wait for Nginx Ingress Controller to start
kubectl -n kube-system wait --for condition=ready pods -l "release=ingress" --timeout 300s
```

To get the external IP that was allocated to the Nginx Ingress Controller's `Service`, use the
following command:

```bash
kubectl -n kube-system get service ingress-nginx-ingress-controller | tail -n 1 | awk '{ print $4; }'
```

### Install GCP Filestore CSI driver and storage class

[Google Cloud Filestore](https://cloud.google.com/filestore/) is Google Cloud's Filesystem-as-a-Service
offering. We will use this to provide the `ReadWriteMany` volumes required for the TDS/publisher.

In order to provision `ReadWriteMany` volumes using a storage class, we install the
[Google Cloud Filestore CSI driver](https://github.com/kubernetes-sigs/gcp-filestore-csi-driver):

```bash
# Set some variables for reuse later
#   Do not change the service account name
SA_NAME=gcp-filestore-csi-driver-sa
PROJECT="$(gcloud config get-value project)"
IAM_NAME="${SA_NAME}@${PROJECT}.iam.gserviceaccount.com"
KEY_FILE="$HOME/.gke/gcp_filestore_csi_driver_sa.json"

# Create Google Cloud service account
gcloud iam service-accounts create "$SA_NAME" \
  --display-name="GCP Filestore CSI driver service account"
# Add Cloud Filestore editor role to service account
gcloud projects add-iam-policy-binding "$PROJECT" \
  --member "serviceAccount:${IAM_NAME}" \
  --role roles/file.editor
# Create key for service account
gcloud iam service-accounts keys create "$KEY_FILE" --iam-account "$IAM_NAME"

# In order to create new cluster roles, we must first grant ourselves the cluster-admin role in Kubernetes
GCLOUD_USER="$(gcloud config get-value account)"
kubectl create clusterrolebinding \
  "$(echo -n "$GCLOUD_USER" | cut -d"@" -f1 | sed 's/\./-/g')-cluster-admin-binding" \
  --clusterrole=cluster-admin \
  --user="$GCLOUD_USER"

# Create the required Kubernetes namespace, service accounts and cluster roles
#   There is a typo in this YAML that we correct on the way through
curl -fsSL https://raw.githubusercontent.com/kubernetes-sigs/gcp-filestore-csi-driver/master/deploy/kubernetes/manifests/setup_cluster.yaml | \
  sed 's/reigstrar/registrar/g' | \
  kubectl apply -f -
# Upload the service account key as a secret
kubectl create secret generic "$SA_NAME" \
  --from-file="$KEY_FILE" \
  --namespace=gcp-filestore-csi-driver

# Start the CSI driver components
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gcp-filestore-csi-driver/master/deploy/kubernetes/manifests/node.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gcp-filestore-csi-driver/master/deploy/kubernetes/manifests/controller.yaml

# Wait for the comonents to start
kubectl -n gcp-filestore-csi-driver wait --for condition=ready \
  pods -l app=gcp-filestore-csi-driver \
  --timeout 300s

# Install the storage class
#   The name is important (it is used in the Helm overrides file for GKE), but the parameters
#   should be tweaked, in particular the location
kubectl apply -f ./cluster/kubernetes/gke/filestore-storageclass.yaml
```


## Configure and deploy ESGF components

As with [Minikube](../minikube/), configuration is very similar to
[Docker Compose](../../compose/quick-start/#configure-environment).

First, configure the DNS entry you want to use for your node to point to the external IP of the Nginx
Controller's Service. For testing, you can use an [xip.io](http://xip.io/) domain:

```bash
ESGF_HOSTNAME="$(kubectl -n kube-system get service ingress-nginx-ingress-controller | tail -n 1 | awk '{ print $4; }').xip.io"
```

Then generate the required configuration and run the Helm chart to deploy the ESGF components:

```bash
# This should be an empty directory
export ESGF_CONFIG=/path/to/esgf/config
# Create an environment file containing the hostname
cat > "$ESGF_CONFIG/environment" <<EOF
ESGF_HOSTNAME=${ESGF_HOSTNAME}
EOF
# Generate configuration
./bin/esgf-setup generate-secrets
./bin/esgf-setup generate-test-certificates
./bin/esgf-setup create-trust-bundle
# Deploy the ESGF components
./bin/esgf-setup helm-values gke | \
    helm upgrade my-node cluster/kubernetes/charts --install -f -
# Wait for the ESGF components to start
kubectl wait --for condition=ready pods -l release=my-node --timeout 600s
```

You can inspect the state of the pods using `kubectl get pods`, or by using the GCP web console.

Once all the containers are running, you should have a functional ESGF node at `https://${ESGF_HOSTNAME}`.


## Test publication

A test publication should work [as for Minikube](http://localhost:4000/kubernetes/minikube/#test-publication).


## Cleanup

To uninstall the ESGF components, run:

```bash
helm delete --purge my-node
```

This should delete all the Kubernetes resources for the ESGF deployment. It will also delete any GCE persistent
disks associated with the RWO `PersistentVolumeClaim`s used by the various Postgres databases and Solr indexes.

Currently, the GCP Filestore CSI driver does **not** delete the Filestore instances it creates, so they need to
be deleted manually.

<div class="note note-warning" markdown="1">
To delete **all** Filestore instances for the current project, you can use this command:

```bash
gcloud beta filestore instances list --format="value(name)" | \
  xargs -n 1 gcloud beta filestore instances delete
```
</div>

To delete the cluster:

```bash
gcloud container clusters delete esgf-node
```

To remove the service account and IAM policy bindings for the GCP Filestore CSI provisioner service account:

```bash
PROJECT="$(gcloud config get-value project)"
IAM_NAME="gcp-filestore-csi-driver-sa@${PROJECT}.iam.gserviceaccount.com"

# Remove the IAM policy binding
gcloud projects remove-iam-policy-binding "$PROJECT" \
  --member "serviceAccount:${IAM_NAME}" \
  --role roles/file.editor
# Remove the service account
gcloud iam service-accounts delete "$IAM_NAME"
```
