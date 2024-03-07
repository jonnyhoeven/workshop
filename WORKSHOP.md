## The Workshop

We're going to deploy a simple application to a Kubernetes cluster using kubectl,
and then we'll deploy the same application using ArgoCD along the way we'll be checking out multiple tools to configure
a kubernetes cluster.

We'll end up with a cluster you can tinker with from your own git repository.

Let's get started, first open up a terminal to run linux/bash commands.

## Requirements

We'll need some tools to get our cluster running.

### Kubectl

Kubectl is a command line tool for controlling Kubernetes clusters. It is used to deploy, inspect and
manage cluster resources, and view logs.

[Reference](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

```bash
sudo apt-get update
```

```bash
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl
```

```bash
# If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command.
sudo mkdir -p -m 755 /etc/apt/keyrings
```

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

```bash
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

```bash
sudo apt-get update
```

```bash
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

Install Docker:

```bash
sudo apt install docker.io
```

### Lens

Lens is a Kubernetes IDE that allows you to manage and monitor your clusters, and deploy.

Recently some features were removed from Open Lens. Plugins replacing this functionality aren't yet working properly.
So for now, it's recommended to use the Mirantis Free version of Lens.

- [Lens](https://k8slens.dev/desktop.html) (From Mirantis)
- [Open Lens](https://flathub.org/apps/dev.k8slens.OpenLens) (Open Source version)

## Start a new Kubernetes cluster

[Reference](https://k3d.io/v5.3.0/usage/commands/k3d_cluster_create/)

We'll be creating 1 server and 2 agents/workers for our cluster.
Normally for high availability you'll want to have at least 2 control planes, each with 2 agents.
but for this example we'll keep it simple.

We'll name this cluster `workshop`.

```bash
sudo k3d cluster create workshop --agents 2 --servers 1
```

Once completed, you can check the status of your cluster by running:

```bash
sudo k3d cluster list
```

## Access the cluster using kubectl

Kubeconfig is a file that holds information about cluster, including the hostname, certificate authority, and
authentication information. It's installed by kubectl at `~/.kube/config` by default, and can be used by other
applications to connect to the cluster. Keep this file secure, it's the **key** to your cluster.

In normal situations you'll need to obtain the kubeconfig file from one of the Kubernetes cluster control nodes,
if running locally K3D can provide the kubeconfig file.

You can get the config from k3d by running:

```bash
sudo k3d kubeconfig get workshop > kubeconfig.yaml
```

- Update your `~/.kube/config` file with the newly generated `kubeconfig.yaml` file.

e.g. on linux:

```bash
mv ~/.kube/config ~/.kube/config.bak-wrkshp
```

```bash
mv ./kubeconfig.yaml ~/.kube/config
```

- Check the cluster info using kubectl cluster-info

```bash
kubectl cluster-info
```

- Check the nodes in the cluster using kubectl

```bash
kubectl get nodes
```

## Access the cluster using Lens

Setup Lens to use the new cluster by adding a new cluster from kubeconfig.

Click on `Catalog` (Top left, second from top) → `Clusters` → `Add Cluster (+) icon` → `Add Cluster from Kubeconfig`
→ Paste the contents of your kubeconfig file → `Add Clusters` or import the kubeconfig file using
the `Add Cluster from Kubeconfig` option.

Now you can access the `k3d-workshop` cluster using Lens.

Browse around, check the `nodes`, `namespaces`, and `pods` sections.

## Some notes about Namespaces

Namespaces are methods to divide cluster resources between multiple users (via resource quota) and multiple projects (
via
separation of resources). They are intended for use in environments with many users spread across multiple teams, or
projects. Namespaces are not a security feature, to isolate different users or namespaces from each other there are
addons like
[Loft](https://loft.sh/) that leverages RBAC (Role based account control) to securely isolate namespaces across teams.

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
kubectl delete pod $(kubectl get pods -n workshop -o jsonpath="{.items[*].metadata.name}") -n workshop
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
This will result in kubernetes creating a new `pod` and wait for it to be ready before deleting the old evicted `pod`.

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
````

```bash
kubectl get pod -n cat-app
````

- Check the service and ingress status with kubectl or lens

```bash
kubectl get service -n cat-app
```

```bash
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

Or use notepad in windows, open it as administrator, open the file `C:\Windows\System32\drivers\etc\hosts`

- Use the output from:

```bash
kubectl get ingress -n cat-app
```

```text
# Workshop K3D cluster
172.xx.0.2 cat-app.k3d.local
172.xx.0.3 cat-app.k3d.local
172.xx.0.4 cat-app.k3d.local
172.xx.0.2 argocd.k3d.local
172.xx.0.3 argocd.k3d.local
172.xx.0.4 argocd.k3d.local
```

- To add the correct IP addresses your hosts file.


- Edit your hosts file, add the cat-app hostname and save it

```bash
sudo nano /etc/hosts
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
```

```bash
kubectl apply -f ./namespace/argocd -n argocd
```

- Extract the ArgoCD admin password, we first request the secret and then decode the password using base64 to plain
  text. The initial password is randomly generated and unique to each ArgoCD installation.
- ArgoCD also provides a CLI tool to interact with the API, but for now we'll use kubectl.

```bash
echo -n $(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}') | base64 --decode
```

*** Ignore the `%` when pasting the password. ***

- Browse to [argocd.k3d.local](https://argocd.k3d.local), username: `admin`, password: `password from previous command`.
  Normally we would delete this initial secret after using it, and set a new admin password. but for now we'll keep it
  as is.

- This repository includes a [repository](/namespace/argocd/repository/argocd.Repository.yaml) file,

- Update the repo url to your forked repository.

- Apply the Repository using kubectl.

```bash
kubectl apply -f ./namespace/argocd/repository/argocd.Repository.yaml -n argocd
```

- The [repository](https://argocd.k3d.local/settings/repos) is now visible in the ArgoCD UI.

- The [application](namespace/argocd/application/cat-app.Application.yaml) file is also already in the repository,
  update the repo url to your forked repo and apply the application.

- Commit and push the changes to your forked repository.

- Apply the application to the ArgoCD namespace.

```bash
kubectl apply -f ./namespace/argocd/application/cat-app.application.yaml -n argocd
```

- Browse to [https://argocd.k3d.local/applications/argocd/cat-app](https://argocd.k3d.local/applications/argocd/cat-app)
- Press the `sync` button to sync the application with the repository.
- Your cat app is now deployed using ArgoCD.

### ArgoCD can Git Ops itself

We just deployed the cat app using ArgoCD, but we still needed kubectl to apply the application. ArgoCD can also manage
itself using GitOps, so we can deploy the cat-app by adding a new file in the `namespace/argocd/application` folder.

- First edit [argocd.application.yaml](/namespace/argocd/application/argocd.Application.yaml) and change `repoURL` to
  your fork, then apply the application manifest.

- Commit and push the changes to your fork.

- Apply the application to ArgoCD.

```bash
kubectl apply -f ./namespace/argocd/application/argocd.Application.yaml -n argocd
```

Since we added the application to the repository and sync is enabled in the ArgoCD application manifest files, it will
automatically maintain the ArgoCD namespace based on the repository state.

- Try deleting the cat-app in the ArgoCD gui, and see what happens.

Argo cd Notice that the cat-app is missing and will automatically recreate it.

- Edit [cat-app.Deployment.yaml](namespace/cat-app/cat-app.Deployment.yaml) and change the `replicas` to 3.

- Commit and push the changes to your fork

- Go to
  the [cat-app network resources view](https://argocd.k3d.local/applications/argocd/cat-app?view=network&resource=)

- Press the refresh button.

- The cat-app `deployment` is now updated to 3 replicas.

### What do you want to host?

- Try playing around with your cluster, break it, fix it, add new applications.

- Open a shell to a container

- Create a volume claim for persistent storage

- Check out cool helm charts you can install within minutes. [awesome-helm](https://github.com/cdwv/awesome-helm)

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

- Restore your `hosts` file to its original state.

```bash
sudo nano /etc/hosts
```

- Optionally restore your backup kubeconfig file by running:

```bash
mv ~/.kube/config.bak-wrkshp ~/.kube/config
```

