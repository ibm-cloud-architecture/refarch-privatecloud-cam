function deploy_ldap {
	echo Deploying LDAP chart
	helm repo add cnct http://atlas.cnct.io
#	helm delete --purge ldap
	helm install --name ldap cnct/openldap
}

function wait_for_available {
	while [ $(kubectl get deploy | grep -v admin | awk '{print $5}') -eq 0 ]
	do
		echo Waiting for LDAP server...
		sleep 1
	done
}

./create_namespace.sh ldap

deploy_ldap

USER="cn=admin,dc=local,dc=io"
PASSWORD=admin

echo Testing connection
POD_ID=$(kubectl get po | grep ldap | grep -v admin | awk '{print $1}')
echo Pod: $POD_ID

kubectl exec $POD_ID -- ldapsearch -x -h localhost -b dc=local,dc=io -D "$USER" -w $PASSWORD

echo Copying file
kubectl cp ldap_config/default.ldif $POD_ID:/container/service/slapd/assets/test/

echo Importing LDIF
kubectl exec $POD_ID --  ldapadd -x -h localhost -D "$USER" -w $PASSWORD -f /container/service/slapd/assets/test/default.ldif

echo Testing user
kubectl exec $POD_ID -- ldapsearch -x -LLL -D "$USER" -w $PASSWORD -b "uid=testuser,ou=people,dc=local,dc=io" -s sub "(objectClass=person)" uid

echo ==========================
echo 
echo LDAP admin available at http://$PROXY_IP:31080/
echo user: $USER, pwd: $PASSWORD
