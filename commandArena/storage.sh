oc new-app --name postgresql-persistent --docker-image registry.redhat.io/rhel8/postgresql-13:1-7 -e POSTGRESQL_USER=redhat -e POSTGRESQL_PASSWORD=redhat123 -e POSTGRESQL_DATABASE=persistentdb

#to create a new postgresql deployment

oc set volumes deployment/postgresql-persistent --add --name postgresql-storage --type pvc --claim-class nfs-storage --claim-mode rwo --claim-size 10Gi --mount-path /var/lib/pgsql --claim-name postgresql-storage

#to create a pvc to attach to the application above