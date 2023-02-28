# container, checking container running
docker container ls
# OR
docker ps
# stop container
docker container stop ${CONTAINER_ID}
# OR
docker stop ${CONTAINER_ID}
# remove container
docker rm ${CONTAINER_ID}
# OR
docker container rm ${CONTAINER_ID}

# Volume
mkdir data
docker run -it -p 27017:27017 -v $(pwd)/data:/data/db --name mongo -d mongo

# Network
docker network create common
docker run -it --name sv1 --network common -d alpine
docker run -it --name sv2 --network common alpine sh
ping sv1