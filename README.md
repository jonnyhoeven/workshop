# GitOps using ArgoCD

## Introduction

This workshop is designed to provide a basic understanding of Kubernetes and ArgoCD.

During the workshop, we'll be deploying a simple application to a Kubernetes cluster using kubectl, and then we'll
deploy
the same application using ArgoCD.

## Corresponding presentation

The presentation corresponding to this workshop can be found on
[Google Docs](https://docs.google.com/presentation/d/152MpdoXHLjObj5jBvd-LYGkc_tZbI_o-GPqt1mTnseM/edit?usp=sharing).

## Kubernetes concepts

Kubernetes is a container orchestration platform that automates deployment, scaling, and management of containerized
applications.

It's declarative, meaning you define the desired state of the system and Kubernetes automatically changes
the current state to the desired state the best way it can.

It's designed to be extensible and scalable, and it's built to handle a wide range of workloads, from stateless
to stateful applications.

### Extendable - Custom Resource Definitions (CRD's)

Kubernetes utilizes Custom Resource Definitions (CRDs) for extendability.

CRDs allow extendability for the Kubernetes API by creating new resources classes.

This allows developers to create their own resources or controllers to manage these resources.

For example, the ArgoCD operator creates a new resource called an Application. This resource can be used to define
applications and their configuration in a declarative way. It's then up to the ArgoCD operator to manage these
applications and ensure they are in the desired state.

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
checks: livenessProbe, readinessProbe, and startupProbe.

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

More importantly, containers in a pod share the same lifecycle, they are started together, stopped together, and are
considered atomic.

A Pod can be considered a separate subnetwork, containers within a pod are effectively behind NAT (Network Address
Translation). Inside this Pod containers can rely on a local DNS service to resolve hostnames to each internally.

Since networking and state is separate and also atomic this means you can run multiple replica's of the same Pod and
increase availability. Without the need to worry about state or networking from a container perspective.

### Pods expose their ports to Services

Services provide a method to expose an application running on a set of Pod replica's as a network service.
Services are mostly abstraction/glue for Pods and Ingress. They provide a stable endpoint for Pods and Ingress to
connect.

### Ingress connects Services to the outside world

Ingress is a collection of rules that allows inbound connections to reach the cluster Services.
It's used to allow external ingress to different services via ports, load balancers, URL hostname.
Plugins for Common Authority Certificates en Cert Manager using Let's Encrypt are easily installed.

### Namespaces

Another important concept in Kubernetes is Namespaces. Namespaces are used to divide cluster resources between
different tenants, teams or applications.

It's a powerful tool to divide resources and provides isolation between different applications. Commonly used to
divide resources between different environments like development, staging, and production.
Ideally the only difference between staging and production should be a namespace Configmap and Secrets.

The ```default``` namespace is the default namespace for objects with no other namespace. It's important to note that
namespaces are not a security boundary, just methods to divide resources and provide isolation between different
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

