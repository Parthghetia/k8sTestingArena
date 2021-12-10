# Elasticsearch stuff - Cluster Logging OCP

## Components

1. LogStore
- Stores the logs into indices
- Provides RBAC access to logs
- Provides data redundancy
  
2. Log Collection
- Implemented with Fluentd, collector collects node and application logs, adds pod and namespace metadata, and stores them in the logstore
- Collector is a DS (fluentd) on each node
  
3. Visualization -> Kibana
4. Event Routing
- Event router monitors the Openshift events API and sends the events to STDOUT so the collector can forward them to the logStore. Events from Openshift are stored in the infra index in Elasticsearch

## Installing the Elasticsearch Operator

- Handles the creation of and update to the Elasticsearch cluster based on the Cluster Logging CR
- Each node in the Elasticsearch cluster is deployed with a PVC. A unique deployment is created for each Elasticsearch node to ensure that each Elasticsearch node has a storage volume of its own
- Try to use another NS apart from the openshift-operators. To avoid conflict

### Steps to Install Elasticsearch Operator
1. Create a namespace e.g. openshift-logging for this purpose (namespace.yaml)
2. Create an Operator Group object to install the operator in all namespaces and a Subcription object to subscribe the namespace to the operator (operatorGroup.yaml; subscription.yaml)
3. Create RBAC objects to grant permission to Prometheus to access the openshift-logging namespace (rbac.yaml)
4. Verify that the operator is available in each namespace as follows:
```
oc get csv -A
-> Output redacted too long. But you will see the elasticsearch operator as succeeded in every NS
```

### Installing the ClusterLogging Operator

This creates components detailed in the cluster logging custom resource, and updates deployment upon any changes to the custom resource. This operator requires the same resource as the one above (clusterLoggingOperator.yaml)

Confirm the installation
```
oc get csv -n openshift-logging
NAME                                        DISPLAY                            VERSION              REPLACES                                    PHASE
clusterlogging.4.6.0-202111191944           Cluster Logging                    4.6.0-202111191944   clusterlogging.4.6.0-202110262229           Succeeded
elasticsearch-operator.4.6.0-202111191944   OpenShift Elasticsearch Operator   4.6.0-202111191944   elasticsearch-operator.4.6.0-202110262229   Succeeded
```

### Deploying a ClusterLogging instance
Defines config of an instance of the cluster logging components and provides the config for the components

##### Configuring Elasticsearch
- For availability and scalability -> 3 cluster nodes; master, client, data. Additional nodes are provisioned as data nodes with client and data roles
  
- Elasticsearch uses persistent or ephemeral storage. Use fast storage like SSD or dedicated local storage in stead of NFS, SMB or Amazon EBS. Consider logging requirements of the application in the cluster and size of Openshift node when sizing storage of elasticsearch
  
- Redundancy policy determines how Elasticsearch shards are replicated across data nodes in the cluster. Several Elasticsearch shards combine to make a single Elasticsearch index. Each shard is responsible for a subset of data that an Elasticsearch index provides.

**-> NOTES TO KNOW WHEN CONFIGURING THE REDUNDANCY POLICY**
1. FullRedundancy -> Elasticsearch copies the shards for each index to every data node in the cluster. Fully replicated shards provide the most redundancy to protect from accidental data loss.
2. MultipleRedundancy -> The primary shards for each index are replicated to half of the data nodes. This provides a good balance between performance and redundancy
3. SingleRedundancy -> Each primary shard is copied once to another node. If at least two data nodes remain available, then the logs are recoverable. If the Elasticsearch cluster has 5 or more nodes, SingleRedundancy performs better than MultipleRedundancy.
4. ZeroRedundancy -> Shards are not replicated. Data loss could happen if a node fails

Use the clusterLoggingInstance.yaml to deploy the clusterLogging instance. To confirm use this command
```
oc get clusterlogging -n openshift-logging instance -o yaml apiVersion: logging.openshift.io/v1
kind: ClusterLogging
...output omitted...
status:
  collection:
    logs:
      fluentdStatus:
        daemonSet: fluentd
        ...output omitted...
```
### Installing the Event Router
The event router monitors the events API and prints events to standard output so Fluentd can collect them and send them to Elasticsearch. Elasticsearch stores this in the infra index
To install the Event Router:
• Download the template from OpenShift Container Platform documentation.
• Use the oc process command to create a manifest file for the Event Router.
• Use the oc apply command to apply the manifest resources to the OpenShift cluster.

### Creating Kibana Index Patterns

Every log message is convrted into JSON that ES stores in an index.
ES uses indexes to organize stuff, and applies RBAC rules to indexes based on OCP permission. Prefixes include:
1. infra- -> this prefix stores pod logs for infra projects. These are projects with name openshift- or kube- prefix
2. app- -> An index with this prefix stores pod log messages for all projects except infrastructure projects
3. audit- -> This stores audit log messages. This allow you to view the Openshift API activity of a user, admin or Component such as a service account


To search for log messages in Kibana, you specify an index pattern, this defines a set of Elasticsearch indexes that you use in a query. An index pattern simplifies an ES query because logs might exist in different indices

**NOTE**
The first time you log in to Kibana, you must create the Kibana index patterns. Red Hat recommends that you create an index pattern for each of preceding Elasticsearch indexes:
infra
Create this index pattern to match any of the infra-* Elasticsearch indexes.
app
Create this index pattern to match any of the app-* Elasticsearch indexes.
audit
Create this index pattern to match any of the audit-* Elasticsearch indexes.
