k port-forward kuard 8080:8080

# command above is used to expose a deployment endpoint like lets say nginx to be able to access it locally
 
k config set-context --current --namespace=parth-test

# how to change namespaces using kubectl could also use kubens - much faster

kubectl label deployments alpaca-test "canary=true"

# labelling anything

kubectl get deployments -L canary

# self explanatory

kubectl label deployments alpaca-test "canary-"

#self-explanatory

kubectl get pods --selector="app=alpaca"

#show objects with certain labels

kubectl get pods --selector="app=bandicoot,ver=2"

#only the objects that satisfy both will be returned. This is a logical AND operation

kubectl get deployments --selector='!canary'

#asking if a key, in this case canary, is not set can look like

kubectl get pods -l 'ver=2,!canary'

# you can combine positive and negative selectors together as follows
