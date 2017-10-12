if [[ $# -lt 1 ]]; then
    echo "Usage: cleanup.sh <CAM IP>"
    echo ""
    echo "       e.g., cleanup.sh 9.5.37.xx"
    echo ""
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/offboard_cam.sh $1

echo helm del cam
helm del cam --purge

echo "Waiting for Pods to terminate"
kubectl -n cam get pod
#mycmd="kubectl -n cam get pods | grep -"
pods=$(kubectl -n cam get pods | grep -)
while [ "${pods}" ]; do
        sleep 2
        kubectl -n cam get pod
        pods=$(kubectl -n cam get pods | grep -)
        #echo $pods
done
echo "All pods terminated"

echo kubectl delete pv cam-logs-nfs
kubectl delete pv cam-logs-nfs

echo kubectl delete pv cam-mongo-nfs
kubectl delete pv cam-mongo-nfs