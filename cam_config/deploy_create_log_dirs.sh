echo Deploying create_log_dirs
kubectl delete job create-log-dirs
kubectl create -f create_log_dirs.yaml
