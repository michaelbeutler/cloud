# Ceph-Tutorial

This tutorial guides you in the installation of Ceph.

All tutorials can be installed on Debian 12 with the newest version of Ceph.

Evaluation takes place on points to be reached. All necessary components for the grading are denoted by a `MUST`. This is necessary as the evaluation takes place with scripts and automatisms.
The grade is based on the points using the following formular:

Grade = 1 + (Points Reached) * 5 / (Max Points)

Total Points reachable: 22

* All nodes MUST have a local user `eval` with the ssh-key stored in https://gitlab.fhnw.ch/cloud/cloud/platforms_to_build/-/blob/main/access/id_ed25519.pub . This user MUST have passwordless sudo-rights. Adding via Group `sudo` might not work since this group is not able to act passwordless by default.
* Your machine names MUST match the names given (e.g. `monitor01` or `osd01`).

Deadline for this project is 13.01.24.


### Ceph Foundations

Ceph is a classical technology found in cloud architectures and a typical representative of software-defined storage.
The architecture of Ceph itself consists of different nodes, which we are going to install. We rely on a small architecture not suitable for productive use cases:

* monitor: Monitor maintain all maps of the cluster 
* osd: Object Storage Nodes represent nodes for storing data themselves

There are also managers and metadata servers but in our tutorial we let the managers run on the monitor nodes. For more information, please consult https://docs.ceph.com/en/latest/start/ .

The storage itself is represented by OSDs. There are different backends available for consuming storage, BlueStore is the way to go nowadays: The idea is to have an unmounted blockdevice on the OSDs which are then consumed and managed by Ceph.
For more information, please take a look at https://docs.ceph.com/en/latest/rados/configuration/storage-devices/#osd-back-ends .

## Install Ceph 

Create a Ceph Cluster. We want to deploy a cluster consisting of four nodes with the following names:

* 1 monitor: monitor01
* 3 OSD: osd[01-03]

Each server should only have 10GB of root-partition. We need the rest of the partitions as additional devices for the cluster (200GB is the quota).
On each machine, add an additional 40GB disk.

#### Points:

* Ceph Cluster MUST run with 1 monitor and 3 OSDs as hosts: 4 Points (1 per correct connected server as device). Check via `ceph orch device ls` from monitor01.
* Ceph Cluster MUST make use of 160GB (4 disks with 40GB each as single OSDs). `ceph osd tree` MUST list all disks on the osd-nodes as Status==up: 4 Points (1 per disk of 40GB).  
* Ceph Cluster MUST be healty, `ceph status` and `ceph health` MUST return `HEALTH_OK`: 4 Points

#### Tips:

* One tutorial can be found under https://docs.ceph.com/en/latest/cephadm/install/#bootstrap-a-new-cluster
* Leave the additional osds on each server untouched, Ceph takes care about them.
* Add the osds with the flag `--method raw`. Otherwise, the devices are not available for generating an OSD on it 

## Provision Storages

Ceph internally relies on pools. Pools are logical partitions where Ceph stores its data.
Internally, pools consists of placement groups which are distributed over OSDs. 
For an overview, please take a look at https://docs.ceph.com/en/latest/rados/operations/placement-groups/ .
It is important to note, that all data is stored in the same abstraction structure of OSDs, Placement Groups and Pools.
This abstraction enables Ceph to provide consistency, distribution, availability independent of the storage kind and is typical for software defined storage.

We are now focussing on the two kinds of data which can be stored in Ceph and want to create a storage interface for each of them like presented in the mgmt-overview:

* rbd
* CephFS

### Block Storage, rbd

Ceph is able to store blocks as it is via Rados Block Device (rbd). rbd e.g. can act as backend for iSCSI. In this part of the tutorial, we want to build pools for storing data via rdb.

1. Create a osd pool on ceph with the name `01-rbd-cloudfhnw`. A tutorial can be found under https://docs.ceph.com/en/latest/rados/operations/pools/ .
2. Init the pool via `rbd`, a tutorial can be found under https://docs.ceph.com/en/latest/rbd/rados-rbd-cmds/ (for the next steps of the block-part as well).
3. Create a client for accessing the block device called `client.01-cloudfhnw-rbd` with read/write access to the pool `01-rbd-cloudfhnw`.
4. In this pool, create an image with 2GB size to act as backend called `01-cloudfhnw-cloud-image`.

#### Points:

* Pool MUST exist with correct name: 2 Points
* Client MUST exists with correct name and correct access: 2 Points
* Image MUST exists with correct settings (name, size, etc.): 2 Points

#### Tips:

Be sure the names fit. Deletion is not easy but can be done as described in https://docs.ceph.com/en/latest/rados/operations/pools/#deleting-a-pool :


### File Storage, CephFS

Ceph is also able to store files directly via a POSIX-compliant filesystem. Basic information can be found under https://docs.ceph.com/en/latest/cephfs/.

1. Create a filesystem called `cephfs-cloudfhnw`.
2. Create a client for accessing the block device called `client.02-cloudfhnw-cephfs` with read/write access to `/`. Please refer to https://docs.ceph.com/en/latest/cephfs/client-auth/ for more information.


#### Points:

* Fileystem MUST exist with correct name: 2 Points 
* Client MUST exist with correct access: 2 Points

#### Tips:

Be sure the names fit. Deletion is not easy but can be done as described in https://docs.ceph.com/en/latest/rados/operations/pools/#deleting-a-pool:



# Write a summary

This repository MUST be cloned on the machine `monitor01` under the path `/home/debian/platforms_to_build`.
The following URL contains a token to clone this repository:
```
git clone https://clone-token:glpat-Hw4JUcuCPssqM-BZ_88U@gitlab.fhnw.ch/cloud/cloud/platforms_to_build.git
```
. 

A report in `/home/debian/platforms_to_build/04-storage/own_report.md` MUST be written according to the given structure.
