list=(
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-auth-service
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-catalog
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-iaas
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-identity-mgmt
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-orchestration
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-portal-api
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-portal-ui
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-proxy
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-service-composer-api
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-service-composer-ui
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-tenant-api
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-ui-basic
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-ui-connections
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-ui-instances
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/orpheus-ui-templates
  orpheus-local-docker.artifactory.swg-devops.com/orpheus/provider-terraform-local
)

for ((i=0; i<${#list[@]}; i++)); do
  echo Checking ${list[$i]}
  images=$(docker images -q -a ${list[$i]} | awk '{if (NR!=1) {print}}')
  if [ ! -z "$images" ]; then
    docker rmi $(docker images -q -a ${list[$i]} | awk '{if (NR!=1) {print}}')
  fi
done
