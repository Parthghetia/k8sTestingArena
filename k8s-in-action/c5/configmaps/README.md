# What are config maps?

- K8s allows separating configuration options into a separate objects called a ConfigMap which is a map containing key/value pairs with the values ranging from short literals to full config files
- The contents of the config maps are either passed as environment variables to the containers or as volumes
  
### CREATING A CONFIGMAP ENTRY FROM THE CONTENTS OF A FILE
ConfigMaps can also store coarse-grained config data, such as complete config files. To do this, the kubectl create configmap command also supports reading files from disk and storing them as individual entries in the ConfigMap:
```
$ kubectl create configmap my-config --from-file=config-file.conf
```
When you run the previous command, kubectl looks for the file config-file.conf in the directory you run kubectl in. It will then store the contents of the file under the key config-file.conf in the ConfigMap (the filename is used as the map key), but you can also specify a key manually like this:
```
$ kubectl create configmap my-config --from-file=customkey=config-file.conf
```
This command will store the file’s contents under the key customkey. As with literals, you can add multiple files by using the --from-file argument multiple times.
CREATING A CONFIGMAP FROM FILES IN A DIRECTORY
Instead of importing each file individually, you can even import all files from a file directory:
```
$ kubectl create configmap my-config --from-file=/path/to/dir
```
In this case, kubectl will create an individual map entry for each file in the specified directory, but only for files whose name is a valid ConfigMap key.j