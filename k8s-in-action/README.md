- [Handy Tips In K8s and some pod labelling](#handy-tips-in-k8s-and-some-pod-labelling)
- [Labels](#labels)
    - [Listing pods using a label selector](#listing-pods-using-a-label-selector)
  - [Check out the difference in output from the above usage of label selectors](#check-out-the-difference-in-output-from-the-above-usage-of-label-selectors)
    - [Listing pods that don't have that particular label](#listing-pods-that-dont-have-that-particular-label)
    - [More Labelling Magic](#more-labelling-magic)
  - [Annotations](#annotations)
  - [Tip](#tip)
    - [Liveness Probes](#liveness-probes)
  - [Breaking down a liveness probe restart](#breaking-down-a-liveness-probe-restart)
    - [NOTE](#note)
  - [An amazing tip for preventing Kubernetes Cascade delete](#an-amazing-tip-for-preventing-kubernetes-cascade-delete)
  - [ReplicaSets](#replicasets)
    - [Replication Controller vs ReplicaSets](#replication-controller-vs-replicasets)
    - [ReplicaSets - A little deep dive](#replicasets---a-little-deep-dive)
    - [Jobs](#jobs)
  - [Running multiple instances in a Job](#running-multiple-instances-in-a-job)
  - [Running job pods in parallel](#running-job-pods-in-parallel)
  - [Limiting the time allowed for a Job pod to complete](#limiting-the-time-allowed-for-a-job-pod-to-complete)
  - [Cron Jobs](#cron-jobs)


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
- app, which specifies which app, component, or microservice the pod belongs to.
- rel, which shows whether the application running in the pod is a stable, beta, or a canary release.
DEFINITION A canary release is when you deploy a new version of an application next to the stable version, and only let a small fraction of users hit the new version to see how it behaves before rolling it out to all users. This prevents bad releases from being exposed to too many users.

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
## Check out the difference in output from the above usage of label selectors
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
parth@Parth MINGW64 ~/OneDrive/Desktop/coding-arena/k8sTestingArena (master)
$ kubectl get pods -l app!=kubia
NAME                                  READY   STATUS    RESTARTS   AGE
check-ip                              1/1     Running   0          44h
dep1-555947d676-cddm8                 1/1     Running   0          8d
dep1-555947d676-dww4b                 1/1     Running   0          8d
dep1-555947d676-fw5hh                 1/1     Running   0          8d
dep1-555947d676-h8jt4                 1/1     Running   0          8d
dep1-555947d676-j6nc6                 1/1     Running   0          8d
dep1-555947d676-m2w4n                 1/1     Running   0          8d
dep1-555947d676-pq7mz                 1/1     Running   0          8d
ds-1-4sstr                            1/1     Running   0          8d
ds-1-n4vxw                            1/1     Running   0          8d
ds-1-vbzwl                            1/1     Running   0          8d
mypod-secrets-via-file                1/1     Running   0          3d17h
nginx-app-fc7875d8-5dnfc              1/1     Running   0          8d
nginx-app-fc7875d8-bw6d5              1/1     Running   0          8d
nginx-app-fc7875d8-s9mv7              1/1     Running   0          8d
nginx-app-reloaded-775d74f595-c6xs6   1/1     Running   0          3d18h
nginx-app-reloaded-775d74f595-thl7n   1/1     Running   0          3d18h
nginx-app-reloaded-775d74f595-zngcx   1/1     Running   0          3d18h

parth@Parth MINGW64 ~/OneDrive/Desktop/coding-arena/k8sTestingArena (master)
$ kubectl get pods --show-labels
NAME                                  READY   STATUS    RESTARTS   AGE     LABELS
check-ip                              1/1     Running   0          44h     run=check-ip
dep1-555947d676-cddm8                 1/1     Running   0          8d      app=dep1,pod-template-hash=555947d676
dep1-555947d676-dww4b                 1/1     Running   0          8d      app=dep1,pod-template-hash=555947d676
dep1-555947d676-fw5hh                 1/1     Running   0          8d      app=dep1,pod-template-hash=555947d676
dep1-555947d676-h8jt4                 1/1     Running   0          8d      app=dep1,pod-template-hash=555947d676
dep1-555947d676-j6nc6                 1/1     Running   0          8d      app=dep1,pod-template-hash=555947d676
dep1-555947d676-m2w4n                 1/1     Running   0          8d      app=dep1,pod-template-hash=555947d676
dep1-555947d676-pq7mz                 1/1     Running   0          8d      app=dep1,pod-template-hash=555947d676
ds-1-4sstr                            1/1     Running   0          8d      app=ds-1,controller-revision-hash=8646d56889,pod-template-generation=1
ds-1-n4vxw                            1/1     Running   0          8d      app=ds-1,controller-revision-hash=8646d56889,pod-template-generation=1
ds-1-vbzwl                            1/1     Running   0          8d      app=ds-1,controller-revision-hash=8646d56889,pod-template-generation=1
kubia-deployment-7c9f8f88df-7fdss     1/1     Running   0          8d      app=kubia,pod-template-hash=7c9f8f88df
kubia-deployment-7c9f8f88df-b4zfp     1/1     Running   0          8d      app=kubia,pod-template-hash=7c9f8f88df
kubia-deployment-7c9f8f88df-h7mzv     1/1     Running   0          8d      app=kubia,pod-template-hash=7c9f8f88df
kubia-dnbrf                           0/1     Running   0          8d      app=kubia
kubia-m56g8                           0/1     Running   0          8d      app=kubia
kubia-msjwq                           0/1     Running   0          8d      app=kubia
mypod-secrets-via-file                1/1     Running   0          3d17h   <none>
nginx-app-fc7875d8-5dnfc              1/1     Running   0          8d      app=nginx-app,pod-template-hash=fc7875d8
nginx-app-fc7875d8-bw6d5              1/1     Running   0          8d      app=nginx-app,pod-template-hash=fc7875d8
nginx-app-fc7875d8-s9mv7              1/1     Running   0          8d      app=nginx-app,pod-template-hash=fc7875d8
nginx-app-reloaded-775d74f595-c6xs6   1/1     Running   0          3d18h   app=nginx-app-reloaded,pod-template-hash=775d74f595
nginx-app-reloaded-775d74f595-thl7n   1/1     Running   0          3d18h   app=nginx-app-reloaded,pod-template-hash=775d74f595
nginx-app-reloaded-775d74f595-zngcx   1/1     Running   0          3d18h   app=nginx-app-reloaded,pod-template-hash=775d74f595
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

## Tip
TIP To quickly switch to a different namespace, you can set up the following alias: alias kcd='kubectl config set-context $(kubectl config current- context) --namespace '. You can then switch between namespaces using kcd some-namespace.

### Liveness Probes
Kubernetes can probe a container using one of the three mechanisms:
- An HTTP GET probe performs an HTTP GET request on the container’s IP address, a port and  path you specify. If the probe receives a response, and the response code doesn’t represent an error (in other words, if the HTTP response code is 2xx or 3xx), the probe is considered successful. If the server returns an error response code or if it doesn’t respond at all, the probe is considered a fail- ure and the container will be restarted as a result.
- A TCP Socket probe tries to open a TCP connection to the specified port of the container. If the connection is established successfully, the probe is successful. Otherwise, the container is restarted.
- An Exec probe executes an arbitrary command inside the container and checks the command’s exit status code. If the status code is 0, the probe is successful. All other codes are considered failures.

## Breaking down a liveness probe restart

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

### NOTE 
Exit code 137 signals that the process was killed by an external signal (exit code is 128 + 9 (SIGKILL). Likewise, exit code 143 corresponds to 128 + 15 (SIGTERM)

But for a better liveness check, you’d configure the probe to perform requests on a specific URL path (/health, for example) and have the app perform an internal status check of all the vital components running inside the app to ensure none of them has died or is unresponsive.
TIP: Make sure the /health HTTP endpoint doesn’t require authentication; otherwise the probe will always fail, causing your container to be restarted indefinitely.


## An amazing tip for preventing Kubernetes Cascade delete

When deleting a ReplicationController with kubectl delete, you can keep its pods running by passing the --cascade=false option to the command. 
```
kubectl delete rc kubia-rc --cascade=false
```

## ReplicaSets
### Replication Controller vs ReplicaSets
A single ReplicationController can’t match pods with the label env=production and those with the label env=devel at the same time. It can only match either pods with the env=production label or pods with the env=devel label. But a single ReplicaSet can match both sets of pods and treat them as a single group.
Similarly, a ReplicationController can’t match pods based merely on the presence of a label key, regardless of its value, whereas a ReplicaSet can. For example, a ReplicaSet can match all pods that include a label with the key env, whatever its actual value is (you can think of it as env=*).

### ReplicaSets - A little deep dive
You can add additional expressions to the selector. As in the example, each expression must contain a key, an operator, and possibly (depending on the operator) a list of values. You’ll see four valid operators:
- In—Label’s value must match one of the specified values.
- NotIn—Label’s value must not match any of the specified values.
- Exists—Pod must include a label with the specified key (the value isn’t import-
ant). When using this operator, you shouldn’t specify the values field.
- DoesNotExist—Pod must not include a label with the specified key. The values
property must not be specified.
If you specify multiple expressions, all those expressions must evaluate to true for the selector to match a pod. If you specify both matchLabels and matchExpressions, all the labels must match and all the expressions must evaluate to true for the pod to match the selector.

Example code below:
```yaml
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: kubia
spec:
  replicas: 3
  selector:
    matchExpressions:
      - key: app
        operator: In
        values:
         - kubia
  template:
    metadata:
      labels:
        app: kubia
    spec:
      containers:
      - name: kubia
        image: parthghetia/kubia
```

### Jobs

This creates one or more pods that will try to execute the required commands specified in the job manifest and will keep the pods running until this is not done. Once the task is complete the pods are terminated

In case of a failure in the job the job can be configured to restart or do some kind of action

An example of such a job would be if you had data stored somewhere and you needed to transform and export it somewhere. You’re going to emulate this by running a container image built on top of the busybox image, which invokes the sleep command for two minutes.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: kubia-job
spec:
  template:
    metadata:
      labels:
        app: kubia-job
    spec:
      containers:
      - name: main
        image: luksa/batch-job
      restartPolicy: OnFailure
```

You need to explicitly define the RestartPolicy always because jobs are not meant to run indefinitely. This is what prevents a container from restarting when the job is completed.

## Running multiple instances in a Job

Jobs maybe configured to create more than one pod instance and run them parallel or sequentially. This is done by setting the completions and the parallelism properties in the Job spec.
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: multi-completion-batch-job
spec:
  completions: 5
  template:
#Setting completions to 5 makes this Job run five pods sequentially.
```
This Job will run five pods one after the other. It initially creates one pod, and when the pod’s container finishes, it creates the second pod, and so on, until five pods complete successfully. If one of the pods fails, the Job creates a new pod, so the Job may create more than five pods overall.

## Running job pods in parallel

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: multi-completion-batch-job
spec:
  completions: 5
  parallelism: 2
  template:
```
By setting parallelism to 2, the Job creates two pods and runs them in parallel:

As soon as one of them finishes, the Job will run the next pod, until five pods finish successfully.
You can even change a Job’s parallelism property while the Job is running. This is similar to scaling a ReplicaSet or ReplicationController, and can be done with the kubectl scale command:
```
$ kubectl scale job multi-completion-batch-job --replicas 3
job "multi-completion-batch-job" scaled
```
## Limiting the time allowed for a Job pod to complete

A pod’s time can be limited by setting the activeDeadlineSeconds property in the pod spec. If the pod runs longer than that, the system will try to terminate it and will mark the Job as failed.
NOTE You can configure how many times a Job can be retried before it is marked as failed by specifying the spec.backoffLimit field in the Job manifest. If you don't explicitly specify it, it defaults to 6.

## Cron Jobs

Batch jobs that need to be run at a specific time in the future, or repeatedly.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: batch-job-every-fifteen-mins
spec:
  schedule: "0,5,10,15 * * * *"
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: periodic-batch-job
        spec:
          containers:
            - name: main
              image: luksa/batch-job
          restartPolicy: OnFailure
```
Pretty self explanatory stuff. You can use online tools to configure a cron job and when to run it. And the online tool will tell you.

It may happen that the Job or pod is created and run relatively late. You may have a hard requirement for the job to not be started too far over the scheduled time. In that case, you can specify a deadline by specifying the startingDeadlineSeconds field in the CronJob specification
```yaml
apiVersion: batch/v1beta1
kind: CronJob
spec:
  schedule: "0,15,30,45 * * * *"
  startingDeadlineSeconds: 15
```
One of the times the job is supposed to run is 10:30:00. If it doesn’t start by 10:30:15 for whatever reason, the job will not run and will be shown as Failed.
In normal circumstances, a CronJob always creates only a single Job for each execution configured in the schedule, but it may happen that two Jobs are created at the same time, or none at all. To combat the first problem, your jobs should be idempotent (running them multiple times instead of once shouldn’t lead to unwanted results). For the second problem, make sure that the next job run performs any work that should have been done by the previous (missed) run.


