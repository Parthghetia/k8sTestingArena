oc new-app --name postgresql-persistent --docker-image registry.redhat.io/rhel8/postgresql-13:1-7 -e POSTGRESQL_USER=redhat -e POSTGRESQL_PASSWORD=redhat123 -e POSTGRESQL_DATABASE=persistentdb

#to create a new postgresql deployment

oc set volumes deployment/postgresql-persistent --add --name postgresql-storage --type pvc --claim-class nfs-storage --claim-mode rwo --claim-size 10Gi --mount-path /var/lib/pgsql --claim-name postgresql-storage

#to create a pvc to attach to the application above

htpasswd -c -b -B ./htpasswd test test123

#to create a new file and add a user to be used for htpasswd auth

oc create secret generic localusers --from-file ./htpasswd

#to create a new secret from an existing htpasswd file

oc extract secret/localusers --to=./ --confirm

#to extract a secret to an existing htpasswd file to edit the contents of the secrets on the cluster

htpasswd -b ./htpasswd parth parth

#add to an existing htpasswd file that you may have extracted

oc set data secret/localusers --from-file ./htpasswd

#to set the secret that you editted earlier into the cluster