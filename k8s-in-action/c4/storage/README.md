# VOLUMES

These are components of a pod, thus defined in the pods spec. They aren't standalone k8s objects and cannot be created or deleted on their own.
A volume is available to all containers in the pod, but it must be mounted in each container that needs access to it.

### Introducing available volume types
- emptyDir—A simple empty directory used for storing transient data.
- hostPath—Used for mounting directories from the worker node’s filesystem into the pod.
- gitRepo—A volume initialized by checking out the contents of a Git repository.
- nfs—An NFS share mounted into the pod.
- gcePersistentDisk (Google Compute Engine Persistent Disk), awsElastic-BlockStore (Amazon Web Services Elastic Block Store Volume), azureDisk
(Microsoft Azure Disk Volume)—Used for mounting cloud provider-specific storage.
- cinder, cephfs, iscsi, flocker, glusterfs, quobyte, rbd, flexVolume, vsphere-Volume, photonPersistentDisk, scaleIO—Used for mounting other types of
network storage.
- configMap, secret, downwardAPI—Special types of volumes used to expose certain Kubernetes resources and cluster information to the pod.
- persistentVolumeClaim—A way to use a pre- or dynamically provisioned persistent storage.

#### emptyDir volume
- Volume starts out as an empty dir
- The volumes lifetime is tied to that of the pod, volumes contents are lost when the pod is deleted
- Is specifically used for sharing files between containers running in the same pod.
- Can also be used by a single container when data needs to be written temporarily to the disk

#### Using an emptyDir volume in a pod
You’ll build a pod with only the web server container and the content agent and a single volume for the HTML. You’ll use Nginx as the web server and the UNIX fortune command to generate the HTML content. The fortune command prints out a random quote every time you run it. You’ll create a script that invokes the fortune command every 10 seconds and stores its output in index.html.

#### Refresher on how to build Docker images - feel free to ignore
Building the fortune container image
Here’s how to build the image. Create a new directory called fortune and then inside it, create a fortuneloop.sh shell script with the following contents:
```
#!/bin/bash
trap "exit" SIGINT
mkdir /var/htdocs
while :
do
  echo $(date) Writing fortune to /var/htdocs/index.html
  /usr/games/fortune > /var/htdocs/index.html
  sleep 10
done
```
Then, in the same directory, create a file called Dockerfile containing the following:
```
FROM ubuntu:latest
RUN apt-get update ; apt-get -y install fortune
ADD fortuneloop.sh /bin/fortuneloop.sh
ENTRYPOINT /bin/fortuneloop.sh
```
The image is based on the ubuntu:latest image, which doesn’t include the fortune binary by default. That’s why in the second line of the Dockerfile you install it with apt-get. After that, you add the fortuneloop.sh script to the image’s /bin folder. In the last line of the Dockerfile, you specify that the fortuneloop.sh script should be executed when the image is run.
After preparing both files, build and upload the image to Docker Hub with the following two commands (replace luksa with your own Docker Hub user ID):
```
$ docker build -t luksa/fortune .
$ docker push luksa/fortune
```
#### Seeing the pod in action
Use the emptyDirVolume.yaml. You need to enable access to the pod, And you can port forward to do that. You can try the commands below to see what you get
```
kubectl port-forward fortune 8080:80        
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
Handling connection for 8080
```
```
curl http://localhost:8080          
Cold hands, no gloves.
pa6105074@mothership: parth-personal curl http://localhost:8080
Today is the first day of the rest of the mess.
```
#### Specifying the medium to use for the emptyDir
The emptyDir you used as the volume was created on the actual disk of the worker node hosting your pod, so its performance depends on the type of the node’s disks. But you can tell Kubernetes to create the emptyDir on a tmpfs filesystem (in memory instead of on disk). To do this, set the emptyDir’s medium to Memory like this:
```yaml
volumes:
  - name: html
emptyDir:
      medium: Memory #This emptyDir’s files should be stored in memory.
```
#### Using a Git Repo as the starting point for a volume
- This is basically an emptyDir volume that gets populated by cloning a Git repo and checking out a specific revision when the pod is starting up (but b4 the containers are created)
  
**NOTE** After the gitRepo volume is created, it isn’t kept in sync with the repo it’s referencing. The files in the volume will not be updated when you push additional commits to the Git repository. However, if your pod is managed by a ReplicationController, deleting the pod will result in a new pod being cre- ated and this new pod’s volume will then contain the latest commits.

#### Running a web server pod serving files from a cloned git repo
Check out the gitrepo-volume-pod.yaml file. Has the manifest required to point to your git Repo. When you create the pod the volume is first initialized as an empty directory and then the git repo is cloned into it. If you hadn’t set the directory to . (dot), the repository would have been cloned into the kubia-website-example subdirectory, which isn’t what you want. You want the repo to be cloned into the root directory of your volume. Along with the repository, you also specified you want Kubernetes to check out whatever revision the master branch is pointing to at the time the volume is created. Use port-forward curl to hit it.

To confirm that the files are not kept in sync you can change it on the git repo and see. And delete the pod to see the effect also

#### Introducing sidecar containers
The Git sync process shouldn’t run in the same container as the Nginx web server, but in a second container: a sidecar container. A sidecar container is a container that augments the operation of the main container of the pod. You add a sidecar to a pod so you can use an existing container image instead of cramming additional logic into the main app’s code, which would make it overly complex and less reusable.
To find an existing container image, which keeps a local directory synchronized with a Git repository, go to Docker Hub and search for “git sync.” You’ll find many images that do that. Then use the image in a new container in the pod from the previous example, mount the pod’s existing gitRepo volume in the new container, and configure the Git sync container to keep the files in sync with your Git repo. If you set everything up correctly, you should see that the files the web server is serving are kept in sync with your GitHub repo.

This will follow also, so wait up. You'll see it.

**NOTE**: gitRepo volumes also doesn't support private repos thus we should always use the sidecar container approach in this case.

### Accessing files on the worker nodes filesystem
Certain system level pods (Mostly managed by a DS) do need to either read the node's files or use the node's filesystem. K8s make this possible throught hostPath volume.

This is the first type of persistent storage we are discussing so far. If a pod is deleted and another pod comes in place of that, it will see the same stuff the other pod was seeing as long as it lands on the same node as the previous pod.
This is the reason its not a good idea to use this for regular pods

Checking a pod in the kube-system namespace and describing it, you will see this.
```
Volumes:
  varrun:
    Type:          HostPath (bare host directory volume)
    Path:          /var/run/google-fluentbit/pos-files
    HostPathType:  
  varlog:
    Type:          HostPath (bare host directory volume)
    Path:          /var/log
    HostPathType:  
  varlibkubeletpods:
    Type:          HostPath (bare host directory volume)
    Path:          /var/lib/kubelet/pods
    HostPathType:  
  varlibdockercontainers:
    Type:          HostPath (bare host directory volume)
    Path:          /var/lib/docker/containers
    HostPathType:
```
**NOTE**: hostPath volumes are mostly just used if you need to read or write to system files on the node.

### Using persistent storage

- None of the above works when you want data to persist even when pods die. For that it must be stored on some type of NAS.
- To learn about volumes that allow persisting data, you’ll create a pod that will run the MongoDB document-oriented NoSQL database

##### Using a GCE persistent disk in a pod volume
Automatic storage provision is now possible on GKE, but we will try this manually to learn the process better. Use the gcePersistentDiskVolume.yaml manifest to apply this.

Before you apply the manifest, create the disk as shown below:
```
gcloud container clusters list 
NAME              LOCATION    MASTER_VERSION   MASTER_IP      MACHINE_TYPE  NODE_VERSION     NUM_NODES  STATUS
parth-playground  us-west1-a  1.21.5-gke.1302  35.233.135.85  e2-medium     1.21.5-gke.1302  3          RUNNING
```
```
gcloud compute disks create mongodb --size=10GB --zone=us-west1-a
WARNING: You have selected a disk size of under [200GB]. This may result in poor I/O performance. For more information, see: https://developers.google.com/compute/docs/disks#performance.
Created [https://www.googleapis.com/compute/v1/projects/modified-wonder-329603/zones/us-west1-a/disks/mongodb].
NAME     ZONE        SIZE_GB  TYPE         STATUS
mongodb  us-west1-a  10       pd-standard  READY

New disks are unformatted. You must format and mount a disk before it
can be used. You can find instructions on how to do this at:

https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting
```
Even if you delete the pod and recreate it. The mongo data will still be there. You can try that if needed to test. Check mongo commands to add data, and check if there after deleting the pod

##### Using an awsElasticBlockStore
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mongodb
spec:
  volumes:
  - name: mongodb-data
    awsElasticBlockStore: 
      volumeId: my-volume
      fsType: ext4
    containers:
```
##### Using an NFS volume
```yaml
volumes:
  - name: mongodb-data
    nfs:
      server: 1.2.3.4 #ip of the nfs server
      path: /some/path # the path exported by the server
```
#### Claiming a PV by creating a PVC
Most things you already know. But good to know these:
- RWO—ReadWriteOnce — Only a single node can mount the volume for reading and writing.
- ROX—ReadOnlyMany — Multiple nodes can mount the volume for reading.
- RWX—ReadWriteMany — Multiple nodes can mount the volume for both reading and writing.

Once a PVC is created as per mongodb-pvc.yaml you just need to specify it in your pod manifest as below:
```yaml
spec:
  containers:
  - image: mongo
    name: mongodb
    volumeMounts:
    - name: mongodb-data
      mountPath: /data/db
    ports:
    - containerPort: 27017
      protocol: TCP
  volumes:
  - name: mongodb-data
    persistentVolumeClaim:
      claimName: mongodb-pvc
```


##### Recycling PVs
Before you wrap up this section on PersistentVolumes, let’s do one last quick experi- ment. Delete the pod and the PersistentVolumeClaim:
```
        $ kubectl delete pod mongodb
        pod "mongodb" deleted
        $ kubectl delete pvc mongodb-pvc
        persistentvolumeclaim "mongodb-pvc" deleted
```
What if you create the PersistentVolumeClaim again? Will it be bound to the Persistent- Volume or not? After you create the claim, what does kubectl get pvc show?
```
        $ kubectl get pvc
        NAME           STATUS    VOLUME       CAPACITY   ACCESSMODES   AGE
        mongodb-pvc    Pending                                         13s
```
The claim’s status is shown as Pending. Interesting. When you created the claim ear- lier, it was immediately bound to the PersistentVolume, so why wasn’t it bound now? Maybe listing the PersistentVolumes can shed more light on this:
```
        $ kubectl get pv
        NAME        CAPACITY  ACCESSMODES  STATUS    CLAIM               REASON AGE
        mongodb-pv  1Gi       RWO,ROX      Released  default/mongodb-pvc        5m
```
The STATUS column shows the PersistentVolume as Released, not Available like before. Because you’ve already used the volume, it may contain data and shouldn’t be bound to a completely new claim without giving the cluster admin a chance to clean it up. Without this, a new pod using the same PersistentVolume could read the data stored there by the previous pod, even if the claim and pod were created in a different namespace (and thus likely belong to a different cluster tenant).


#### PersistentVolume Reclaim policies
Two other possible reclaim policies exist: Recycle and Delete. The first one deletes the volume’s contents and makes the volume available to be claimed again. This way, the PersistentVolume can be reused multiple times by different PersistentVolumeClaims and different pods. The Delete policy, on the other hand, deletes the underlying storage. 

A PersistentVolume only supports the Retain or Delete policies. Other PersistentVolume types may or may not support each of these options, so before creating your own PersistentVolume, be sure to check what reclaim policies are supported for the specific underlying storage you’ll use in the volume.
**TIP** You can change the PersistentVolume reclaim policy on an existing PersistentVolume. For example, if it’s initially set to Delete, you can easily change it to Retain to prevent losing valuable data.

#### Dynamic provisioning of PVs
Cluster admin in stead of creating PVs can deploy Persistent Volume Provisioner and define one or more SCs to let users choose what type of PV they want. K8s includes provisioners for most popular cloud providers, so the admin doesn't always need to deploy a provisioner. In stead of the admin, pre-provisioning a bunch of PVs they need to define one or two more SCs and let the system create a new PV each timeone is requested through a PVC. Check storageClass.yaml and pvc-with-sc.yaml to get more details.

A PersistentVolume only supports the Retain or Delete policies. Other Persistent- Volume types may or may not support each of these options, so before creating your own PersistentVolume, be sure to check what reclaim policies are supported for the specific underlying storage you’ll use in the volume.
TIP You can change the PersistentVolume reclaim policy on an existing PersistentVolume. For example, if it’s initially set to Delete, you can easily change it to Retain to prevent losing valuable data.

**Examining the created SC**
```
$ kubectl get pvc mongodb-pvc
NAME          STATUS   VOLUME         CAPACITY   ACCESSMODES   STORAGECLASS
mongodb-pvc   Bound    pvc-1e6bc048   1Gi        RWO           fast
```
The VOLUME column shows the PersistentVolume that’s bound to this claim (the actual name is longer than what’s shown above). You can try listing PersistentVolumes now to see that a new PV has indeed been created automatically:
```
$ kubectl get pv
NAME CAPACITY ACCESSMODES RECLAIMPOLICY STATUS STORAGECLASS mongodb-pv 1Gi RWO,ROX Retain Released
pvc-1e6bc048 1Gi RWO Delete Bound fast
```
NOTE Only pertinent columns are shown.
You can see the dynamically provisioned PersistentVolume. Its capacity and access modes are what you requested in the PVC. Its reclaim policy is Delete, which means the PersistentVolume will be deleted when the PVC is deleted. Beside the PV, the provisioner also provisioned the actual storage. Your fast StorageClass is configured to use the kubernetes.io/gce-pd provisioner, which provisions GCE Persistent Disks. You can see the disk with the following command:
```
$ gcloud compute disks list
NAME                          ZONE            SIZE_GB  TYPE         STATUS
gke-kubia-dyn-pvc-1e6bc048    europe-west1-d  1        pd-ssd       READY
gke-kubia-dyn-pvc-1e6bc048    europe-west1-d  1        pd-standard  READY
gke-kubia-default-pool-71df   europe-west1-d  100      pd-standard  READY
gke-kubia-default-pool-71df   europe-west1-d  100      pd-standard  READY
gke-kubia-default-pool-71df   europe-west1-d  100      pd-standard  READY
gke-kubia-default-pool-79cd   europe-west1-d  100      pd-standard  READY
gke-kubia-default-pool-blc4   europe-west1-d  100      pd-standard  READY
mongodb                       europe-west1-d  1        pd-standard  READY
```
Dynamic provisioning of PersistentVolume As you can see, the first persistent disk’s name suggests it was provisioned dynamically and its type shows it’s an SSD, as specified in the storage class you created earlier.

##### Examining the default SC
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  name: standard
parameters:
  type: pd-standard
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Delete
volumeBindingMode: Immediate
```
If you look closely toward the top of the listing, the storage class definition includes an annotation, which makes this the default storage class. The default storage class is what’s used to dynamically provision a PersistentVolume if the PersistentVolumeClaim doesn’t explicitly say which storage class to use.

##### **FORCING A PERSISTENTVOLUMECLAIM TO BE BOUND TO ONE OF THE PRE-PROVISIONED PERSISTENT VOLUMES**
This finally brings us to why you set storageClassName to an empty string (when you wanted the PVC to bind to the PV you’d provisioned manually). Let me repeat the relevant lines of that PVC definition here:
If you hadn’t set the storageClassName attribute to an empty string, the dynamic volume provisioner would have provisioned a new PersistentVolume, despite there being an appropriate pre-provisioned PersistentVolume. At that point, I wanted to demonstrate how a claim gets bound to a manually pre-provisioned PersistentVolume. I didn’t want the dynamic provisioner to interfere.

TIP Explicitly set storageClassName to "" if you want the PVC to use a pre- provisioned PersistentVolume.