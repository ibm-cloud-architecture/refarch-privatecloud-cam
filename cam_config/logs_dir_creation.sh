#/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: logs_dir_creation.sh <NFS CAM_logs directory>"
    echo ""
    echo "       e.g., logs_dir_creation.sh /export/CAM_logs"
    echo ""
    exit 1
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
  cam-ui-catalog
  cam-ui-connections
  cam-ui-instances
  cam-ui-templates
  provider-terraform-local
)

mount_point=$1

for ((i=0; i<${#list[@]}; i++)); do
echo "Creating folder ${list[$i]} and subfolders apt fsck nginx ntpstats supervisor"
    sudo mkdir ${mount_point}/${list[$i]} 
    sudo chmod 777 ${mount_point}/${list[$i]}
    sudo mkdir -p ${mount_point}/${list[$i]}/apt 
    sudo mkdir -p ${mount_point}/${list[$i]}/fsck 
    sudo mkdir -p ${mount_point}/${list[$i]}/nginx 
    sudo mkdir -p ${mount_point}/${list[$i]}/ntpstats 
    sudo mkdir -p ${mount_point}/${list[$i]}/supervisor 
    if [ -f /etc/lsb-release ]; then
        sudo chown -R nobody ${mount_point}
        sudo chgrp -R nogroup ${mount_point} 
    fi
done

