PROXY_IP=169.45.207.217

function create_log_pv {
	echo Creating log PV
	kubectl delete pv d-10	
	kubectl delete pv cam-logs-nfs
	kubectl create -f cam_install/cam/pre-install/cam-logs-pv.yaml 
}

function create_db_pv {
	echo Creating DB PV
	kubectl delete pv d-11
	kubectl delete pv cam-mongo-nfs
	kubectl create -f cam_install/cam/pre-install/cam-mongo-pv.yaml 
}

function delete_log_pvc {
	echo Deleting log PVC
	kubectl delete pvc cam-logs-nfs
}


function create_log_pvc {
	echo Deleting PVC
	delete_log_pvc
	echo Creating log PVC
	kubectl create -f cam_config/cam_log_pvc.yaml	
}

function wait_for_create_dirs_completion {
	while [ $(kubectl get job | grep create-log-dirs | awk '{print $3}') -ne "1" ]
	do
		echo Waiting for create dirs job
		sleep 1
	done
}

function deploy_create_log_dirs {
	echo Creating log directories
	cd cam_config
	./deploy_create_log_dirs.sh
	cd ..
}

function deploy_cam {
	echo Deploing CAM
	cd cam_install
	helm install --name cam --set host.ip=$PROXY_IP --set license=accept cam
	cd ..
}

function wait_for_deployments {
	kubectl get deploy |grep cam- | awk '{print $4}' | grep -v 1
	while [ $? == 0 ]
	do
		echo Waiting for deployments to complete
		kubectl get deploy |grep cam- | awk '{print $4}' | grep -v 1
	done
}

function onboard_cam {
	./cam_install/cam/scripts/onboard_cam.sh $PROXY_IP cam cam_config/ldap.env
}

function load_contents {
	kubectl exec -n cam $(kubectl get -n cam pods | grep proxy | sed 's/[ ].*//g') \
	/usr/src/app/camlibrary/importTemplatesToCatalog.sh $PROXY_IP testuser testuser
}

function display_message {
    echo "================"
	echo Congratulations!
	echo CAM is available at https://$PROXY_IP:30000
	echo user:testuser, pwd: testuser
	echo Have fun!
}

./create_namespace.sh cam 

# No need to create specific PVs
## create_log_pv
## create_db_pv

create_log_pvc
deploy_create_log_dirs
wait_for_create_dirs_completion
deploy_cam
wait_for_deployments
onboard_cam
display_message

# No need to load contents
## load_contents