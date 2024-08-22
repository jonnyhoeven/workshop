## Introduction

This workshop is designed to provide basic understanding of Kubernetes and `ArgoCD`.

During the workshop, we'll be deploying simple applications to your Kubernetes cluster using `kubectl`. Later we'll
deploy the same application using `ArgoCD` and your new `git` repository. Meanwhile, we'll be checking out multiple
tools to control and manage Kubernetes clusters.

### After this workshop:

- You'll have a development Kubernetes cluster you can tinker with from your own `git repository`.
  This means you'll be able to _`deploy`_, _`update`_ and _`delete`_ applications remotely and `declaratively` from your
  own `git repository` to your development cluster.
- You'll be able to deploy applications using `kubectl`, use `manifest files` and `ArgoCD` or `DevOps` to
  deploy your `manifests`.
- You'll understand the difference between `declarative` vs `imperative` statements and the vital importance of proper
  `health checks` in conjunction with `livenessProbe`, `readinessProbe` and `startupProbe`.
- Yes, Kubernetes has some deep dark declarative `logic`, it will try to maintain the desired `state`
  and might do some unexpected things if you're not careful.
- You'll understand the difference between `Pods`, `Services`, `Ingress`, `Namespaces`, `ConfigMaps` and `Secrets`.
- You'll know how to use tools like `Helm` and `Lens` to manage your cluster.

## Presentation

<iframe
src="https://docs.google.com/presentation/d/e/2PACX-1vTwUNGkjI-YYRBIXGol9IpAwuzhIPCXTP01DUP8k-cV1_0Z8Kilxw6VyfaXS70pRMfuTJeTrYkpZS0C/embed?start=false&loop=false&delayms=15000"
frameborder="0" width="100%"
height="414pt"
allowfullscreen="true"
mozallowfullscreen="true"
webkitallowfullscreen="true"></iframe>

### Kubernetes concepts

- Kubernetes is a container orchestration platform that automates `deployment`, `scaling` and `management` of
  containerized applications.
- It's `declarative`, meaning you define the desired `state` and Kubernetes automatically changes the `current
  state` to the `desired state` the best way it can.
- It's designed to be `extensible` and `scalable`.
- Built to handle a wide range of workloads, from `stateless`
  to `stateful` applications.

### Extendable - Custom Resource Definitions (CRD's)

- Kubernetes utilizes Custom Resource Definitions (CRDs) for extendability.
- CRDs allow extendability for the Kubernetes API by creating new resources classes.

This allows developers to create their own resources or controllers to manage with their own operator running inside
your cluster.

For example, the ArgoCD operator creates a new resource called an Application. This resource can be used to define
applications and their configuration declaratively. It's then up to the ArgoCD operator to manage these
applications and ensure they're in their desired state.

> [!TIP]
> It's important to understand that CRD's are methods to extend the Kubernetes API and create new resources. This
> concept is used in many operators, controllers, helm charts, ingress classes and storage classes to create new
> resources and manage them individually.

### Declarative vs Imperative

Declarative means: you define the desired state of the system and Kubernetes automatically changes the current state to
the desired state the best way it can.
A powerful tool to manage the system. Instead of writing a series of commands to put the system in a certain state, you
declare the desired state and Kubernetes will do the rest.

> [!WARNING]
> This has a mayor impact, small changes in the desired state can have a big impact on the current state. It's important
> to understand the difference between the desired states of the system to prevent unwanted changes by Kubernetes.

### Health Checks

Health checks are integral to determine if a container is healthy or not. Kubernetes supports three types of health
checks: `livenessProbe`, `readinessProbe` and `startupProbe`.

Kubernetes utilizes `Health Probes` to determine container liveness. If a container isn't healthy,
Kubernetes will restart the whole `Pod`. After a number of specified back-off periods while restarting the pod.
Kubernetes will not send anymore traffic to that `pod`.

Developers can define the health-result of their application and Kubernetes will take care of the rest.

> [!TIP]
> Kubernetes won't just kill the old containers and start new ones. It will do this in a controlled manner. It
> first starts up the new container and waits for it to be healthy. Then it will stop the old container to prevent
> downtime. It's therefore important to have concise health checks in place, developers should be encouraged to
> manipulate health checks if they deem a service misbehaving or unavailable.

### Containers reside in Pods

A Pod is the smallest deployable unit in Kubernetes. A Pod represents a single instance of a service within your
cluster. Pods contain one or more containers. When a Pod runs multiple containers, the
containers are managed as a single entity and share the same resources.

More importantly, containers in a pod share the same lifecycle, they're started together, stopped together and are
considered atomic.

A Pod can be considered a separate subnetwork, containers within a pod are effectively behind NAT (Network Address
Translation). Inside this `Pod` containers can rely on local DNS services to find hostnames in their own or different
namespaces.

Since networking and state is separate and atomic this means you can run multiple replica's of the same Pod and
increase availability. Without the need to worry about state or networking from the perspective of a container.

### Pods expose their ports to Services

Services allow you to expose applications running on a set of Pod replica's as a network service.
Services are mostly abstraction/glue for Pods and Ingress. They provide a stable endpoint for Pods and Ingress to
interconnect.

### Ingress connects Services to the outside world

Ingress is a collection of rules that allows inbound connections to reach the cluster Services.
It's used to allow external ingress to different services via ports, load balancers, Virtual Hostnames or SSL
termination using [Cert Manager](https://cert-manager.io/) and the [Let's Encrypt API](https://letsencrypt.org/docs/).

### Namespaces

Another important concept in Kubernetes is Namespaces. Namespaces are used to divide cluster resources between
different tenants, teams or applications.

The `default` namespace is the place for objects with no other namespace. It's important to note that
namespaces are not your security boundary, just methods to divide resources and provide `naming` isolation between
identical deployments.
It's important to note that resources in different namespaces can communicate with each other and .

A powerful tool to divide resources. Ideally the only difference between staging and production environments would
be your Configmap and Secrets.

### ConfigMaps and Secrets

ConfigMaps provide a great pattern to configure your containers from the namespace they started in, you can use them
to mount files, set environment values. More importantly, you can reuse the same ConfigMap for different environments
and refer to this config map's keys to provision your deployment and much more.

When you need to store sensitive information, such as passwords, OAuth tokens and SSH keys, you can use Secrets.
If you need to store non-sensitive configuration data, you can use ConfigMaps.

ConfigMaps and Secrets can be mounted as files or environment variables in a Pod. Containers in a pod might need to be
drained/restarted to reload the latest environment configuration changes.

## The Workshop

We're going to deploy a simple application to your cluster using `kubectl`,
then we'll deploy the same application using `ArgoCD`,
along the way we'll be checking out multiple tools to configure your Kubernetes cluster.

- We'll end up with your own cluster you can tinker with from your personal git repository.
- It follows `DevOps` patterns where we use Git repositories as the source of _truth_ that defines the desired state of
  our deployments. ArgoCD is very declarative and all configuration can be stored your Git repository.
- This won't be some deep dive into Kubernetes, it will teach you some basics interacting with `Kubernetes` and how to 
  deploy applications using `kubectl` and `ArgoCD`.

Let's get started:

### Clone the workshop repository

Browse to this [Workshop](https://github.com/jonnyhoeven/workshop/fork) to create your fork,
later on we'll be using this fork to steer your local cluster.

Clone your forked repo to your local machine.

::: code-group

```markdown [VSCode]
Open the command palette with the key 
combination of `Ctrl` + `Shift` + `P`.
At the command palette prompt, enter `gitclone`, 
select the Git: `Clone` command, 
then select `Clone from GitHub` and press Enter.
When prompted for the Repository URL,
select `clone from GitHub`, then press Enter.
```

```bash [Bash]
git clone https://github.com/<USERNAME>/workshop
cd workshop
```

:::

### Software requirements

Please note that this workshop is designed to run on Linux or Windows machines with `WSL2` installed.
It's suggested to use `apt` based distro's like `Debian`, `Ubuntu` or `Mint`.

#### WSL (Windows Subsystem for Linux)

::: info Install `WSL2` on Windows to Run Linux commands

```powershell
wsl --install
```

[Reference](https://learn.microsoft.com/en-us/windows/wsl/install)
:::

#### Docker

Docker is a platform for developing, shipping and running applications. It allows you to package your application and
dependencies into a container that can run on any machine.

::: info Windows install
Download & install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
:::

::: info Linux install

```bash
sudo apt install docker.io
sudo groupadd docker
sudo usermod -aG docker $USER
```

[Reference](https://packages.debian.org/sid/docker.io)
:::

#### Kubectl

Kubectl is the command line tool for controlling Kubernetes clusters. It's used to deploy, inspect and
manage your cluster.

::: info Install kubectl

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

[Reference](https://kubernetes.io/docs/tasks/tools/install-Kubectl-linux/)
:::

#### K3D (K3S in Docker)

K3D is a lightweight wrapper to run K3S (Rancher Lab's minimal Kubernetes distribution) in docker. It's a single binary
that deploys a K3S server in a docker container. K3D makes it very easy to create single and multi-node K3S clusters in
docker, it's possible to run multiple clusters at the same time on your development machine.

::: info Install k3d

```bash
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

[Reference](https://k3d.io/v5.6.0/#quick-start)
:::

#### Lens

Lens is a Kubernetes IDE that allows you to manage, monitor and manipulate your clusters.
It's a great tool to get a visual representation of your cluster and to manage your resources.
Download and install [Lens](https://k8slens.dev/download)

### Starting your Kubernetes cluster

We'll be creating 2 agents and 1 master for our cluster, for this example we'll keep it simple.

We'll name this cluster `workshop`.

:::info Create a new cluster

```bash
sudo k3d cluster create workshop --agents 2 --servers 1
```

Once completed, you can check the status of your cluster by running:

```bash
sudo k3d cluster list
```

[Reference](https://k3d.io/v5.3.0/usage/commands/k3d_cluster_create/)
:::

### Access the cluster using Kubectl

Kubeconfig is a file that holds information about clusters, including the hostname, certificate authority and
authentication information. It's located at `~/.kube/config` and can be used by other
applications to connect to the cluster. Keep this file secure, it's the **key** to your cluster.

You can get the kubeconfig file from K3D by running:

::: info Retrieve and save kubeconfig file

```bash
mv ~/.kube/config ~/.kube/config-$(uuidgen) #Backup any existing kubeconfig
sudo k3d kubeconfig get workshop > ~/.kube/config
```

Check cluster info

```bash
kubectl cluster-info
```

Check the cluster Nodes

```bash
kubectl get nodes
```

:::

### Access the cluster using Lens

Setup Lens to use the new cluster by adding your new [kubeconfig.yaml](kubeconfig.yaml) file.
::: info View contents of kubeconfig file and add to Lens

```bash
cat ~/.kube/config
```

Open Lens, Click on `Catalog` (Top left, second from top) → `Clusters` → `Add Cluster (+) icon` →
`Add Cluster from Kubeconfig` → Paste the contents of your kubeconfig file → `Add Clusters`
:::

Now you can access the `k3d-workshop` cluster using Lens.

Browse around, check the `Nodes`, `Namespaces`, `Custom Resource Definitions` and `Pods`.

### Some notes about Namespaces

Namespaces divide cluster resources and quota's.
They're intended for use in environments with many users spread across multiple teams or
projects. Namespaces are not a security feature, to isolate different users or namespaces from each other we need tools
like [Loft](https://loft.sh/) that leverage RBAC (Role Based Account Control) to securely isolate your namespaces
across teams.

By default, Kubernetes starts with four initial namespaces:

::: info List namespaces

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
  :::

### Create your own namespace

Let's create a new namespace and deploy an application in the `workshop` namespace.
::: info Create a new namespace

```bash
kubectl create namespace workshop
```

:::

### Deploy your application manually

We'll deploy nginx web server to our cluster.

The `-n` or `--namespace` parameter is used to specify the namespace to deploy the application to.
If you don't provide a namespace, the application will deploy to the `default` namespace.
Resulting in naming conflicts and hard to find, hard to manage resources.

::: info Deploy nginx to the workshop namespace

```bash
kubectl create deployment nginx --image=nginx -n workshop
```

Check the `deployment` kubectl

```bash
kubectl get deployment -n workshop
```

The result should look like this:

```text
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           **s
```

Check the `pod` status with kubectl

```bash
kubectl get pod -n workshop
```

The result should look like this:

```text
# NAME                     READY   STATUS    RESTARTS   AGE
# nginx-**********-*****   1/1     Running   0          **s
```

Find this `deployment` in `lens` and check the `pod` status.
As you can see, the `deployment` and `pod` replica is up and running.

Try deleting the `pod` and see what happens.

```bash
kubectl delete pod $(kubectl get pods -n workshop -o jsonpath="{.items[*].metadata.name}") -n workshop
```

The `pod` gets deleted and a new one is created to replace it. This is because the `deployment` is set to have 1
replica, so if the `pod` is deleted, a new one is created to replace it.

List the `pods` again

```bash
kubectl get pod -n workshop
```

The `pod` is running again, but now it's got a _different_ name.
:::

It's important to note that the `deployment` manifest manages the `pod` and `pods` can be replicated.

::: tip
To avoid downtime it's recommended to use `Evict` or `Taint` instead of deleting definitions.
This will result in Kubernetes creating a new `pod` and wait for it to be ready before deleting the original pod.
:::

::: info Delete the `deployment`

```bash
kubectl delete deployment nginx -n workshop
```

Now check the `pod` status again

```bash
kubectl get pod -n workshop
```

Without the `deployment` manifest that defines `pod` replica count, the `pod` is removed.

Clean up the namespace.

```bash
kubectl delete namespace workshop
```

:::

### Deploy using manifest files from code

Normally you'll want to deploy manifest files, so you can keep track of your `deployments` and
easily replicate them across different clusters or namespaces.

::: warning Before starting
Make sure you're in the correct working directory.
:::

::: info Create the `cat-app` namespace using Kubectl:

```bash
kubectl create namespace cat-app
```

Deploy the cat-app `deployment` to the `cat-app` namespace using the manifest files.

```bash
kubectl apply -f ./namespace/cat-app/cat-app.Deployment.yaml -n cat-app
kubectl apply -f ./namespace/cat-app/cat-app.Service.yaml -n cat-app
kubectl apply -f ./namespace/cat-app/cat-app.Ingress.yaml -n cat-app
```

You can also deploy complete folders using Kubectl, this will deploy all the files in one folder, try it.

```bash
kubectl apply -f ./namespace/cat-app/ -n cat-app
```

- Get familiar with the files in the `cat-app` folder and try to understand what each file does.
- Notice the URL in the cat-app.Ingress.yaml file, this is the `URL`, `Virtual Host` you'll use to access the cat-app.
- Notice the `Service` file, this is the service that'll be used to expose the cat-app to the internet. It uses the
  type `ClusterIP` for now.

Check the `deployment`

```bash
kubectl get deployment -n cat-app
````

Check the `pod`

```bash
kubectl get pod -n cat-app
````

Check the `service`

```bash
kubectl get service -n cat-app
```

Check the `ingress`

```bash
kubectl get ingress -n cat-app
```

Ingress is a collection of classes that allow inbound connections to reach the cluster services. It can be configured to
give services externally reachable URLs, load balance traffic, terminate SSL and even integrate with oauth middleware.

```text
NAME      CLASS    HOSTS               ADDRESS                            PORTS   AGE
cat-app   <none>   cat-app.k3d.local   172.xx.0.2,172.xx.0.3,172.xx.0.4   80      **s
```

- Notice the `cat-app.k3d.local` URL, this is the URL you'll use to access the cat-app.
- Notice the `ADDRESS` field, this is the IP address of the service, it's a `ClusterIP` type service and is available on
  all Kubernetes Nodes in the cluster. If a node does not have the cat-app `pod`, it will forward the request to other
  nodes with deployments that host services with the `cat-app` deployment selection tag.
- More commonly you'll see `LoadBalancer` type services, which use cloud provider or edge network load balancer

### Accessing the cat-app

First we need to update our hosts file, normally you'll use a DNS server to resolve the URL to the IP address and sign
TLS certificates automatically with `let's encrypt` or a `Common Authority` certificate.

::: info Get Ingress

```bash
kubectl get ingress -n cat-app
```

Notice the `ADDRESS` field, copy the IP addresses and paste them after the `hosthelp.sh` command.

```bash
chmod +x hosthelp.sh
./hosthelp.sh <ADDRESS>
```

:::

Add the output from the `hosthelp.sh` command to your hosts file.

::: info Windows users
Start notepad as administrator, open the file `C:\Windows\System32\drivers\etc\hosts`.
:::

::: info Linux users (Not for WSL2 users)

```bash
sudo nano /etc/hosts
```

:::

Open [http://cat-app.k3d.local/](https://cat-app.k3d.local/), you should see the nginx welcome page.

### Start deploying using ArgoCD

::: danger Before continuing:
Make sure you forked this repo and cloned your forked repo to your local machine before editing files.
Later on we'll use your fork to steer your local cluster.
:::

::: info Create the ArgoCD namespace using Kubectl:

```bash
kubectl create namespace argocd
```

Apply the ArgoCD manifests to the `argocd` namespace.

```bash
kubectl apply -f ./namespace/argocd -n argocd
```

Extract the ArgoCD admin password, first we request the secret and then decode the password using base64 to plain
text. The initial password is randomly generated and unique to each ArgoCD installation.

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode
```

::: info Ignore the `%` when pasting the password.
:::
Login to [argocd.k3d.local](https://argocd.k3d.local)

| Username | admin                          |
|----------|--------------------------------|
| Password | password from previous command |

::: info Setup repository
Open the [argocd.Repository](/namespace/argocd/repository/argocd.Repository.yaml) file and change the url
to your forked repository.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: workshop
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/<user>/workshop.git // [!code focus]
```

Apply the changed Repository using kubectl.

```bash
kubectl apply -f ./namespace/argocd/repository/argocd.Repository.yaml -n argocd
```

:::

Your forked [repository](https://argocd.k3d.local/settings/repos) is now visible in the ArgoCD web ui.

::: info Setup application
Open the [cat-app.Application](namespace/argocd/application/cat-app.Application.yaml) file and change the `repoURL` to
your forked repository.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cat-app
  namespace: argocd
  labels:
    name: cat-app
spec:
  project: default
  source:
    repoURL: https://github.com/<user>/workshop.git // [!code focus]
    targetRevision: HEAD
    path: namespace/cat-app
    directory:
      recurse: true
  destination:
    server: https://kubernetes.default.svc
    namespace: cat-app
  info:
    - name: 'Cat App'
      value: 'Cats Do Moo!'
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
  revisionHistoryLimit: 1
```

Push this change to your forked repository.

```bash
git add .
git commit -m "New fork"
git push
```

Apply the changed Application to the ArgoCD namespace.

```bash
kubectl apply -f ./namespace/argocd/application/cat-app.Application.yaml -n argocd
```

:::

Lookup the [cat-app in ArgoCD](https://argocd.k3d.local/applications/argocd/cat-app)

Press the `sync` button to sync the application with your forked repository.
Your cat app is now deployed using ArgoCD.

### ArgoCD can DevOps itself

We just deployed the cat app using ArgoCD, but we still needed Kubectl to apply the application. ArgoCD can also manage
itself using DevOps.

::: info Setup ArgoCD using DevOps
Open the [argocd.Application](/namespace/argocd/application/argocd.Application.yaml) and change `repoURL` to your forked
repository.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd
  namespace: argocd
  labels:
    name: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<user>/workshop.git // [!code focus]
    targetRevision: HEAD
    path: namespace/argocd
    directory:
      recurse: true
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  info:
    - name: 'This is ArgoCD'
      value: 'Managing ArgoCD with ArgoCD!'
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
  revisionHistoryLimit: 1
```

Commit and push the changes to your fork

```bash
git add .
git commit -m "Change"
git push
```

Apply the application to ArgoCD

```bash
kubectl apply -f ./namespace/argocd/application/argocd.Application.yaml -n argocd
```

:::

Since we added the application to the repository and sync is enabled in the ArgoCD Application manifest file, it will
automatically maintain the ArgoCD namespace based on the repository state.

::: info Change replicas using DevOps

Try deleting the cat-app in the ArgoCD web ui and see what happens

Argo cd notices that the cat-app is missing and will automatically recreate/heal.

Edit [cat-app.Deployment.yaml](namespace/cat-app/cat-app.Deployment.yaml) and change the `replicas` to 3

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: cat-app
  name: cat-app
spec:
  replicas: 1 // [!code focus]
  selector:
    matchLabels:
      app: cat-app
  template:
    metadata:
      labels:
        app: cat-app
    spec:
      containers:
        - name: cat-app
          image: nginx
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
              name: http
              protocol: TCP
```

Commit and push the changes to your fork

```bash
git add .
git commit -m "Changed repoURL"
git push
```

:::

Open [cat-app network resources view](https://argocd.k3d.local/applications/argocd/cat-app?view=network&resource=)
Press the refresh button to check for git updates, the cat-app `deployment` is now updating to 3 replicas

### Some ideas to try

Since we have a Kubernetes cluster that allows you to define the state from your own git repository, why not be
creative.

- Open a shell to a container
  Click on a pod in lens, see top right.
- Read container logs
- Create a persistent volume claim.

- Check out cool helm charts you can install within minutes.
  [awesome-helm](https://github.com/cdwv/awesome-helm)

If you have any questions or suggestions please let me know.

### Cleanup

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