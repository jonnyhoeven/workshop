
# Workshop

## Introduction

This document provides a high-level overview of the Kubernetes cluster.
and provides a starting point for onboarding ops team members to Kubernetes.

Topics Overview:

- Kubernetes concepts
    - Custom Resource Definitions
    - Declarative vs imperative
    - Health checks
    - Containers reside in Pods
    - Pods expose their ports to Services
    - Ingress connects Services to the outside world
    - Namespaces
    - ConfigMaps and Secrets
    - Pod Reload
    - Draining
    - Persistent Volumes Claims and Storage Classes
    - Difference between k3s and k8s
    - Helm
    - Git-ops with ArgoCD
- The Workshop

## Kubernetes concepts

Kubernetes is a container orchestration platform that automates the deployment, scaling, and management of containerized
applications. It is a portable, extensible, open-source platform for managing containerized workloads and Services, that
facilitates both declarative configuration and automation.

### Custom Resource Definitions

Kubernetes has a concept of Custom Resource Definitions (CRDs). CRDs are a way to extend the Kubernetes API and create
new resources. This allows developers to create their own resources and controllers to manage these resources.
for example, the ArgoCD operator creates a new resource called an Application. This resource can be used to define
applications and their configuration in a declarative way. It's then up to the ArgoCD operator to manage these
applications and ensure they are in the desired state.
It's important to understand that CRDs are a way to extend the Kubernetes API and create new resources. This concept is
used in many operators, controllers, helm charts, ingress classes, storage classes to create new resources and manage
them individually.

### Declarative vs imperative

Declarative means you define the desired state of the system and Kubernetes
automatically changes the current state to the desired state the best way it can.

### Health checks

Health checks are integral to determine if a container is healthy or not. Kubernetes supports three types of health
checks: livenessProbe, readinessProbe, and startupProbe. These can be simple HTTP Error Codes, HTTP requests or custom
healthcheck endpoints containing json data kubernetes can parse.

Kubernetes utilizes Health Probes to determine if a container is healthy or not. If a container is not healthy,
Kubernetes
will restart the container. Kubernetes will not send traffic to that container.

This means developers can define the health-result of their application and Kubernetes will take care of the rest.

If you want to update a container image to a new version you can do this by updating the deployment manifest. Kubernetes
sees the change in the desired state and will automatically update the running containers to the new version.

However, Kubernetes won't just kill the old containers and start new ones. It will do this in a controlled manner. It
first starts up the new container and waits for it to be healthy. Then it will stop the old container to prevent
downtime. It's therefore important to have concise health checks in place, developers should be encouraged to manipulate
health checks if they deem a service misbehaving or unavailable.

### Containers reside in Pods

A Pod is the smallest deployable unit in Kubernetes. A Pod represents a single instance of a running process in your
cluster. Pods contain one or more containers. When a Pod runs multiple containers, the
containers are managed as a single entity and share the same resources.

More importantly, containers in a pod share the same lifecycle, they are started together, stopped together, and are
considered atomic.

A Pod can be considered a separate subnetwork, containers within a pod are effectively behind NAT (Network Address
Translation). Inside this Pod containers can rely on a local DNS service to resolve hostnames to each internally.

Since networking and state is separate and atomic this means you can run multiple replica's of the same Pod and increase
availability. Without the need to worry about state or networking from a container perspective.

### Pods expose their ports to Services

Services provide a way to expose an application running on a set of Pod replica's as a network service.
Services are mostly abstraction/glue for Pods and Ingress. They provide a stable endpoint for Pods and Ingress to
connect.

### Ingress connects Services to the outside world

Ingress is a collection of rules that allows inbound connections to reach the cluster Services.
It can be used to allow external ingress to different services via ports, load balancers, URL hostname.
Plugins for Common Authority Certificates en Cert Manager using Let's Encrypt are easily installed.

### Namespaces

Another important concept in Kubernetes is Namespaces. Namespaces are a way to divide cluster resources between
different tenants, teams or applications.

It's a powerful tool to divide resources and provides isolation between different applications. Commonly used to
divide resources between different environments like development, staging, and production.
Ideally the only difference between staging and production should be a namespace Configmap and Secrets.

The ```default``` namespace is the default namespace for objects with no other namespace. It's important to note that
namespaces are not a security boundary, they are a way to divide resources and provide isolation between different
applications. It's important to note that resources in different namespaces can communicate with each other.

### ConfigMaps and Secrets

ConfigMaps are a Kubernetes resources that allows decoupled configuration artifacts from image content in an
effort to keep containerized applications portable.

When you need to store sensitive information, such as passwords, OAuth tokens, and SSH keys, you can use Secrets.
If you need to store non-sensitive configuration data, you can use ConfigMaps.

ConfigMaps and Secrets can be mounted as files or environment variables in a Pod. Containers in a pod might need to be
drained to apply the latest configuration changes.

### Pod Reload

In most cases (when no active "operator" is present) a pod will not reload when a configmap or secret is updated.
This is because the pod is not aware of the change and won't get drained.

### Draining

Draining is the process of gracefully terminating a node and moving its workloads to other nodes in the cluster. This is
useful when you need to perform maintenance on a node or when you want to remove the workload while maintaining
availability using the other nodes.

This also applies to pods, when a pod is draining it will not accept new connections and will gracefully terminate.
**Don't delete pods when there is no other replica, use the drain command.**

### Persistent Volumes Claims and Storage Classes

It's important to note that k3s is a lightweight Kubernetes distribution and does not come with most storage classes.
Most of these classes are provided by the cloud provider or need to be installed manually when on bare metal.

### Difference between k3s and k8s

K3s is a lightweight Kubernetes distribution. It is a fully compliant Kubernetes distribution some differences.

K3S is a lightweight Kubernetes distribution. It is a fully compliant Kubernetes distribution with some differences.
It's a perfect candidate for edge computing, IoT, and CI/CD. It's lightweight, easy to install, and has a small
footprint.

K8S contains a lot of features in the default build that are not always needed, helm charts for most missing k3s
features
can also be installed via helm charts.

Some feature differences:

- Included Storage classes
- Traefik ingress controller
- Arm64 support
- Memory footprint

### Helm

Helm is a package manager for Kubernetes. It allows you to define, install, and upgrade complex Kubernetes applications.
Helm is a tool that streamlines installing and managing Kubernetes applications.

Think of it like apt/yum/homebrew for Kubernetes. Helm charts allow you to define values that control the applied
Kubernetes manifests.

Helm charts are available for most applications and services.

When ArgoCD is available on a cluster it's important to note that helm can be handled differently in ArgoCD.
Helm charts can be installed as a regular application in ArgoCD.

Helm charts are handled differently with ArgoCD to provide rollbacks and prevent influence from volatile external
sources.

## Git-ops with ArgoCD

ArgoCD is highly available (on all nodes have replicated state), It's a continuous delivery tool for Kubernetes based on
external sources, most commonly git repositories.

It follows the GitOps pattern of using Git repositories as the source of truth for defining the desired application
state. ArgoCD is very declarative and all it's configuration is stored in a Git repository also.

You'll need to install kubectl to interact with the cluster.

## The Workshop

Let's start doing stuff ourselves!

## Requirements

### Kubectl

Kubectl is a command line tool for controlling Kubernetes clusters. It is used to deploy, inspect and
manage cluster resources, and view logs.

[Reference](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

```bash
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl

# If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

### K3D (K3s in Docker) cluster setup

K3D is a lightweight wrapper to run k3s (Rancher Lab's minimal Kubernetes distribution) in docker. It is a single binary
that deploys a k3s server in a docker container. K3D makes it very easy to create single and multi-node k3s clusters in
docker, and it is also possible to run multiple clusters at the same time.

[Reference](https://k3d.io/v5.6.0/#quick-start)

```bash
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

### Docker

If running in Windows (WSL) you'll need [Docker Desktop](https://www.docker.com/products/docker-desktop/),
otherwise you can install docker using this
guide: [Install on Linux](https://docs.docker.com/desktop/install/linux-install/)

### Lens

Lens is a Kubernetes IDE that allows you to manage and monitor your clusters, and deploy.

Recently some features were removed from Open Lens. Plugins replacing this functionality aren't yet working properly.
So for now, it's recommended to use the Mirantis version of Lens.

- [Lens](https://k8slens.dev/desktop.html) (From Mirantis)
- [Open Lens](https://flathub.org/apps/dev.k8slens.OpenLens) (Open Source version)

## Start a new Kubernetes cluster

[Reference](https://k3d.io/v5.3.0/usage/commands/k3d_cluster_create/)

We'll be creating 1 server and 2 agents/workers for our cluster.
Normally for high availability you'll want to have at least 2 control planes, each with 2 agents.
but for this example we'll keep it simple.

We'll name this cluster `workshop`.

```bash
k3d cluster create workshop --agents 2 --servers 1
```

Once completed, you can check the status of your cluster by running:

```bash 
k3d cluster list
```

## Access the cluster using kubectl

Kubeconfig is a file that holds information about cluster, including the hostname, certificate authority, and
authentication information. It's installed by kubectl at `~/.kube/config` by default, and can be used by other
applications to connect to the cluster. Keep this file secure, it's the key to your cluster.

The default kubeconfig file is located at `~/.kube/config`, you can check the current the file by running:

```bash
cat ~/.kube/config
```

K3D automatically update the kubeconfig file for you, so you can access this development cluster using kubectl.
In normal situations you'll need to obtain the kubeconfig file from the cluster and set it up manually.

You can get the config from k3d by running:

```bash
k3d kubeconfig get workshop > kubeconfig.yaml
```

- Update your `~/.kube/config` file with the newly generated [kubeconfig.yaml](./kubeconfig.yaml) file.

e.g. on linux:

```bash
mv ~/.kube/config ~/.kube/config.bak
mv ./kubeconfig.yaml ~/.kube/config
```

- Check the cluster info using kubectl cluster-info

```bash
kubectl cluster-info
```

```text
Kubernetes control plane is running at https://0.0.0.0:35357
CoreDNS is running at https://0.0.0.0:35357/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://0.0.0.0:35357/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

- Check the nodes in the cluster using kubectl

```bash
kubectl get nodes
```

## Access the cluster using Lens

Setup Lens to use the new cluster by adding a new cluster from kubeconfig.

- Windows WSL users:
  Click on `Catalog` (Top left, second from top) → `Clusters` → `Add Cluster (+) icon` → `Add Cluster from Kubeconfig`
  → Paste the contents of your kubeconfig file → `Add Clusters`

- Linux's users:
  Just import the kubeconfig file using the `Add Cluster from Kubeconfig` option.

Now you can access the `k3d-workshop` cluster using Lens.

Browse around, check the `nodes`, `namespaces`, and `pods` sections.

## Some notes about Namespaces

Namespaces are a way to divide cluster resources between multiple users (via resource quota) and multiple projects (via
separation of resources). They are intended for use in environments with many users spread across multiple teams, or
projects. Namespaces are not a security feature, to isolate different users or namespaces from each other there are
addons like
[Loft](https://loft.sh/) that leverages RBAC (Role based account control) to securely isolate namespaces across teams.

By default, Kubernetes starts with four initial namespaces:

- `default`, The default namespace for objects with no other namespace. Try not to use this namespace for your own
  objects.
- `kube-system`, The namespace for objects created by the Kubernetes system.
- `kube-public`, This namespace is created automatically and is readable by all users (including those not
  authenticated).
- `kube-node-lease`, This namespace is used for the lease objects associated with each `node` which improves the
  performance
  of the `node` heartbeats as the cluster scales.

## Create your own namespace

Let's create a new namespace to work with and deploy an application to it.
Let's call it `workshop`.

```bash
kubectl create namespace workshop
```

### Deploy an application manually

We'll deploy a simple nginx web server to our cluster.

`-n` or `--namespace` is used to specify the namespace to deploy the application to.
If you don't provide a namespace, the application will be deployed to the `default` namespace by default.
Resulting in hard to manage and hard to find resources.

```bash
kubectl create deployment nginx --image=nginx -n workshop
```

- Check the `deployment` and `pod` status with kubectl

```bash
kubectl get deployment -n workshop
```

```text
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           2m3s
```

```bash
kubectl get pod -n workshop
```

```text
# NAME                     READY   STATUS    RESTARTS   AGE
# nginx-7854ff8877-z9j2t   1/1     Running   0          49s
```

- Find the `deployment` in lens and check the `pod` status.
  As you can see, the `deployment` is running and the `pod` is up and running.

- Try deleting the `pod` and see what happens.

```bash
kubectl delete pod <pod-name> -n workshop
```

The `pod` gets deleted, and a new one is created to replace it. This is because the `deployment` is set to have 1
replica, so if the `pod` is deleted, a new one is created to replace it.

- List the `pods` again

```bash
kubectl get pod -n workshop
```

The `pod` is running again, but now it's got a different name.

It's important to note that the `deployment` is the object that manages the `pod`, and the `pod` is the object that runs
one or more containers.

It's recommended to use `Evict` or `Taint` instead of deleting definitions, to avoid downtime.
This will result in kubernetes creating a new `pod` and wait for it to be ready before deleting the old tainted `pod`.

- Delete the `deployment` and check the `pod` status again.

```bash
kubectl delete deployment nginx -n workshop
```

```bash
kubectl get pod -n workshop
```

Without the declaration for the `deployment`, the `pod` is also deleted.

- Clean up the namespace

```bash
kubectl delete namespace workshop
```

### Deploy using a manifest files from code

Normally you'll want to deploy using a manifest file, so you can keep track of your `deployments` and
easily replicate them across different clusters. With version control to keep track of changes.

__Before we start make sure you're in the correct working directory__

- Create the `cat-app` namespace again using kubectl:

```bash
kubectl create namespace cat-app
```

- Deploy the cat-app `deployment` to the `cat-app` namespace using the manifest files.

```bash
kubectl apply -f ./namespace/cat-app/cat-app.Deployment.yaml -n cat-app
kubectl apply -f ./namespace/cat-app/cat-app.Service.yaml -n cat-app
kubectl apply -f ./namespace/cat-app/cat-app.Ingress.yaml -n cat-app
```

- You can also deploy a complete folder using kubectl, this will deploy all the files in the folder, try it now.

```bash
kubectl apply -f ./namespace/cat-app/ -n cat-app
```

- Get familiar with the files in the `cat-app` folder, and try to understand what each file does.
- Notice the URL in the cat-app.Ingress.yaml file, this is the `URL`, `Virtual Host` you'll use to access the cat-app.
- Notice the `Service` file, this is the service that will be used to expose the cat-app to the internet. it uses the
  type `ClusterIP` more on that later.
- For now check the `deployment` and `pod` status with kubectl or lens

```bash
kubectl get deployment -n cat-app
kubectl get pod -n cat-app
````

- Check the service and ingress status with kubectl or lens

```bash
kubectl get service -n cat-app
kubectl get ingress -n cat-app
```

Ingress is a collection of rules that allow inbound connections to reach the cluster services. It can be configured to
give services externally-reachable URLs, load balance traffic, terminate SSL, offer name-based virtual hosting, and
more.

```text
NAME      CLASS    HOSTS               ADDRESS                            PORTS   AGE
cat-app   <none>   cat-app.k3d.local   172.20.0.2,172.20.0.3,172.20.0.4   80      2m1s
```

- Notice the `cat-app.k3d.local` URL, this is the URL you'll use to access the cat-app.
- Notice the `ADDRESS` field, this is the IP address of the service, it's a `ClusterIP` type service and is available on
  all kubernetes Nodes ip in the cluster. If a node does not have the cat-app `pod`, it will forward the request to a
  node
  that does host the cat-app `pod`.
- More commonly you'll see `LoadBalancer` type services, which will use the cloud provider's or on premises load
  balancer to expose the service to the internet.
- Try changing the `replicas` in the `cat-app.Deployment.yaml` file and apply the changes using kubectl.

### Accessing the cat-app

First we need to update our hosts file, normally you'll use a DNS server to resolve the URL to the IP address, and sign
certificates automatically with let's encrypt.

- Edit your hosts file and add the cat-app hostname to it.

```bash
sudo nano /etc/hosts
```

Or use notepad in windows, open it as administrator, open the file `C:\Windows\System32\drivers\etc\hosts`

Use the output from the `kubectl get ingress -n cat-app` command to add the IP address and the URL to the hosts file.
For example:

```text
172.20.0.2 cat-app.k3d.local
172.20.0.3 cat-app.k3d.local
172.20.0.4 cat-app.k3d.local
```

Now browse to [http://cat-app.k3d.local/](https://cat-app.k3d.local/) and you should see the nginx welcome page.

### Start deploying using ArgoCD

- Make sure you forked this repo before editing files, and clone your forked repo to your local machine. Later on you'll
  push the changes to your fork to control ArgoCD the Gitops way.

- To use ArgoCD we need to create the `argocd` namespace and deploy the ArgoCD application with
  configmap, ingress and service. This command is not recursive, so only files in the `argocd` folder will be deployed,
  sub folders are ignored.

```bash
kubectl create namespace argocd
kubectl apply -f ./namespace/argocd -n argocd
```

- Edit your hosts file and add the `argocd.k3d.local` hostname to it.

```text
172.20.0.2 argocd.k3d.local
172.20.0.3 argocd.k3d.local
172.20.0.4 argocd.k3d.local
```

- Extract the ArgoCD admin password, we first request the secret and then decode the password using base64 to plain
  text. The initial password is randomly generated and unique to each ArgoCD installation.
- ArgoCD also provides a CLI tool to interact with the API, but for now we'll use kubectl.

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode
```

*** There can be a `%` at the end of the password (no newline), ignore it when pasting the password. ***

- Browse to [argocd.k3d.local](https://argocd.k3d.local), username: `admin`, password: `password from previous command`.
  Normally we would delete this initial secret after using it, and set a new admin password. but for now we'll keep it as
  is.

- This repository already has a [repository](./namespace/argocd/repository/argocd.Repository.yaml) file, update the repo
  url to your forked repo and apply the repository.

```bash
kubectl apply -f ./namespace/argocd/repository/argocd.Repository.yaml -n argocd
```

- The [repository](https://argocd.k3d.local/settings/repos) is now visible in the ArgoCD UI.

- The [application](./namespace/argocd/application/cat-app.Application.yaml) file is also already in the repository,
  update
  the repo url to your forked repo and apply the application.

```bash
kubectl apply -f ./namespace/argocd/application/cat-app.Application.yaml -n argocd
```

- Commit and push the change to your branch.

- Apply the application to ArgoCD.

```bash
kubectl apply -f ./namespace/argocd/application/cat-app.application.yaml -n argocd
```

- Browse to [https://argocd.k3d.local/applications/argocd/cat-app](https://argocd.k3d.local/applications/argocd/cat-app)
- Press the `sync` button to sync the application with the repository.
- Your cat app is now deployed using ArgoCD.

### ArgoCD can Git Ops itself

We just deployed the cat app using ArgoCD, but we still needed kubectl to apply the application. ArgoCD can also manage
itself using GitOps, so we can deploy the cat-app by adding a new file in the `namespace/argocd/application` folder.

- First edit [argocd.application.yaml](./namespace/argocd/application/argocd.Application.yaml) and change `repoURL` to
  your
  fork, then apply the application manifest.

```bash
kubectl apply -f ./namespace/argocd/application/argocd.Application.yaml -n argocd
```

Since we added the application to the repository and sync is enabled in the ArgoCD application, it will automatically
maintain, prune and heal the ArgoCD namespace based on the repository state.

- Try deleting the cat-app in the ArgoCD gui, and see what happens.

Argo cd Notice that the cat-app is missing and will automatically recreate it.
The cat-app is still running, because the `deployment` is still in the kubernetes cluster.

- Edit the cat-app application yaml, and uncomment lines below  `syncPolicy` to enable auto sync on the cat app.

- Commit and push the changes to your fork

### Cloud Native Postgres

Since we took our time to automate our GitOps, We can easily deploy a cloud native database using the same approach.
In fact, we already have a [Postgres](./namespace/argocd/application/postgres.Application.yaml) application file.
Since autosync is enabled, the postgres database cluster was deployed automatically.

See [cluster-example.Cluster.yaml](namespace/cnpg-system/cluster-example.Cluster.yaml) for the cluster configuration.

### Delete the cluster

- To keep your system clean, you can delete the cluster by running:

```bash
k3d  cluster delete mycluster 
```

- Remember to delete the kubeconfig file if you don't need it anymore.

```bash
rm ~/.kube/config
```
