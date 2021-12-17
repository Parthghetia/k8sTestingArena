- [Build a simple node app and package it using Docker](#build-a-simple-node-app-and-package-it-using-docker)
- [Stuff to check after](#stuff-to-check-after)
- [Pushing an image to the docker registry or any other registries](#pushing-an-image-to-the-docker-registry-or-any-other-registries)


Build a simple node app and package it using Docker
==================
Run the following command to build the app
```
docker build -t kubia .
```
You then need to run this command to run the container

```
docker run --name kubia-container -p 8080:8080 -d kubia
```
-d means detached from the console and the container will run in the background

To check whether your stupid app is running

```
curl -v -k localhost:8080*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#0)
> GET / HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.64.1
> Accept: */*
> 
< HTTP/1.1 200 OK
< Date: Wed, 01 Dec 2021 02:13:51 GMT
< Connection: keep-alive
< Transfer-Encoding: chunked
< 
You've hit 662c4bac66f8
* Connection #0 to host localhost left intact
* Closing connection 0
```
Getting more information about a container

```
docker inspect kubia-container
[
    {
        "Id": "662c4bac66f8dac5740043fa5b9cfb6ebffba9bedbab6c45fc1a0b3bcb666aef",
        "Created": "2021-12-01T02:11:54.423280023Z",
        "Path": "node",
        "Args": [
            "app.js"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 35337,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2021-12-01T02:11:54.840139761Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:b8f13909a40d6c784541a4d8413cc7bafadce38f86dd73abcac96aa31e2dae0f",
        "ResolvConfPath": "/var/lib/docker/containers/662c4bac66f8dac5740043fa5b9cfb6ebffba9bedbab6c45fc1a0b3bcb666aef/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/662c4bac66f8dac5740043fa5b9cfb6ebffba9bedbab6c45fc1a0b3bcb666aef/hostname",
        "HostsPath": "/var/lib/docker/containers/662c4bac66f8dac5740043fa5b9cfb6ebffba9bedbab6c45fc1a0b3bcb666aef/hosts",
        "LogPath": "/var/lib/docker/containers/662c4bac66f8dac5740043fa5b9cfb6ebffba9bedbab6c45fc1a0b3bcb666aef/662c4bac66f8dac5740043fa5b9cfb6ebffba9bedbab6c45fc1a0b3bcb666aef-json.log",
        "Name": "/kubia-container",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {
                "8080/tcp": [
                    {
                        "HostIp": "",
                        "HostPort": "8080"
                    }
                ].............
```

You can go into the container and check stuff as below
```
docker exec -it kubia-container bash 
```
The -it option is shorthand for two options:
-i, which makes sure STDIN is kept open. You need this for entering com- mands into the shell.
-t, which allocates a pseudo terminal (TTY).

Stuff to check after
==================
Listing processes from inside a container
```
root@662c4bac66f8:/# ls
app.js  bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@662c4bac66f8:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  1.2 813608 25832 ?        Ssl  02:11   0:00 node app.js
root        13  0.0  0.1  20252  3216 pts/0    Ss   02:18   0:00 bash
root        21  0.0  0.0  17508  2028 pts/0    R+   02:19   0:00 ps aux
```
If you now open another terminal and list the processes on the host OS itself, you will, among all other host processes, also see the processes running in the container.
```
ps aux | grep app.js
pa6105074        39126   0.0  0.0  4399480    816 s002  R+    9:21PM   0:00.00 grep --color=auto --exclude-dir=.bzr --exclude-dir=CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn --exclude-dir=.idea --exclude-dir=.tox app.js
```
This proves that processes running in the container are running in the host OS. If you have a keen eye, you may have noticed that the processes have different IDs inside the container vs. on the host. The container is using its own PID Linux namespace and has a completely isolated process tree, with its own sequence of numbers.



You then need to stop the container using
```
docker stop kubia-container
```
Stopping itself is not enough. You can still see the stuff when you do docker ps -a

You need to remove the container truly using

```
docker rm kubia-container
```
Best command to remove them all stopped containers

```
docker container prune
```

Pushing an image to the docker registry or any other registries
================
You need to re-tag your image according to docker hub rules
```
docker tag kubia parthghetia/kubia
```
Do a docker images and you'll see them both with the same id
```
docker images | grep kubia 
kubia                                                                 latest                                                  b8f13909a40d   47 minutes ago   660MB
parthghetia/kubia                                                     latest                                                  b8f13909a40d   47 minutes ago   660MB
```
Go ahead and do docker login
Then docker push parthghetia/kubia

That's it. Your image should be now publicly available, Which you can get to using

```
docker run -p 8080:8080 -d parthghetia/kubia
```
