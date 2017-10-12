# Make sure we have kube configured and we can see the cam namespace
if [ ! $KUBECONFIG  ]; then
  if [ -f ~/admin.conf ]; then
    export KUBECONFIG=~/admin.conf
  fi
fi

list=(
  cam-auth-service
  cam-catalog
  cam-iaas
  cam-identity-mgmt
  cam-orchestration
  cam-portal-api
  cam-portal-ui
  cam-proxy
  cam-service-composer-api
  cam-service-composer-ui
  cam-tenant-api
  cam-ui-basic
  cam-ui-connections
  cam-ui-instances
  cam-ui-templates
  provider-terraform-local
)

for ((i=0; i<${#list[@]}; i++)); do
  CONTAINER=$(kubectl get -n cam pods | grep ${list[$i]} | sed 's/[ ].*//g')
  VERSION=$(kubectl exec -n cam $CONTAINER -- cat /usr/src/app/VERSION)
  echo $VERSION   ${list[$i]}
done


