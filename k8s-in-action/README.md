Handy Tips In K8s and some pod labelling
==================
Use the kubectl explain command when building a manifest. This shit comes in handy

```
kubectl explain pods
DESCRIPTION:
Pod is a collection of containers that can run on a host. This resource
             is created by clients and scheduled onto hosts.
FIELDS:
   kind      <string>
     Kind is a string value representing the REST resource this object
     represents...



kubectl explain pods.spec
DESCRIPTION:
Specification of the desired behavior of the pod... podSpec is a description of a pod.
FIELDS:
hostPID <boolean>
Use the host's pid namespace. Optional: Default to false.
```
Labels
======
Each pod is labeled with two labels:
- app, which specifies which app, component, or microservice the pod belongs to.  rel, which shows whether the application running in the pod is a stable, beta,
or a canary release.
DEFINITION A canary release is when you deploy a new version of an applica- tion next to the stable version, and only let a small fraction of users hit the new version to see how it behaves before rolling it out to all users. This pre- vents bad releases from being exposed to too many users.

Check how labels are pretty awesome

```
kubectl get pods -L component,tier -A
NAMESPACE              NAME                                                         READY   STATUS    RESTARTS   AGE   COMPONENT           TIER
kube-system            event-exporter-gke-5479fd58c8-wgdrj                          2/2     Running   0          22h                       
kube-system            fluentbit-gke-552x4                                          2/2     Running   0          64m   fluentbit-gke       
kube-system            fluentbit-gke-khr4v                                          2/2     Running   0          64m   fluentbit-gke       
kube-system            fluentbit-gke-kvrc8                                          2/2     Running   0          64m   fluentbit-gke       
kube-system            gke-metrics-agent-6j4z5                                      1/1     Running   0          64m   gke-metrics-agent   
kube-system            gke-metrics-agent-fmmn4                                      1/1     Running   0          64m   gke-metrics-agent   
kube-system            gke-metrics-agent-lwqd2                                      1/1     Running   0          64m   gke-metrics-agent   
kube-system            konnectivity-agent-86c7cb7bf6-469p8                          1/1     Running   0          63m                       
kube-system            konnectivity-agent-86c7cb7bf6-dn5zb                          1/1     Running   0          63m                       
kube-system            konnectivity-agent-86c7cb7bf6-xzqh7                          1/1     Running   0          22h                       
kube-system            konnectivity-agent-autoscaler-5c49cb58bb-mc9gt               1/1     Running   0          22h                       
kube-system            kube-dns-697dc8fc8b-llkg7                                    4/4     Running   0          22h                       
kube-system            kube-dns-697dc8fc8b-vf9kk                                    4/4     Running   0          22h                       
kube-system            kube-dns-autoscaler-844c9d9448-2tnx8                         1/1     Running   0          22h                       
kube-system            kube-proxy-gke-parth-playground-default-pool-809498a9-7d1n   1/1     Running   0          64m   kube-proxy          node
kube-system            kube-proxy-gke-parth-playground-default-pool-809498a9-hb1r   1/1     Running   0          64m   kube-proxy          node
kube-system            kube-proxy-gke-parth-playground-default-pool-809498a9-vl4c   1/1     Running   0          62m   kube-proxy          node
kube-system            l7-default-backend-865b4c8f8b-xl2c8                          1/1     Running   0          22h                       
kube-system            metrics-server-v0.4.4-857776bc9c-fjvgq                       2/2     Running   0          22h                       
kube-system            pdcsi-node-g7r7h                                             2/2     Running   0          64m                       
kube-system            pdcsi-node-nlj4c                                             2/2     Running   0          64m                       
kube-system            pdcsi-node-qfff7                                             2/2     Running   0          64m                       
kubernetes-dashboard   dashboard-metrics-scraper-c45b7869d-bcxgg                    1/1     Running   0          57m                       
kubernetes-dashboard   kubernetes-dashboard-576cb95f94-blm5v                        1/1     Running   0          57m                       
parth-test             kubia-manual                                                 1/1     Running   0          29m 
```
### Listing pods using a label selector
#### Check out the difference in output from the above usage of label selectors
```
kubectl get pods -l component -A
NAMESPACE     NAME                                                         READY   STATUS    RESTARTS   AGE
kube-system   fluentbit-gke-552x4                                          2/2     Running   0          67m
kube-system   fluentbit-gke-khr4v                                          2/2     Running   0          67m
kube-system   fluentbit-gke-kvrc8                                          2/2     Running   0          67m
kube-system   gke-metrics-agent-6j4z5                                      1/1     Running   0          67m
kube-system   gke-metrics-agent-fmmn4                                      1/1     Running   0          67m
kube-system   gke-metrics-agent-lwqd2                                      1/1     Running   0          67m
kube-system   kube-proxy-gke-parth-playground-default-pool-809498a9-7d1n   1/1     Running   0          67m
kube-system   kube-proxy-gke-parth-playground-default-pool-809498a9-hb1r   1/1     Running   0          67m
kube-system   kube-proxy-gke-parth-playground-default-pool-809498a9-vl4c   1/1     Running   0          66m
```
### Listing pods that don't have that particular label

```
kubectl get pods -l component -A
NAMESPACE     NAME                                                         READY   STATUS    RESTARTS   AGE
kube-system   fluentbit-gke-552x4                                          2/2     Running   0          67m
kube-system   fluentbit-gke-khr4v                                          2/2     Running   0          67m
kube-system   fluentbit-gke-kvrc8                                          2/2     Running   0          67m
kube-system   gke-metrics-agent-6j4z5                                      1/1     Running   0          67m
kube-system   gke-metrics-agent-fmmn4                                      1/1     Running   0          67m
kube-system   gke-metrics-agent-lwqd2                                      1/1     Running   0          67m
kube-system   kube-proxy-gke-parth-playground-default-pool-809498a9-7d1n   1/1     Running   0          67m
kube-system   kube-proxy-gke-parth-playground-default-pool-809498a9-hb1r   1/1     Running   0          67m
kube-system   kube-proxy-gke-parth-playground-default-pool-809498a9-vl4c   1/1     Running   0          66m
```
### More Labelling Magic

```
Similarly, you could also match pods with the following label selectors:
- creation_method!=manual to select pods with the creation_method label with any value other than manual
- env in (prod,devel) to select pods with the env label set to either prod or devel
- env notin (prod,devel) to select pods with the env label set to any value other than prod or devel
```
If you want to select only pods running the beta release of the product catalog microservice, you’d use the following selector: app=pc,rel=beta

## Annotations
Annotations can hold much larger pieces of information and are primarily meant to be used by tools. Certain annotations are automatically added to objects by Kubernetes, but others are added by users manually
A great use of annotations is adding descriptions for each pod or other API object, so that everyone using the cluster can quickly look up information about each individ- ual object. For example, an annotation used to specify the name of the person who created the object can make collaboration between everyone working on the cluster much easier.

#### Tip
TIP To quickly switch to a different namespace, you can set up the following alias: alias kcd='kubectl config set-context $(kubectl config current- context) --namespace '. You can then switch between namespaces using kcd some-namespace.

### Liveness Probes
Kubernetes can probe a container using one of the three mechanisms:
- An HTTP GET probe performs an HTTP GET request on the container’s IP address, a port and  path you specify. If the probe receives a response, and the response code doesn’t represent an error (in other words, if the HTTP response code is 2xx or 3xx), the probe is considered successful. If the server returns an error response code or if it doesn’t respond at all, the probe is considered a fail- ure and the container will be restarted as a result.
- A TCP Socket probe tries to open a TCP connection to the specified port of the container. If the connection is established successfully, the probe is successful. Otherwise, the container is restarted.
- An Exec probe executes an arbitrary command inside the container and checks the command’s exit status code. If the status code is 0, the probe is successful. All other codes are considered failures.

#### Breaking down a liveness probe restart

```
kdscr po kubia-unhealthy | grep -i exit
      Exit Code:    137
```
The exit code was 137, which has a special meaning—it denotes that the process was terminated by an external signal. The number 137 is a sum of two numbers: 128+x, where x is the signal number sent to the process that caused it to ter- minate. In the example, x equals 9, which is the number of the SIGKILL signal, meaning the process was killed forcibly.


```
kdscr po kubia-unhealthy | grep -i Liveness
    Liveness:     http-get http://:8080/ delay=0s timeout=1s period=10s #success=1 #failure=3
  Normal   Killing      24m (x3 over 27m)     kubelet            Container kubia-unhealthy failed liveness probe, will be restarted
  Warning  Unhealthy    3m56s (x28 over 28m)  kubelet            Liveness probe failed: HTTP probe failed with statuscode: 500
```
Beside the liveness probe options you specified explicitly, you can also see additional properties, such as delay, timeout, period, and so on. The delay=0s part shows that the probing begins immediately after the container is started. The timeout is set to only 1 second, so the container must return a response in 1 second or the probe is counted as failed. The container is probed every 10 seconds (period=10s) and the container is restarted after the probe fails three consecutive times (#failure=3).
These additional parameters can be customized when defining the probe. For example, to set the initial delay, add the initialDelaySeconds property to the liveness probe as shown below:
```yaml
   livenessProbe:
    httpGet:
      path: /
      port: 8080
    initialDelaySeconds: 15
```
If you don’t set the initial delay, the prober will start probing the container as soon as it starts, which usually leads to the probe failing, because the app isn’t ready to start receiving requests. If the number of failures exceeds the failure threshold, the con- tainer is restarted before it’s even able to start responding to requests properly.

I’ve seen this on many occasions and users were confused why their container was being restarted. But if they’d used kubectl describe, they’d have seen that the container terminated with exit code 137 or 143, telling them that the pod was terminated externally. Additionally, the listing of the pod’s events would show that the container was killed because of a failed liveness probe. If you see this happening at pod startup, it’s because you failed to set initialDelaySeconds appropriately.

##### NOTE 
Exit code 137 signals that the process was killed by an external signal (exit code is 128 + 9 (SIGKILL). Likewise, exit code 143 corresponds to 128 + 15 (SIGTERM)

But for a better liveness check, you’d configure the probe to perform requests on a specific URL path (/health, for example) and have the app perform an internal status check of all the vital components running inside the app to ensure none of them has died or is unresponsive.
TIP: Make sure the /health HTTP endpoint doesn’t require authentication; otherwise the probe will always fail, causing your container to be restarted indefinitely.


## An amazing tip for preventing Kubernetes Cascade delete

When deleting a ReplicationController with kubectl delete, you can keep its pods running by passing the --cascade=false option to the command. 
```
kubectl delete rc kubia-rc --cascade=false
```
