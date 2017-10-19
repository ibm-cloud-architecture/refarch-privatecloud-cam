# Deploying IBM Cloud Automation Manager in ICP

This tutorial shows to deploy IBM Cloud Automation Manager in ICP.

*We assume that kubectl has been configured to interact with your ICP environment*

* First download the scripts from this github repository:

```
git clone https://github.com/patrocinio/refarch-privatecloud-applications.git
cd refarch-privatecloud-applications
```

* Then define the variable PROXY_IP according to your environment:

```
export PROXY_IP=<your proxy IP>
```

## Deploy LDAP

Before we install CAM, we need to install an LDAP server:

* Run the script `deploy_ldap.sh`

* You will see a message like this at the end:

```
LDAP admin available at http://169.55.86.200:31080/
user: cn=admin,dc=local,dc=io, pwd: admin
```

## Deploy CAM

* Edit the file `deploy_cam.sh` to change the variable `PROXY_IP` according to your environment

* Run the script `deploy_cam.sh`

* You will see a message similar to this one at the end:

```
================
Congratulations!
CAM is available at https://<PROXY_IP>:30000
user:testuser, pwd: testuser
Have fun!
```




