# My cheat sheet for CKA
## Enable autocomplete and aliases
Check out the cheat sheet on the docs. Really important
## Daemonset
- Dry run and create a deployment first as below
```
kubectl create deploy ds-1 --image=nginx -o yaml --dry-run > ds.yaml
```
Use the manifest and change it to DaemonSet and remove not required params. Boom! You have a DS

## Pod
```
kubectl run nginx --image=nginx --labels=env=test
```
Create a pod with image nginx and allow traffic on port 80
```
kubectl run nginx --image=nginx --port=80
```
Create a pod and pass an environment variable
```
kubectl run nginx --image=nginx --env=var1=value1
```
- to check whether the variable is there or not
```
kubectl exec -it nginx -- env
```

Create a pod and add `sleep 3600` command
```
kubectl run busybox --image=busybox -- /bin/sh -c "sleep 3600"
```
List pods with different levels of verbosity
```
kubectl get po --v=7 (use 8 or 9 for more verbosity)
```

List pods using custom columns like below
```
kubectl get pods -o=custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name"
```

## Attaching a service to a pod
```
kubectl expose pod front-end --name=frontend-svc --port=80 --target-port=80 --type=NodePort
```

## Deployment
```
kubectl create deploy dep1 --image=nginx --replicas=7
```
So let's say you want to change the image of a deployment you would use the kubectl set command as below
```
kubectl set image deployment nginx-app-reloaded nginx=nginx:1.11.13-alpine
```

Let's say you want to rollback to the previous version all you need to do is as below
```
kubectl rollout undo deployment nginx-app-reloadedkubectl set image deployment nginx-app-reloaded nginx=nginx:1.11.13-alpine
```
## List all pods attached to a service
Describe the SVC, Use the label in the service to list all the pods. List all pods with that particular label

## Set node as unavailable and reschedule all pods running on it
```
kubectl drain 'node-name' --ignore-daemonsets --delete-local-data --force
```

## Create pod that mounts a secret at a specific mount point
Best use the docs to get the manifest. We would be looking deeper into this

## Aliases needed
alias k = "kubectl"
alias kg = "kubectl get"
alias kd = "kubectl describe"
alias kcsc = "kubectl config set-context --current --namespace="

## Shortcuts not to forget 
-o name like so
```
pa6105074@mothership: test-1 k config get-contexts        
CURRENT   NAME                                                                                  CLUSTER                                                  AUTHINFO                                                     NAMESPACE
          admin                                                                                 03                                                       admin                                                        
*         gke_modified-wonder-329603_us-west1-a_parth-playground                                gke_modified-wonder-329603_us-west1-a_parth-playground   gke_modified-wonder-329603_us-west1-a_parth-playground       parth-test-2
pa6105074@mothership: test-1 k config get-contexts -o name
admin
gke_modified-wonder-329603_us-west1-a_parth-playground
```

If the question asks you to record your action. Just do a --record at the end of the command and this will create an annotation that records your action

## Notes

Change service cidr in the apiserver and controller manager manifests in the worker nodes. Not sure a good idea or not. But this is what i see

