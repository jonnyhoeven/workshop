### Introduction

This workshop is designed to provide basic understanding of Kubernetes and ArgoCD.

During the workshop, we'll be deploying a simple application to your Kubernetes cluster using Kubectl. Later we'll
deploy the same application using ArgoCD using your new git repository. Meanwhile, we'll be checking out multiple tools
to communicate with and control Kubernetes clusters.

After this workshop:

- You'll have a development Kubernetes cluster you can tinker with from your own git repository.
  This means you'll be able to _deploy_, _update_ and _delete_ applications remotely and declaratively from your
  own (private) git repository to your development cluster.

- Inside out, your cluster will be managed by ArgoCD, which will be managed by the contents of your git repository.
  It's looking for changes in your git repository and will apply them to your cluster.
- You'll be able to deploy applications using kubectl, use manifest files and ArgoCD or Git-Ops to
  deploy your `manifests`.
- You'll understand the difference between `declarative` vs `imperative` statements and the vital importance of proper
  `health checks` in conjunction with `livenessProbe`, `readinessProbe` and `startupProbe`.
- Yes, kubernetes has some deep dark `logic`, it's a declarative system that will try to maintain the desired state and
  might do some unexpected things if you're not careful. Puppet and Ansible are also imperative systems, they will do
  the same thing every time you run them.
- You'll understand the difference between `Pods`, `Services`, `Ingress`, `Namespaces`, `ConfigMaps` and `Secrets`.
- You'll understand the difference between `K3S` and `K8S` and the importance of `Helm` and `Lens`.

<iframe
src="https://docs.google.com/presentation/d/e/2PACX-1vTwUNGkjI-YYRBIXGol9IpAwuzhIPCXTP01DUP8k-cV1_0Z8Kilxw6VyfaXS70pRMfuTJeTrYkpZS0C/embed?start=false&loop=false&delayms=15000"
frameborder="0" width="100%"
height="414pt"
allowfullscreen="true"
mozallowfullscreen="true"
webkitallowfullscreen="true"></iframe>

### Kubernetes concepts

- Kubernetes is a container orchestration platform that automates deployment, scaling and management of containerized
  applications.
- It's declarative, meaning you define the desired state of the system and Kubernetes automatically changes the current
  state to the desired state the best way it can.
- It's designed to be extensible and scalable and it's built to handle a wide range of workloads, from stateless
  to stateful applications.

### Extendable - Custom Resource Definitions (CRD's)

- Kubernetes utilizes Custom Resource Definitions (CRDs) for extendability.
- CRDs allow extendability for the Kubernetes API by creating new resources classes.

This allows developers to create their own resources or controllers to manage these resources.

For example, the ArgoCD operator creates a new resource called an Application. This resource can be used to define
applications and their configuration in a declarative way. It's then up to the ArgoCD operator to manage these
applications and ensure they're in the desired state.

It's important to understand that CRD's are methods to extend the Kubernetes API and create new resources. This concept
is used in many operators, controllers, helm charts, ingress classes, storage classes to create new resources and manage
them individually.

### Declarative vs Imperative

Declarative means you define the desired state of the system and Kubernetes automatically changes the current state to
the desired state the best way it can.

This has a mayor impact, small changes in the desired state can have a big impact on the current state. It's important
to understand the difference between the desired states of the system to prevent unwanted changes.

However, it's also a powerful tool to manage the system. Instead of writing a series of commands to
put the system in a certain state, you declare the desired state and Kubernetes will do the rest.

### Health Checks

Health checks are integral to determine if a container is healthy or not. Kubernetes supports three types of health
checks: livenessProbe, readinessProbe and startupProbe.

Kubernetes utilizes Health Probes to determine if a container is healthy or not. If a container isn't healthy,
Kubernetes will restart the container. Afterwards Kubernetes will not send traffic to that container.

Developers can define the health-result of their application and Kubernetes will take care of the rest.

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

More importantly, containers in a pod share the same lifecycle, they're started together, stopped together and are
considered atomic.

A Pod can be considered a separate subnetwork, containers within a pod are effectively behind NAT (Network Address
Translation). Inside this Pod containers can rely on local DNS services to find hostnames in their own or different
namespaces.

Since networking and state is separate and also atomic this means you can run multiple replica's of the same Pod and
increase availability. Without the need to worry about state or networking from a container perspective.

### Pods expose their ports to Services

Services provide a method to expose applications running on a set of Pod replica's as a network service.
Services are mostly abstraction/glue for Pods and Ingress. They provide a stable endpoint for Pods and Ingress to
connect to.

### Ingress connects Services to the outside world

Ingress is a collection of rules that allows inbound connections to reach the cluster Services.
It's used to allow external ingress to different services via ports, load balancers, Virtual Hostnames or SSL
termination using
Common authority or Cert Manager using Let's Encrypt API.

### Namespaces

Another important concept in Kubernetes is Namespaces. Namespaces are used to divide cluster resources between
different tenants, teams or applications.

It's a powerful tool to divide resources and provides isolation between different applications. Commonly used to
divide resources between different environments like development, staging and production.
Ideally the only difference between staging and production should be a namespace Configmap and Secrets.

The ```default``` namespace is the default namespace for objects with no other namespace. It's important to note that
namespaces are not a security boundary, just methods to divide resources and provide isolation between different
applications. It's important to note that resources in different namespaces can communicate with each other.

### ConfigMaps and Secrets

ConfigMaps are a Kubernetes resources that allows decoupled configuration artifacts from image content in an
effort to keep containerized applications portable.

When you need to store sensitive information, such as passwords, OAuth tokens and SSH keys, you can use Secrets.
If you need to store non-sensitive configuration data, you can use ConfigMaps.

ConfigMaps and Secrets can be mounted as files or environment variables in a Pod. Containers in a pod might need to be
drained/restarted to reload the latest environment configuration changes.

### Pod Reload

In most cases (when no active "operator" is present) a pod will not reload when a configmap or secret is updated.
This is because the pod is not aware of the change and won't get drained/restarted.

### Draining

Draining is the process of gracefully terminating a node and moving its workloads to other nodes in the cluster. This is
useful when you need to perform maintenance on a node or when you want to remove the workload while maintaining
availability using the other nodes.

**Don't delete pods when there is no other replica, use the drain command.**

### Difference between k3s and k8s

K3s is a lightweight Kubernetes distribution. It's a fully compliant Kubernetes distribution with some differences.

It's a perfect candidate for edge computing, IoT and CI/CD. It's easy to install and has a small
footprint.

K8S contains a lot more features that are not always needed.

Some feature differences:

- Included Storage classes
- Traefik ingress controller
- Arm64 support
- Memory footprint

### Helm

Helm is a package manager for Kubernetes. It allows you to define, install and upgrade complex Kubernetes applications.
Helm is a tool that streamlines installing and managing Kubernetes applications.

Think of it like `apt`, `yum` or `Homebrew` for Kubernetes. Helm charts allow you to define values that control the
applied Kubernetes manifests files. A semi aware templating engine for kubernetes yaml files.

Helm charts are available for most applications and services.

When ArgoCD is available on a cluster it's important to note that helm can be handled differently in ArgoCD.
Helm charts can be installed and managed as a regular ArgoCD application.

## The Workshop

We're going to deploy a simple application to a Kubernetes cluster using Kubectl,
then we'll deploy the same application using ArgoCD,
along the way we'll be checking out multiple tools to configure a Kubernetes cluster.

- We'll end up with a cluster you can tinker with from your own git repository.

- It follows the GitOps pattern of using Git repositories as the source of _truth_ that defines the desired state.
  ArgoCD is very declarative and all configuration is stored in Git repositories.

Let's get started, first open up a terminal to run linux/bash commands.

### Requirements

- We'll need _some_ tools to get our cluster running.

### Kubectl AKA Kube-Cuttle or Kube-Control

Kubectl is a command line tool for controlling Kubernetes clusters. It's used to deploy, inspect and
manage cluster.

[Reference](https://kubernetes.io/docs/tasks/tools/install-Kubectl-linux/)

```bash
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl
# If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command.
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

### K3D (K3S in Docker) cluster setup

K3D is a lightweight wrapper to run K3S (Rancher Lab's minimal Kubernetes distribution) in docker. It's a single binary
that deploys a K3S server in a docker container. K3D makes it very easy to create single and multi-node K3S clusters in
docker, it's possible to run multiple clusters at the same time on your development machine.

[Reference](https://k3d.io/v5.6.0/#quick-start)

```bash
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

### Docker

- **Windows** you'll need [Docker Desktop](https://www.docker.com/products/docker-desktop/).

- **Linux** Install Docker.io:

[Reference](https://packages.debian.org/sid/docker.io)

```bash
sudo apt install docker.io
sudo groupadd docker
sudo usermod -aG docker $USER
```

### Lens

Lens is a Kubernetes IDE that allows you to manage, monitor and manipulate your clusters.

Recently some features were removed from Open Lens. Plugins replacing this functionality aren't yet working properly.
So for now, it's recommended to use the Mirantis Free version of Lens.

- [Lens](https://k8slens.dev/desktop.html) (Mirantis)
- [Open Lens](https://flathub.org/apps/dev.k8slens.OpenLens) (Open Source version)

### Starting your Kubernetes cluster

[Reference](https://k3d.io/v5.3.0/usage/commands/k3d_cluster_create/)

We'll be creating 1 server and 2 agents for our cluster. Normally for high availability you'll want to have at least 2
control planes, with 3 agents/workers _each_. For this example we'll keep it simple.

We'll name this cluster `workshop`.

```bash
sudo k3d cluster create workshop --agents 2 --servers 1
```

Once completed, you can check the status of your cluster by running:

```bash
sudo k3d cluster list
```

### Access the cluster using Kubectl

Kubeconfig is a file that holds information about clusters, including the hostname, certificate authority and
authentication information. It's located at `~/.kube/config` and can be used by other
applications to connect to the cluster. Keep this file secure, it's the **key** to your cluster.

You can get the kubeconfig file from K3D by running:

```bash
sudo k3d kubeconfig get workshop > kubeconfig.yaml
```

- Update your user `~/.kube/config` file with the newly generated [kubeconfig.yaml](kubeconfig.yaml) file.

```bash
mv ~/.kube/config ~/.kube/config-$(uuidgen) #Backup any existing kubeconfig
```

```bash
mv ./kubeconfig.yaml ~/.kube/config
```

- Check cluster info

```bash
kubectl cluster-info
```

- Check the cluster Nodes

```bash
kubectl get nodes
```

### Access the cluster using Lens

Setup Lens to use the new cluster by adding a new cluster from the [kubeconfig.yaml](kubeconfig.yaml) file.

- Click on `Catalog` (Top left, second from top) → `Clusters` → `Add Cluster (+) icon` → `Add Cluster from Kubeconfig`
  → Paste the contents of your kubeconfig file → `Add Clusters`

- Or import the kubeconfig file using the `Add Cluster from Kubeconfig` option.

Now you can access the `k3d-workshop` cluster using Lens.

Browse around, check the `Nodes`, `Namespaces`, `Custom Resource Definitions` and `Pods`.

### Some notes about Namespaces

Namespaces divide cluster resources and quota's.
They're intended for use in environments with many users spread across multiple teams or
projects. Namespaces are not a security feature, to isolate different users or namespaces from each other we need tools
like [Loft](https://loft.sh/) that leverage RBAC (Role based account control) to securely isolate namespaces
across teams.

By default, Kubernetes starts with four initial namespaces:

```bash
kubectl get namespaces
```

- `default`, The default namespace for objects with no other namespace. Try not to use this namespace for your own
  objects.
- `kube-system`, The namespace for objects created by the Kubernetes system.
- `kube-public`, This namespace is created automatically and is readable by all users (including those not
  authenticated).
- `kube-node-lease`, This namespace is used for the lease objects associated with each `node` which improves the
  performance of the `node` heartbeats as the cluster scales.

### Create your own namespace

Let's create a new namespace and deploy an application in the `workshop` namespace.

```bash
kubectl create namespace workshop
```

### Deploy your application manually

We'll deploy nginx web server to our cluster.

The `-n` or `--namespace` parameter is used to specify the namespace to deploy the application to.
If you don't provide a namespace, the application will deploy to the `default` namespace.
Resulting in naming conflicts and hard to find, hard to manage resources.

```bash
kubectl create deployment nginx --image=nginx -n workshop
```

- Check the `deployment` and `pod` status with Kubectl

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
  As you can see, the `deployment` and `pod` replica is up and running.

- Try deleting the `pod` and see what happens.

```bash
kubectl delete pod $(kubectl get pods -n workshop -o jsonpath="{.items[*].metadata.name}") -n workshop
```

The `pod` gets deleted and a new one is created to replace it. This is because the `deployment` is set to have 1
replica, so if the `pod` is deleted, a new one is created to replace it.

- List the `pods` again

```bash
kubectl get pod -n workshop
```

The `pod` is running again, but now it's got a _different_ name.

It's important to note that the `deployment` manifest manages the `pod` and a `pod` can be replicated.

To avoid downtime it's recommended to use `Evict` or `Taint` instead of deleting definitions.
This will result in Kubernetes creating a new `pod` and wait for it to be ready before deleting the old `evicted pod`.

- Delete the `deployment` and check the `pod` status again.

```bash
kubectl delete deployment nginx -n workshop
```

```bash
kubectl get pod -n workshop
```

Without the `deployment` manifest with a minimal `pod` replica count, the `pod` is removed.

- Clean up the namespace.

```bash
kubectl delete namespace workshop
```

### Deploy using manifest files from code

Normally you'll want to deploy using a manifest file, so you can keep track of your `deployments` and
easily replicate them across different clusters or namespaces.

__Before starting make sure you're in the correct working directory.__

- Create the `cat-app` namespace using Kubectl:

```bash
kubectl create namespace cat-app
```

- Deploy the cat-app `deployment` to the `cat-app` namespace using the manifest files.

```bash
kubectl apply -f ./namespace/cat-app/cat-app.Deployment.yaml -n cat-app
kubectl apply -f ./namespace/cat-app/cat-app.Service.yaml -n cat-app
kubectl apply -f ./namespace/cat-app/cat-app.Ingress.yaml -n cat-app
```

- You can deploy a complete folder using Kubectl, this will deploy all the files in one folder, try it.

```bash
kubectl apply -f ./namespace/cat-app/ -n cat-app
```

- Get familiar with the files in the `cat-app` folder and try to understand what each file does.
- Notice the URL in the cat-app.Ingress.yaml file, this is the `URL`, `Virtual Host` you'll use to access the cat-app.
- Notice the `Service` file, this is the service that will be used to expose the cat-app to the internet. it uses the
  type `ClusterIP`.
- For now check the `deployment` and `pod` status with Kubectl or lens.

```bash
kubectl get deployment -n cat-app
````

```bash
kubectl get pod -n cat-app
````

- Check the service and ingress status with Kubectl or lens.

```bash
kubectl get service -n cat-app
```

```bash
kubectl get ingress -n cat-app
```

Ingress is a collection of classes that allow inbound connections to reach the cluster services. It can be configured to
give services externally-reachable URLs, load balance traffic, terminate SSL, offer name-based virtual hosting and
more.

```text
NAME      CLASS    HOSTS               ADDRESS                            PORTS   AGE
cat-app   <none>   cat-app.k3d.local   172.20.0.2,172.20.0.3,172.20.0.4   80      2m1s
```

- Notice the `cat-app.k3d.local` URL, this is the URL you'll use to access the cat-app.
- Notice the `ADDRESS` field, this is the IP address of the service, it's a `ClusterIP` type service and is available on
  all Kubernetes Nodes in the cluster. If a node does not have the cat-app `pod`, it will forward the request to other
  nodes that host the cat-app `pod` selector.
- More commonly you'll see `LoadBalancer` type services, which use cloud provider's or on premises load balancers to
  expose the services to other networks/internet.

### Accessing the cat-app

First we need to update our hosts file, normally you'll use a DNS server to resolve the URL to the IP address and sign
TLS certificates automatically with `let's encrypt` or a `Common Authority` certificate.

- Use the output above to update your hosts file:

```text
# Workshop K3D cluster
172.xx.0.2 cat-app.k3d.local
172.xx.0.3 cat-app.k3d.local
172.xx.0.4 cat-app.k3d.local
172.xx.0.2 argocd.k3d.local
172.xx.0.3 argocd.k3d.local
172.xx.0.4 argocd.k3d.local
```

- Add the correct IP addresses to your hosts file:

Windows:

- Open notepad as administrator, open the file `C:\Windows\System32\drivers\etc\hosts`

Linux:

- Edit your hosts file.

```bash
sudo nano /etc/hosts
```

Now browse to [http://cat-app.k3d.local/](https://cat-app.k3d.local/), you should see the nginx welcome page.

### Start deploying using ArgoCD

- Make sure you forked this repo and cloned your forked repo to your local machine before editing files. Later on we'll
  use your fork to steer your local cluster.
- Push any changes to your fork: This is the `GitOps` way.
- To use ArgoCD we need to create the `argocd` namespace and deploy the ArgoCD application with
  `configmap`, `ingress` and `service`. This is not recursive, only files in the `argocd` folder will be deployed,
  sub folders are ignored.

```bash
kubectl create namespace argocd
```

```bash
kubectl apply -f ./namespace/argocd -n argocd
```

- Extract the ArgoCD admin password, we first request the secret and then decode the password using base64 to plain
  text. The initial password is randomly generated and unique to each ArgoCD installation.
- ArgoCD also provides a CLI tool to interact with the API, but for now we'll use kubectl.
- We should delete this `ConfigMap` manifest and create a new password.

```bash
Kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode
```

**Ignore the `%` when pasting the password.**

- Browse to [argocd.k3d.local](https://argocd.k3d.local)
- username: `admin`
- password: `password from previous command`

Normally we would delete this initial secret after using it and set a new admin password, Ffr now we'll keep it
as is.

- This repository includes an [argocd.Repository](/namespace/argocd/repository/argocd.Repository.yaml) file.
- Update the repo url in this file to your forked repository.
- Apply the Repository using Kubectl.

```bash
kubectl apply -f ./namespace/argocd/repository/argocd.Repository.yaml -n argocd
```

- Your forked [repository](https://argocd.k3d.local/settings/repos) is now visible in the ArgoCD UI.

- Update the Repository URL in the [cat-app.Application](namespace/argocd/application/cat-app.Application.yaml) file.

- Push this change to your fork.

- Now, Apply the application to the ArgoCD namespace.

```bash
kubectl apply -f ./namespace/argocd/application/cat-app.application.yaml -n argocd
```

- Browse to [https://argocd.k3d.local/applications/argocd/cat-app](https://argocd.k3d.local/applications/argocd/cat-app)
- Press the `sync` button to sync the application with your forked repository.
- Your cat app is now deployed using ArgoCD.

### ArgoCD can Git Ops itself

We just deployed the cat app using ArgoCD, but we still needed Kubectl to apply the application. ArgoCD can also manage
itself using GitOps, we can deploy the `cat-app` by adding a new file in the `namespace/argocd/application` folder.

- First edit [argocd.application.yaml](/namespace/argocd/application/argocd.Application.yaml) and change `repoURL` to
  your fork.

- Commit and push the changes to your fork

- Apply the application to ArgoCD

```bash
kubectl apply -f ./namespace/argocd/application/argocd.Application.yaml -n argocd
```

Since we added the application to the repository and sync is enabled in the ArgoCD Application manifest file, it will
automatically maintain the ArgoCD namespace based on the repository state.

- Try deleting the cat-app in the ArgoCD gui and see what happens

Argo cd notices that the cat-app is missing and will automatically recreate/heal.

- Edit [cat-app.Deployment.yaml](namespace/cat-app/cat-app.Deployment.yaml) and change the `replicas` to 3

- Commit and push the changes to your fork

- Go to
  the [cat-app network resources view](https://argocd.k3d.local/applications/argocd/cat-app?view=network&resource=)

- Press the refresh button to check for git updates

- The cat-app `deployment` is now updating to 3 replicas

### What do you want to host?

- Try playing around with your cluster, break it, fix it, add new applications

- Open a shell to a container

- Create a volume claim for persistent storage

- Check out cool helm charts you can install within minutes.
  [awesome-helm](https://github.com/cdwv/awesome-helm)

If you have any questions or suggestions please let me know.

### Delete the cluster

- To keep your system clean, you can delete the cluster by running:

```bash
sudo k3d cluster delete workshop 
```

- You can also delete the kubeconfig file by running:

```bash
rm ~/.kube/config
```

- Optionally restore the original kubeconfig file you had before by running:

```bash
mv ~/.kube/config<UUID> ~/.kube/config
```

- Restore your `hosts` file to its original state.

```bash
sudo nano /etc/hosts
```
