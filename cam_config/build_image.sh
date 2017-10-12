IMAGE_PATH=patrocinio/cam_create_logs

docker build -t $IMAGE_PATH .
docker push $IMAGE_PATH
