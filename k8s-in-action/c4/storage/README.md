# VOLUMES

These are components of a pod, thus defined in the pods spec. They aren't standalone k8s objects and cannot be created or deleted on their own.
A volume is available to all containers in the pod, but it must be mounted in each container that needs access to it.

### Introducing available volume types
- emptyDir—A simple empty directory used for storing transient data.
- hostPath—Used  for  mounting  directories  from  the  worker  node’s  filesystem into the pod.
- gitRepo—A volume initialized by checking out the contents of a Git repository.
- nfs—An NFS share mounted into the pod.
- gcePersistentDisk (Google Compute Engine Persistent Disk), awsElastic-BlockStore  (Amazon  Web  Services  Elastic  Block  Store  Volume),  azureDisk
(Microsoft  Azure  Disk  Volume)—Used  for  mounting  cloud  provider-specific storage.
- cinder, cephfs, iscsi, flocker, glusterfs, quobyte, rbd, flexVolume, vsphere-Volume,  photonPersistentDisk,  scaleIO—Used  for  mounting  other  types  of
network storage.
- configMap, secret, downwardAPI—Special types of volumes used to expose certain Kubernetes resources and cluster information to the pod.
- persistentVolumeClaim—A way to use a pre- or dynamically provisioned persistent storage.

#### emptyDir volume
- Volume starts out as an empty dir
- The volumes lifetime is tied to that of the pod, volumes contents are lost when the pod is deleted
- Is specifically used for sharing files between containers running in the same pod.
- Can also be used by a single container when data needs to be written temporarily to the disk

#### Using an emptyDir volume in a pod
You’ll build a pod with only the web server container and the content agent and a single volume for the HTML. You’ll use Nginx as the web server and the UNIX fortune command to generate the HTML content. The fortune command prints out a random quote every time you run it. You’ll create a script that invokes the fortune command every 10 seconds and stores  its  output  in  index.html.
