#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "Usage: bash onboard_cam.sh cam-hostname-or-ipaddress tenant-name [ ldap-env-file ]"
    echo ""
    echo "       cam-hostname-or-ipaddress      CAM hostname or IP address"
    echo "       tenant-name                    Tenant name"
    echo "       ldap-env-file                  Provide LDAP config as env file or through environment variables"
    echo ""
    echo "       e.g., bash onboard_cam.sh cam-proxy pepsi ldap_config.env"
    echo ""
    exit 1
fi

CAM_HOST=$1
ping -c 1 $CAM_HOST &> /dev/null
status=$?
if [ $status -ne 0 ]; then
    echo "Error: The CAM host $CAM_HOST is not reachable. Please check and try again."
    exit 1
fi

curl -V &> /dev/null
status=$?
if [ $status -ne 0 ]; then
    echo "Error: The 'curl' command is not installed. Please install curl and try again."
    exit 1
fi

TENANT_NAME=$2

LDAP_CONFIG_ENV=$3
# ldap_config.env
if [[ -n $LDAP_CONFIG_ENV ]]; then
    . $LDAP_CONFIG_ENV
fi

# Replace all HTML/XML special characters with their entity names
LDAP_USERFILTER=${LDAP_USERFILTER/&/&amp;}
LDAP_GROUPFILTER=${LDAP_GROUPFILTER/&/&amp;}

LDAP_USERFILTER=${LDAP_USERFILTER/</&lt;}
LDAP_GROUPFILTER=${LDAP_GROUPFILTER/</&lt;}

LDAP_USERFILTER=${LDAP_USERFILTER/>/&gt;}
LDAP_GROUPFILTER=${LDAP_GROUPFILTER/>/&gt;}

LDAP_USERFILTER=${LDAP_USERFILTER/\"/&quot;}
LDAP_GROUPFILTER=${LDAP_GROUPFILTER/\"/&quot;}

LDAP_USERFILTER=${LDAP_USERFILTER/\'/&apos;}
LDAP_GROUPFILTER=${LDAP_GROUPFILTER/\'/&apos;}


if [ -z $LDAP_ID ]; then
    echo "Error: LDAP config not provided."
    exit 1
fi

CAM_HOST_URL="https://$CAM_HOST:30000"

CURL_CMD="curl -k -s"
POST_REQ="-X POST"
HEADER_CONTENT_TYPE_JSON="Content-Type: application/json"
HEADER_ACCEPT_JSON="Accept: application/json"

RESPONSE=response.txt
HEADERS=headers.txt

# Cleanup all generated files
cleanup() {
   rm -f $HEADERS $RESPONSE
}


# Onboard LDAP directory

echo ""
echo "Onboard LDAP directory..."

# create ldap_config.json file
cat <<EOF >ldap_config.json
{
  "TYPE": "LDAP",
  "LDAP_ID": "$LDAP_ID",
  "LDAP_REALM": "$LDAP_REALM",
  "LDAP_HOST": "$LDAP_HOST",
  "LDAP_PORT": "$LDAP_PORT",
  "LDAP_IGNORECASE": "$LDAP_IGNORECASE",
  "LDAP_BASEDN": "$LDAP_BASEDN",
  "LDAP_BINDDN": "$LDAP_BINDDN",
  "LDAP_BINDPASSWORD": "$LDAP_BINDPASSWORD",
  "LDAP_TYPE": "$LDAP_TYPE",
  "LDAP_USERFILTER": "$LDAP_USERFILTER",
  "LDAP_GROUPFILTER": "$LDAP_GROUPFILTER",
  "LDAP_USERIDMAP": "$LDAP_USERIDMAP",
  "LDAP_GROUPIDMAP": "$LDAP_GROUPIDMAP",
  "LDAP_GROUPMEMBERIDMAP": "$LDAP_GROUPMEMBERIDMAP"
}
EOF

cat ldap_config.json

ONBOARD_LDAP_URL="$CAM_HOST_URL/orpheus/tenant/api/v1/cam/api/v1/directory/ldap/onboardDirectory"

isConfigured=false

cleanup
$CURL_CMD $POST_REQ --header "$HEADER_CONTENT_TYPE_JSON" --header "$HEADER_ACCEPT_JSON" -d @ldap_config.json -D $HEADERS -o $RESPONSE $ONBOARD_LDAP_URL
echo "Response:"
cat $RESPONSE
echo ""
status=$(cat $HEADERS | head -n 1 | awk '{print $2}')
echo "Status: $status"
rm -f ldap_config.json

if [ $status -eq 200 ]; then
    isConfigured=true
fi

result=$( cat $RESPONSE )
retValue=
if [[ "$result" =~ "Already Exists" ]]; then
    retValue="Already Exists"
elif [[ "$result" =~ "Success" ]]; then
    retValue="Success"
    isConfigured=true
elif [[ "$result" =~ "Status" ]]; then
    retValue=$( python -c "import sys, json;  data = json.dumps($result); print json.loads(data)[\"Status\"]" )
elif [[ "$result" =~ "status" ]]; then
    retValue=$( python -c "import sys, json; data = json.dumps($result); print json.loads(data)[\"status\"]" )
elif [[ "$result" = *error* ]]; then
    retValue=$( python -c "import sys, json;  data = json.dumps($result); print json.loads(data)[\"error\"][\"message\"]" )
elif [[ "$result" = *id* ]]; then
    retValue=$( python -c "import sys, json;  data = json.dumps($result); print json.loads(data)[\"id\"]" )
    isConfigured=true
else
    retValue=$result
fi

#echo "retValue==$retValue"

if [[ ( "$isConfigured" = true || "$retValue" == "Success" || "$retValue" == "success" ) ]]; then
    echo "Successfully onboarded the LDAP directory."
    echo "id==$retValue"
    isConfigured=true
elif [ "$retValue" == "Already Exists" ]; then
    echo "The LDAP directory already exists."
    isConfigured=true
else
    echo "Error: Failed to onboard the LDAP directory."
    isConfigured=false
    cleanup
    exit 1
fi


# Register tenant

echo ""
echo "Register tenant..."

# create tenant_config.json file
cat <<EOF >tenant_config.json
{
   "name": "$TENANT_NAME"
}
EOF

cat tenant_config.json

TENANT_REGISTER_URL="$CAM_HOST_URL/orpheus/tenant/api/v1/tenants/registerTenantOnPrem"

cleanup
$CURL_CMD $POST_REQ --header "$HEADER_CONTENT_TYPE_JSON" --header "$HEADER_ACCEPT_JSON" -d @tenant_config.json -D $HEADERS -o $RESPONSE $TENANT_REGISTER_URL
echo "Response:"
cat $RESPONSE
echo ""
status=$(cat $HEADERS | head -n 1 | awk '{print $2}')
echo "Status: $status"
rm -f tenant_config.json

if [ $status -ne 200 ]; then
  echo "Error: Failed to register tenant."
  cleanup
  exit 1
fi

cleanup
