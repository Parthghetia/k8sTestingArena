htpasswd -c -b -B ./htpasswd test test123

#to create a new file and add a user to be used for htpasswd auth

oc create secret generic localusers --from-file ./htpasswd

#to create a new secret from an existing htpasswd file

oc extract secret/localusers --to=./ --confirm

#to extract a secret to an existing htpasswd file to edit the contents of the secrets on the cluster

htpasswd -b ./htpasswd parth parth

#add to an existing htpasswd file that you may have extracted

oc set data secret/localusers --from-file ./htpasswd

#to set the old secret that you editted earlier into the cluste