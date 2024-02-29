# Workshop

## Requirements

### Kubectl

Kubectl is a command line tool for controlling Kubernetes clusters. It is used to deploy applications, inspect and
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

Lens is a Kubernetes IDE that allows you to manage and monitor your clusters, and deploy applications.

Recently some features were removed from Open Lens. Plugins replacing this functionality aren't yet working properly.
So for now, it's recommended to use the Mirantis version of Lens.

- [Lens](https://k8slens.dev/desktop.html) (From Mirantis)
- [Open Lens](https://flathub.org/apps/dev.k8slens.OpenLens) (Open Source version)

## Start a new Kubernetes cluster

[Reference](https://k3d.io/v5.3.0/usage/commands/k3d_cluster_create/)

We'll be creating one server and two agents for our cluster.
Normally for high availability you'll want to have at least 3 servers, and 6 agents
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

Kubeconfig is a file that holds information about the cluster, including the server, certificate authority, and
authentication information.

The default kubeconfig file is located at `~/.kube/config`, and you can check the current context by running:

```bash
cat ~/.kube/config
```

K3D automatically sets up the kubeconfig file for you, so you can access the development cluster using kubectl.
Normally you'll need to obtain the kubeconfig file from the cluster and set it up manually.

You can get the config from k3d by running:

```bash
k3d kubeconfig get workshop > kubeconfig.yaml
```

```bash
kubectl cluster-info
```

## Access the cluster using Lens

Setup Lens to use the new cluster by adding a new cluster and selecting the kubeconfig file.

Click on `Catalog` (Top left, second from top) → `Clusters` → `Add Cluster (+) icon` → `Add Cluster from Kubeconfig`
→ Paste the contents of your kubeconfig file → `Add Clusters`

Now you can access the `k3d-workshop` cluster using Lens.

Browse around, check the nodes, namespaces, and pods.

## Some more about Namespaces

Namespaces are a way to divide cluster resources between multiple users (via resource quota) and multiple projects (via
separation of resources). They are intended for use in environments with many users spread across multiple teams, or
projects. Namespaces are not a security feature, to isolate different users or applications from each other there are
addons like
[Loft](https://loft.sh/) that leverages RBAC (Role based account control) to securely isolate namespaces across teams.

By default, Kubernetes starts with four initial namespaces:

- default, The default namespace for objects with no other namespace. Try not to use this namespace for your own
  objects.
- kube-system, The namespace for objects created by the Kubernetes system.
- kube-public, This namespace is created automatically and is readable by all users (including those not authenticated).
- kube-node-lease, This namespace is used for the lease objects associated with each node which improves the performance
  of the node heartbeats as the cluster scales.

## Create your own namespace

Let's create a new namespace to work with and deploy an application to it.
Let's call it `workshop`.

```bash
kubectl create namespace workshop
```

### Deploy an application manually

We'll deploy a simple nginx web server to our cluster.

`-n` or `--namespace` is used to specify the namespace to deploy the application to.
If you don't provide a namespace, the application will be deployed to the default namespace.

```bash
kubectl create deployment nginx --image=nginx -n workshop
```

- Check the deployment and pod status with kubectl

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

- Find the deployment in lens and check the pod status.
  As you can see, the deployment is running and the pod is up and running.

- Try deleting the pod and see what happens.

```bash
kubectl delete pod <pod-name> -n workshop
```

The pod gets deleted, and a new one is created to replace it. This is because the deployment is set to have 1 replica,
so if the pod is deleted, a new one is created to replace it.

- List the pods again

```bash
kubectl get pod -n workshop
```

The pod is running again, but it has a different unique name now.

It's important to note that the deployment is the object that manages the pod, and the pod is the object that runs the
containers.

It's recommended to use `Evict` or `Taint` instead of deleting definitions, to avoid downtime.
This will result in kubernetes creating a new pod and waiting for it to be ready before deleting the old tainted pod.

- Delete the deployment and check the pod status again.

```bash
kubectl delete deployment nginx -n workshop
```

```text
deployment.apps "nginx" deleted
```

```bash
kubectl get pod -n workshop
```

```text
No resources found in workshop namespace.
```

As you can see without the declaration of the deployment, the pod is also finally deleted.

- Clean up the namespace

```bash
kubectl delete namespace workshop
```

### Deploy using a manifest files from code

Normally you'll want to deploy your applications using a manifest file, so you can keep track of your deployments and
easily replicate them across different clusters. And of course, you can use version control to keep track of changes.

- First Make sure your changed path to same folder as this `README.md` file.

- Create the `cat-app` namespace again using kubectl:

```bash
kubectl create namespace cat-app
```

- Deploy the cat-app deployment to the `cat-app` namespace using the manifest files.

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
- For now check the deployment and pod status with kubectl or lens

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
  all kubernetes Nodes ip in the cluster. If a node does not have the cat-app pod, it will forward the request to a node
  that does host the cat-app pod.
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

- Make sure to fork this repo before editing files, and clone your forked repo to your local machine.

- For us to deploy using ArgoCD we need to create the `argocd` namespace and deploy the argocd application with
  configmap, ingress and service. This command is not recursive, so only file in the `argocd` folder will be deployed,
  sub folders are ignored.

```bash
kubectl create namespace argocd
kubectl apply -f ./namespace/argocd -n argocd
```

- Edit your hosts file and add the argocd hostname to it.

```text
172.20.0.2 argocd.k3d.local
172.20.0.3 argocd.k3d.local
172.20.0.4 argocd.k3d.local
```

- Extract the argocd admin password, we first request the secret and then decode the password using base64 to plain
  text.

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode
```

*** There might be a `%` at the end of the password, ignore it when pasting the password. ***

- Browse to [argocd.k3d.local](https://argocd.k3d.local), username: `admin`, password: `password from previous command`.
  Normally we would delete this initial secret after using it, and set a new admin password but for now we'll keep it as
  is.

- This repository already has a [repository](./namespace/argocd/repository/argocd.Repository.yaml) file, update the repo
  url to your forked repo and apply the repository.

```bash
kubectl apply -f ./namespace/argocd/repository/argocd.Repository.yaml -n argocd
```

- The [repository](https://argocd.k3d.local/settings/repos) is now visible in the argocd UI.

- The [application](./namespace/argocd/application/cat-app.Application.yaml) file is also already in the repository, update
  the repo url to your forked repo and apply the application.

```bash
kubectl apply -f ./namespace/argocd/application/cat-app.Application.yaml -n argocd
```


- Commit and push the change to your branch.

- Apply the application file to argocd.

```bash
kubectl apply -f ./namespace/argocd/application/cat-app.application.yaml -n argocd
```

```bash

### Delete the cluster

- To keep your system clean, you can delete the cluster by running:

```bash
k3d  cluster delete mycluster 
```

- Remember to delete the kubeconfig file if you don't need it anymore.

```bash
rm ~/.kube/config
```