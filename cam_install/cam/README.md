[//]: # (Licensed Materials - Property of IBM)
[//]: # (\(C\) Copyright IBM Corp. 2017. All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)

# Cloud Automation Manager Helm Chart
IBM Cloud Automation Manager is a cloud management solution on IBM Cloud private (ICp) for deploying cloud infrastructure in multiple clouds with an optimized user experience. Cloud Automation Manager uses open source Terraform to manage and deliver cloud infrastructure as code. Cloud infrastructure delivered as code is reusable, able to be placed under version control, shared across distributed teams, and it can be used to easily replicate environments. 

The Cloud Automation Manager content library comes pre-populated with sample templates to help you get started quickly. Use the sample templates as is or customize them as needed.  A Chef runtime environment can also be deployed using CAM for more advanced application configuration and deployment.  

With Cloud Automation Manager, you can provision cloud infrastructure and accelerate application delivery into IBM Cloud, Amazon EC2, VMware vSphere, and VMware NSXv cloud environments with a single user experience.

You can spend more time building applications and less time building environments when cloud infrastructure is delivered with automation. You are able to get started fast with pre-built infrastructure from the Cloud Automation Manager library.

# Requirements
## Hardware requirements:
CAM may consume additional resources on top of ICp depending on its usage.   You may want to allocate more resources to ICp than the minimum ICp hardware requirements.

## ICp Namespace
* A namespace in ICp is required to install CAM (e.g. "cam")

## Persistant Volumes (25GB total)
Two persistant volumes (PVs) are required to store CAM DB and CAM log data
* 15 GB Persistant Volume for CAM DB
* 10 GB Persistant Volume for CAM Logs
* Note: The persistant volumes need to be created prior to the CAM install.

## LDAP requirements:
* You must have LDAP to authenticate to Cloud Automation Manager. 
Note: You can configure Cloud Automation Manager with only one LDAP directory at any point in time.

## Internet connectivity required:
* Internet connectivity must be available during the CAM install process to retrieve docker container images from Docker Hub, and for deployments that require internet connectivity including IBM Cloud, AWS, Azure. The automated setup of a Chef runtime environment using CAM also requires internet connectivity. 

## Other release notes:
* You can configure Cloud Automation Manager with only one tenant. The tenant is defined during the onboarding process. 
* Role-based access control is not implemented in this release of Cloud Automation Manager. All users have the same access privileges.
* As CAM is currently a beta there is no upgrade path to new versions. Future versions will require a new install.  
* Cloud connection fields (including passwords) cannot contain any of the following special characters < > | % & ; # [ ]

# Installation Prerequisites
## 1) Download the CAM chart tgz which includes initialization scripts and sample kube yamls:
On the same machine where you have the ICp master node installed
* Download the cam-0.1.0.tgz: 
  * https://w3-01.ibm.com/marketing/automation/iwm/preview/web/preLogin.do?source=swerpcl-cam-2
* Extract the tgz
  * `tar -xvf cam-0.1.0.tgz`

## 2) Create a namespace in ICp
### Using the ICp UI
System > Organization > Namespaces > New Namespace
enter a namespace name e.g. "cam"
### or using the helm CLI (sample in the cloned helm chart repository)
* `kubectl create -f ./cam/pre-install/namespace.yaml`

## 3) Setup ICp persistant volumes for CAM DB and CAM Logs
### Using ICp UI
Navigate to Infrastructure > Storage > Persistant Volume > Create Persistant Volume and create the following two entries:
* 1) CAM DB 
```Name: cam-mongo-nfs
Capacity: 15
Unit: Gi (default)
Access Mode: ReadWriteMany
Add the following two key/value pairs:
  key: server  value: <your PV ip> e.g. the master node IP if the PV is on your master node
  key: path   value: <your PV path> e.g. /export/CAM_db
  ```
* 2) CAM Logs 
```Name: cam-logs-nfs
Capacity: 10
Unit: Gi (default)
Access Mode: ReadWriteMany
Add the following two key/value pairs:
  key: server  value: <your PV ip> e.g. the master node IP if the PV is on your master node
  key: path   value: <your PV path>  e.g. /export/CAM_logs
  ```

### or using the kubectl CLI (samples in the cloned helm chart repository)
Edit the following two yaml files to add your PV ip and path
* 1)  Example of creating a _dummy_ PV for the CAM DB
```kind: PersistentVolume
apiVersion: v1
metadata:
  name: cam-mongo-nfs
  namespace: cam
spec:
  capacity:
    storage: 15Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: <nfs server ip>
    path: <your path e.g. /export/CAM_db>

kubectl create -f ./cam/pre-install/cam-mongo-pv.yaml
```

* 2) Example of creating a _dummy_ PV for the CAM Logs
```kind: PersistentVolume
apiVersion: v1
metadata:
  name: cam-logs-nfs
  namespace: cam
spec:
  capacity:
    storage: 10Gi
  accessModes:
    -  ReadWriteMany
  nfs:
    server: <nfs server ip>
    path: <your path e.g. /export/CAM_logs>

kubectl create -f ./cam/pre-install/cam-logs-pv.yaml
```

## 4) Create log directories in the persistant volume
On the server where you have created the persistant volume, or have mounted the persistant volume, run the following command
* `./cam/scripts/logs_dir_creation.sh <path for CAM logs>`
* for example `./cam/scripts/logs_dir_creation.sh /export/CAM_logs`


# Install CAM helm chart

## Using helm install CLI
Invoke the helm install command, passing in your parameters:
* `helm install --name cam --namespace <namespace> --set host.ip=<ICp_proxy_IP> --set license=accept cam`

## You can optionally monitor the install and pod deployment with this command:
* `kubectl get -n cam pods`
```
root@myhost:~# kubectl get -n cam pods
NAME                             READY     STATUS              RESTARTS   AGE
a8-controller-g2b8k              0/1       ContainerCreating   0          3s
a8-registry-98jt6                0/1       Pending             0          3s
cam-auth-service-90fsx           0/1       Pending             0          3s
cam-catalog-jmhcs                0/1       ContainerCreating   0          3s
cam-iaas-zw28k                   0/1       Pending             0          3s
cam-identity-mgmt-qwm1d          0/1       ContainerCreating   0          3s
cam-mongo-95nj5                  0/1       Pending             0          3s
cam-orchestration-27565          0/1       Pending             0          2s
cam-portal-api-n3b48             0/1       ContainerCreating   0          3s
cam-portal-ui-bw4qv              0/1       ContainerCreating   0          4s
cam-proxy-mq1vh                  0/1       Pending             0          2s
cam-service-composer-api-d4v7m   0/1       Pending             0          2s
cam-service-composer-ui-s9r36    0/1       ContainerCreating   0          4s
cam-tenant-api-grk1f             0/1       Pending             0          3s
cam-ui-basic-sdvpg               0/1       Pending             0          2s
cam-ui-connections-c6mhh         0/1       Pending             0          2s
cam-ui-instances-s9n79           0/1       Pending             0          2s
cam-ui-templates-8n8nb           0/1       ContainerCreating   0          4s
provider-terraform-local-brpzl   0/1       Pending             0          3s
redis-7wt0m                      0/1       Pending             0          2s
```

Note: Once the helm install command completes, the CAM UI should be available on the same IP as ICp, however you will need to configure LDAP in the next step before logins will work:
* `https://<CAM_IP_address>:30000`

# Post install steps
## 1) Configure CAM with an LDAP server
Run the `onboard_cam.sh` passing the CAM IP, an LDAP configuration file, and a tenant name:
* e.g. `./cam/scripts/onboard_cam.sh <CAM_IP_address> cam ./cam/scripts/openLdap_config.env`

## 2) Install default content (e.g. sample templates in the Library -> Templates section)
Run the following command to load the content which resides on the proxy container
* `kubectl exec -n cam $(kubectl get -n cam pods | grep proxy | sed 's/[ ].*//g') /usr/src/app/camlibrary/importTemplatesToCatalog.sh <CAM_IP_address> <username> <password>`

## 3) Installation complete
Access your UI at the following location
* `https://<CAM_IP_address>:30000`


# Uninstall CAM helm chart
## Offboard the LDAP
It is recommend you first offboard the LDAP using the following command (if you want to reuse the DB for a future CAM install)
* `/cam/scripts/offboard_cam.sh <CAM_IP_address>`

## Using helm del cli
* `helm del cam --purge`

## -or- using a script that offboards LDAP and does a helm delete
Offboard LDAP configuration and delete the CAM Helm chart
* `./cam/scripts/cleanup.sh <CAM_IP_address>`

## Cleaning the database (optional)
If you have persistence enabled, you should be able to keep the database from one deploy to the next.  If you
want to wipe the database clean, then on the PV, delete everything under the /export/CAM_db directory
* `rm -Rf /export/CAM_db/*`

# Upgrade CAM
At the moment we do not have an official upgrade path.  However, if you follow the uninstall steps above without cleaning the database, you can then re-create your PVs and then re-deploy the helm chart. Once the environment is running again, you need to run the onboard script again to re-configure CAM with LDAP.
