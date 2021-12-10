## Services

###### Tip: Remotely executing commands in runnning containers
```
kubectl exec kubia-rc-2g7c2 -- curl -s http://10.120.0.244
You've hit kubia-rc-rkzcc
```
The double dash (--) in the command signals the end of command options for kubectl. Everything after the double dash is the command that should be executed inside the pod. Using the double dash isn’t necessary if the command has no arguments that start with a dash. But in your case, if you don’t use the double dash there, the -s option would be interpreted as an option for kubectl exec and would result in the following strange and highly misleading error:
```
$ kubectl exec kubia-7nog1 curl -s http://10.111.249.153
The connection to the server 10.111.249.153 was refused – did you
     specify the right host or port?
```

A service load balances across different pods but however if sometimes you don't want the load balancing and just want the external service to hit only one pod in that case you can use session affinity like so:
```yaml
apiVersion: v1
kind: Service
spec:
  sessionAffinity: ClientIP
```
This makes the service proxy redirect all requests originating from the same client IP to the same pod

#### EXPOSING MULTIPLE PORTS IN THE SAME SERVICE
Your service exposes only a single port, but services can also support multiple ports. For example, if your pods listened on two ports—let’s say 8080 for HTTP and 8443 for HTTPS—you could use a single service to forward both port 80 and 443 to the pod’s ports 8080 and 8443. Using a single, multi-port service exposes all the service’s ports through a single cluster IP.
NOTE: When creating a service with multiple ports, you must specify a name for each port.
```yaml
apiVersion: v1
kind: Service
metadata:
name: kubia
spec: ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: https
port: 443
    targetPort: 8443
  selector:
app: kubia

#The label selector always applies to the whole service.
```
You can also use named ports. Same shit but just change with name in stead of number. Specify the name in the pod definition and use it in the service. Can be skipped but helpful if you have non-famous ports.

Also helps if you sometime change the ports. You just define in one place and that's it

### How services are discovered through environment variables

When a pod is started, Kubernetes initializes a set of environment variables pointing to each service that exists at that moment. If you create the service before creating the client pods, processes in those pods can get the IP address and port of the service by inspecting their environment variables.

```
k exec kubia-rc-qlrp9 env
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=kubia-rc-qlrp9
NPM_CONFIG_LOGLEVEL=info
NODE_VERSION=7.10.1
YARN_VERSION=0.24.4
KUBIA_RC_PORT=tcp://10.120.0.244:80
KUBIA_RC_PORT_80_TCP_PROTO=tcp
KUBIA_RC_PORT_80_TCP_ADDR=10.120.0.244
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=10.120.0.1
KUBIA_RC_PORT_80_TCP=tcp://10.120.0.244:80
KUBERNETES_SERVICE_HOST=10.120.0.1
KUBERNETES_PORT_443_TCP=tcp://10.120.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBIA_RC_SERVICE_HOST=10.120.0.244
KUBIA_RC_SERVICE_PORT=80
KUBIA_RC_PORT_80_TCP_PORT=80
KUBERNETES_PORT=tcp://10.120.0.1:443
HOME=/root

kg svc                   
NAME       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubia-rc   ClusterIP   10.120.0.244   <none>        80/TCP    22h
```
Two services are defined in your cluster: the kubernetes and the kubia service (you saw this earlier with the kubectl get svc command); consequently, two sets of service related environment variables are in the list. Among the variables that pertain to the kubia service you created at the beginning of the chapter, you’ll see the KUBIA_SERVICE _HOST and the KUBIA_SERVICE_PORT environment variables, which hold the IP address and port of the kubia service, respectively.

###### NOTE: 
Turning back to the frontend-backend example we started this chapter with, when you have a frontend pod that requires the use of a backend database server pod, you can expose the backend pod through a service called backend-database and then have the frontend pod look up its IP address and port through the environment vari- ables BACKEND_DATABASE_SERVICE_HOST and BACKEND_DATABASE_SERVICE_PORT.

### How services are discovered through DNS

Remember when you listed pods in the kube-system namespace? One of the pods was called kube-dns. The kube-system namespace also includes a corresponding service with the same name.
As the name suggests, the pod runs a DNS server, which all other pods running in the cluster are automatically configured to use (Kubernetes does that by modifying each container’s /etc/resolv.conf file). Any DNS query performed by a process running in a pod will be handled by Kubernetes’ own DNS server, which knows all the services running in your system.

**NOTE:** Whether a pod uses the internal DNS server or not is configurable through the dnsPolicy property in each pod’s spec.

Each service gets a DNS entry in the internal DNS server, and client pods that know the name of the service can access it through its fully qualified domain name (FQDN) instead of resorting to environment variables.

To revisit the frontend-backend example, a frontend pod can connect to the backend database service by opening a connection to the following FQDN:
backend-database.default.svc.cluster.local
backend-database corresponds to the service name, default stands for the namespace the service is defined in, and svc.cluster.local is a configurable cluster domain suffix used in all cluster local service names.

Connecting to a service can be even simpler than that. You can omit the svc.cluster.local suffix and even the namespace, when the frontend pod is in the same name- space as the database pod. You can thus refer to the service simply as backend- database.

```
root@kubia-rc-qlrp9:/# curl http://10.120.0.244
You've hit kubia-rc-xlq4p
root@kubia-rc-qlrp9:/# curl http://kubia-rc
You've hit kubia-rc-qqq7m
root@kubia-rc-qlrp9:/# curl http://kubia-rc.parth-test-2
You've hit kubia-rc-qqq7m
root@kubia-rc-qlrp9:/# curl http://kubia-rc.parth-test-2.svc.cluster.local
You've hit kubia-rc-qqq7m
root@kubia-rc-qlrp9:/# cat /etc/resolv.conf 
search parth-test-2.svc.cluster.local svc.cluster.local cluster.local us-west1-a.c.modified-wonder-329603.internal c.modified-wonder-329603.internal google.internal
nameserver 10.120.0.10
options ndots:5
```
You can hit your service by using the service’s name as the hostname in the requested URL. You can omit the namespace and the svc.cluster.local suffix because of how the DNS resolver inside each pod’s container is configured. Look at the /etc/resolv.conf file in the container above and you’ll understand

#### Service endpoints

```
kdscr svc kubia-rc       
Name:              kubia-rc
Namespace:         parth-test-2
Labels:            <none>
Annotations:       cloud.google.com/neg: {"ingress":true}
Selector:          app=kubia-rc
Type:              ClusterIP
IP:                10.120.0.244
Port:              <unset>  80/TCP
TargetPort:        8080/TCP
Endpoints:         10.116.0.6:8080,10.116.1.6:8080,10.116.2.4:8080
Session Affinity:  None
Events:            <none>
pa6105074@mothership: k8s-in-action git:(master) ✗ kg endpoints kubia-rc
NAME       ENDPOINTS                                         AGE
kubia-rc   10.116.0.6:8080,10.116.1.6:8080,10.116.2.4:8080   23h
```
Endpoints is a list of IP addresses and ports exposing a SVC. Although the pod selector is defined in the SVC spec, its not used directly when redirecting incoming connections. Instead the selector is used to build a list of IPs and Ports which is then stored as endpoints

When a client connects to a service the service proxy selects one of the IPs and Ports and redirects requests to the server listening on that location

#### Manually configuring service endpoints
If you create a service without a pod selector, then k8s will not create the endpoints to you and you have to create them manually like so
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
ports:
- port: 80
---
apiVersion: v1
kind: Endpoints #The name of the endpoint must match the name of the service
metadata:
  name: external-service
subsets:
  - addresses:
    - ip: 11.11.11.11
    - ip: 22.22.22.22
    ports:
    - port: 80
```

if you later decide to migrate the service within pods in the cluster in stead of using an external service like so; you can add a selector to your service thus making them auto

#### Creating an alias for an external service
In stead of going all manual in adding endpoints related to a svc. You can also use FQDN to reach to the external service. For this you need to create a service resource with the type set to ExternalName
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
  type: ExternalName
  externalName: someapi.somecompany.com
  ports:
  - port: 80
```
After this service is created pods can connect to this by connecting to external-service.default.svc.cluster.local domain name. This hides the actual service name within the cluster.

ExternalName services are implemeneted solely at the DNS level - a simple CNAME DNS record is created for the service. Therefore, clients connecting to the service will connect to the external service directly, bypassing the service proxy completely. For this reason, these types of services don’t even get a cluster IP.

**NOTE:**  A CNAME record points to a fully qualified domain name instead of a numeric IP address.

#### Exposing Services to External Clients
Ways to expose your services externally:

- Setting the service type to NodePort—For a NodePort service, each cluster node opens a port on the node itself and redirects traffic received on that port to the underlying service. The service isn’t accessible only at the internal cluster IP and port, but also through a dedicated port on all nodes.
- Setting the service type to LoadBalancer, an extension of the NodePort type. This makes the service accessible through a dedicated load balancer, provisioned from the cloud infrastructure Kubernetes is running on. The load balancer redirects traffic to the node port across all the nodes. Clients connect to the service through the load balancer’s IP.
- Creating an Ingress resource, a radically different mechanism for exposing multiple services through a single IP address. It operates at the HTTP level (network layer 7) and can thus offer more features than layer 4 services can. Details later
  
##### Using a NodePort service

This just involves telling the cluster to reserve a port on every node and the external client that connects to that port will redirect traffic to the app. Take a look at the manifest.

Not so good for multicluster nodes as routing can get complicated and would still need a good load balancer. Plus only one service per port and ports are limited to 30000 to 32767

##### Using a Loadbalancer service

Mostly highly supported on cloud services. In an Environment without this service, a Loadbalancer service would just act like a NodePort service. Check manifests

With this guy, you will always hit the same pod everytime. Reason being that until a connection is not closed, the session is maintained on a web browser when compared to lets say a curl request where a new connection is opened everytime. 

BTW loadbalancers just use some randomly assigned ports making them a NodePort service too.

##### Understanding the peculiarity of external connections

When an external client connects to a service through the node port the randomly chosen pod may or may not be running on the same node that received the connection. An additional network hop would then be required to reach the pod. You can prevent this additional hop by configuring the service to redirect external traffic to only the pods running on the same node that received the connection. This is done by setting the externalTrafficPolicy to Local in the service's spec field.

Usually, when clients inside the cluster connect to a service, the pods backing the service can obtain the client’s IP address. But when the connection is received through a node port, the packets’ source IP is changed, because Source Network Address Translation (SNAT) is performed on the packets.
The backing pod can’t see the actual client’s IP, which may be a problem for some applications that need to know the client’s IP. In the case of a web server, for example, this means the access log won’t show the browser’s IP.
The Local external traffic policy described in the previous section affects the pres- ervation of the client’s IP, because there’s no additional hop between the node receiv- ing the connection and the node hosting the target pod (SNAT isn’t performed).

#### Exposing services externally through an Ingress resource

Each Loadbalancer service requires its own load balancer with its own public IP. While an ingress just requires just one resource even when providing access to dozens of services
When a client sends an HTTP request to the ingress. the host and path in the request determine which service the request is forwarded to

Ingresses operate at the App layer of the network stack and can provide features such as cookie based session affinity

##### Understanding the requirements of an IngressController

To make ingress resources work an ingress controller needs to be running within the cluster. different distros have different levels of ingress controller like GKE uses its own HTTP load balancing features to provide ingress functionality

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kubia
spec:
  rules:
  - host: kubia.example.com # this ingress maps this domain name to your service
http: paths:
      - path: /
        backend:
          serviceName: kubia-nodeport # all requests will be sent to port 80 of the kubia-nodeport service
          servicePort: 80
```

This defines an ingress with a single rule which makes sure that all HTTP requests received by the ingress controller, in which the host kubia.example.com is requested, will be sent to kubia-nodeport service on port 80

NOTE Ingress controllers on cloud providers (in GKE, for example) require the Ingress to point to a NodePort service. But that’s not a requirement of Kubernetes itself.

To access your service through http://kubia.example.com, you’ll need to make sure the domain name resolves to the IP of the Ingress controller.
To look up the IP, you need to list Ingresses:
```
$ kubectl get ingresses
NAME      HOSTS               ADDRESS          PORTS     AGE
kubia     kubia.example.com   192.168.99.100   80        29m
```
NOTE When running on cloud providers, the address may take time to appear, because the Ingress controller provisions a load balancer behind the scenes.
The IP is shown in the ADDRESS column.

**ENSURING THE HOST CONFIGURED IN THE INGRESS POINTS TO THE INGRESS’ IP ADDRESS**
Once you know the IP, you can then either configure your DNS servers to resolve kubia.example.com to that IP or you can add the following line to /etc/hosts (or C:\windows\system32\drivers\etc\hosts on Windows):
        192.168.99.100    kubia.example.com

##### Understanding how ingresses work

Client first performs a local DNS lookup and understands the external IP to hit. The DNS server thus returns the IP of the ingress controller. The client then sends an HTTP request to the ingress controller and specified the domain name in the header. The controller then determines which service the client is trying to hit, it then looked up the pods IP through the Endpoints object associated with the service, and forwarded the client's request to one of the pods.

##### Exposing multiple services thorugh the same ingress
**MAPPING DIFFERENT SERVICES TO DIFFERENT PATHS OF THE SAME HOST**
```yaml
...
  - host: kubia.example.com
    http: paths:
      - path: /kubia # requests to kubia.example.com/kubia will be routed to kubia service and the to /foo will be routed to bar service
        backend:
          serviceName: kubia
          servicePort: 80
      - path: /foo
        backend:
          serviceName: bar
          servicePort: 80
```

In this case, requests will be sent to two different services, depending on the path in the requested URL. Clients can therefore reach two different services through a single IP address (that of the Ingress controller).

**MAPPING DIFFERENT SERVICES TO DIFFERENT HOSTS**
```yaml
spec: rules:
  - host: foo.example.com
    http:
      paths:
      - path: /
        backend:
          serviceName: foo
          servicePort: 80
  - host: bar.example.com
    http:
      paths:
      - path: /
        backend:
          serviceName: bar
          servicePort: 80
```

Similarly, you can use an Ingress to map to different services based on the host in the HTTP request instead of (only) the path, as shown in the next listing.


#### Configuring Ingress to handle TLS traffic

##### Creating a TLS cert for ingress
- When a client opens a TLS connection to the ingress controller, it terminates the TLS connection.
- The communication between the client and controller is encrypted, whereas the communication between controller and backend pod isn't
- The application running in the pod doesn't need to support TLS. For e.g: If the pods runs a web server, it can accept only HTTP traffic and let the ingress controller take care of everything related to TLS
- To enable the controller to do that, you need to attach a certificate and a private key to the ingress. The two need to be stored in a k8s secret resource, which is then referenced in the ingress manifest

##### STEPS
1. Create a private key and cert -> Create a secret to store this
```
openssl genrsa -out tls.key 2048                                                       
Generating RSA private key, 2048 bit long modulus
.....+++
.....................................+++
e is 65537 (0x10001)
pa6105074@mothership: services git:(master) ✗ openssl req -new -x509 -key tls.key -out tls.cert -days 360 -subj /CN=kubia.example.com
pa6105074@mothership: services git:(master) ✗ kubectl create secret tls tls-secret --cert=tls.cert --key tls.key
```

After this is done apply ingress-http.yaml. Can be confirmed as shown below:
```
curl -v -k https://kubia.example.com
*   Trying 34.102.190.238...
* TCP_NODELAY set
* Connected to kubia.example.com (34.102.190.238) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/cert.pem
  CApath: none
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to kubia.example.com:443 
* Closing connection 0
curl: (35) LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to kubia.example.com:443
```
Ingress resources at the time of writing of the book, only support HTTP/HTTPS load balancing, support for L4 load balancing coming soon. Gotta check if its here or not