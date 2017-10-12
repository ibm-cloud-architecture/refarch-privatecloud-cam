#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: bash offboard_cam.sh cam-hostname-or-ipaddress"
    echo ""
    echo "       cam-hostname-or-ipaddress      CAM hostname or IP address"
    echo ""
    echo "       e.g., bash offboard_cam.sh cam-proxy"
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

CAM_HOST_URL="https://$CAM_HOST:30000"

CURL_CMD="curl -k -s"
GET_REQ="-X GET"
POST_REQ="-X POST"
DELETE_REQ="-X DELETE"
HEADER_CONTENT_TYPE_JSON="Content-Type: application/json"
HEADER_ACCEPT_JSON="Accept: application/json"

RESPONSE=response.txt
HEADERS=headers.txt

# Cleanup all generated files
cleanup() {
   rm -f $HEADERS $RESPONSE
}

# 1. Offboard LDAP Directory...

echo ""
echo "Offboard LDAP Directory..."

OFFBOARD_LDAP_URL="$CAM_HOST_URL/orpheus/tenant/api/v1/cam/api/v1/directory/ldap/offboardDirectory"

cleanup
$CURL_CMD $POST_REQ --header "$HEADER_CONTENT_TYPE_JSON" --header "$HEADER_ACCEPT_JSON" -D $HEADERS -o $RESPONSE $OFFBOARD_LDAP_URL
status=$?
echo "Response:"
cat $RESPONSE
echo ""
status=$(cat $HEADERS | head -n 1 | awk '{print $2}')
echo "Status: $status"

cleanup
