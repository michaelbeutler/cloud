# K8s-Tutorial

This tutorial guides you in the installation of k8s.

All tutorials can be installed on Debian 12.

Evaluation takes place on points to be reached. All necessary components for the grading are denoted by a `MUST`. This is necessary as the evaluation takes place with scripts and automatisms.
The grade is based on the points using the following formular:

Grade = 1 + (Points Reached) * 5 / (Max Points)

Total Points reachable: 20

* All nodes MUST have a local user `eval` with the ssh-key stored in https://gitlab.fhnw.ch/cloud/cloud/platforms_to_build/-/blob/main/access/id_ed25519.pub . This user MUST have passwordless sudo-rights. Adding via Group `sudo` might not work since this group is not able to act passwordless by default.
* Your machine names MUST match the names given (e.g. `k3snode01` or `k8smain01`).

K8s is the jack of all trades currently regarding container orchestation. Many cloud provider offer native K8s-services, multiple enterprise grade products exist to install/handle K8s on prem.

As a consequence, we want to know K8s better, utilize the knowledge we gained from our container installation and install it ourselves.

The setup is divided into three parts:

* Part 1: Installation of Kubernetes via `K3S`.
* Part 2: Installation of Vanilla Kubernetes with one main node and one worker node
* Part 3: Extension of this Vanilla Kubernetes Installation as HA-setup.

The testworkload to verify running clusters is the same as on all clusters and is defined under https://kubernetes.io/de/docs/tutorials/hello-minikube/.
This following workload MUST be deployed successfully to see kubernetes running.

```
kubectl create deployment hello-node --image=registry.k8s.io/echoserver:1.4
```

## Part 1: K3S

K3S is a lightweight kubernetes distribution making installations very easy, even for multi-node deployments.

Create a two debian machines called `k3snode01` and `k3snode02`. Both machines should be something like 2 CPUs, 4GB RAM, 40GB Storage (typical m1.medium instance).

Relevant documentation about the installation can be found under https://docs.k3s.io/installation/requirements and https://docs.k3s.io/datastore/ha-embedded .

### Installing K3s on the first node

* Install K3s on the node `k3snode01` with the init-flag

#### Points

* K3s MUST run on node `k3snode01`: 2 Points

### Installing K3s on the second k3snode,  joining the existing one

* Install K3s on the nodes `k3snode02` and join them the first node. Reflect which IP you use and why, especially with respect to the necessary security groups.

#### Points

* K3s MUST run on node `k3snode02` in same cluster as `k3snode01`: 4 Points (2 Points in node and 2 points for running in same cluster as `k3snode01`).

### Execute test workload

Tainting motivates K8s to schedule work not on the defined node. We want to keep `k3snode01` clean from any user workload, so we taint it before executing workloads.

* Execute the example workload.
* Taint the `k3snode01` via `kubectl taint node <Node> k3s-controlplane=true:NoSchedule`. Reschedule workload (e.g. by killing the existing pod to see it redeployed) if necessary.

#### Points

* Example Workload MUST run on cluster successfully on node `k3snode02`: 2 Point


## Part 2: Vanilla Kubernetes, Single Main Node Setup

Kubernetes itself consists of multiple elements all shipped normally via OCI-contaier. It is modular leveraging from the concrete infrastructure it runs whereas additional tools for networking and ingress needs to be defined.

Create a three debian machines called `k8smain01`, `k8smain02`, `k8sworker01`. The machine should be something like 2 CPUs, 4GB RAM, 40GB Storage (typical m1.medium instance).

All common information about installation can be found under: 

* https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
* https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/

### Installing K8s 

Install K8s. A tutorial can be found under https://learning.oreilly.com/library/view/certified-kubernetes-administrator/9781803238265/B18201_02.xhtml#_idParaDest-46 

The following adaptions must be made:

* The apt-repository must be adapted, information about the adaption can be found under https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/change-package-repository/ .
* Be sure that your containerd-version fits your k8s-version and update it if necessary: https://containerd.io/releases/#kubernetes-support
* You might get an error within `kubeadm` like `level=fatal msg="validate service connection: CRI v1 image API is not implemented for endpoint \"unix:///var/run/containerd/containerd.sock\": rpc error: code = Unimplemented desc = unknown service runtime.v1.ImageService"`. To overcome this, cgroup driver must be "systemd" on all nodes. You can set this in the configuration of containerd.
* Be sure CIDRs of Host and k8s are not overlapping according to https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network
* You need to enable iptables to access the traffic according to https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic .
* You need to install a CNI (like flannel), make sure the pod-cidr are set explicety. Read https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network carefully and choose one.

#### Points: 

* Main node MUST be installed and MUST be status ready: 3 Points
* Worker node MUST have joined the cluster and MUST be in status ready: 3 Points
* Kubernetes Version MUST be 1.31: 1 Point
* Example Workload MUST run on cluster successfully on worker node: 1 Point


## Part 3: Installing K8s with two main nodes and one worker node

No we are installing K8s in a way that the master nodes are HA-aware. A tutorial can be found under https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/ .
Etcd can run on the master nodes themselves.

You have to make your own choices regarding load balancing. Load Balancing on Switch is not working.

Mind the following gabs:

* Be sure that that all necessary ports are free beteween the nodes. If not, you might see weird errors like etcd not working or so on.
* If you are working with a virtual IP for load balancing, you might need a dedicated network with dedicated NICs. Be careful when adding a router there because your machines might become unavailable.

#### Points: 

* Second main node MUST be installed and MUST be in status ready: 4 Points


# Write a summary

This repository MUST be cloned on the machine `k8smain01` under the path `/home/debian/platforms_to_build`.
The following URL contains a token to clone this repository:
```
git clone https://clone-token:glpat-Hw4JUcuCPssqM-BZ_88U@gitlab.fhnw.ch/cloud/cloud/platforms_to_build.git
```
. 

A report in `/home/debian/platforms_to_build/03-orchestrator/own_report.md` MUST be written according to the given structure.

