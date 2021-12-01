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