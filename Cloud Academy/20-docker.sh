sudo yum -y install docker
sudo systemctl start docker
sudo docker info

grep docker /etc/group
sudo groupadd docker

sudo groupadd docker
sudo gpasswd -a $USER docker

newgrp docker

# Docker commands
docker --help
docker system info
docker system --help

docker image --help
docker image build
docker image pull
docker image push

# Images are read-only snapshots that containers can be created from. Images are built up in layers, one image built on top of another.
# Because each layer is read-only, they can be identified with cryptographic hash values computed from the bytes of the data.
# Layers can be shared between images as another benefit of being read-only.

# When you build your own image, you will select a base image to build on top of with your custom application.
# A pull can be used to pull or download an image to your server from an image registry, while push can upload an image to a registry.

docker container --help
docker container commit

# A container is another core concept in Docker. Containers run applications or services, almost always just one per container.
# Containers run on top of an image. In terms of storage, a container is like another layer on top of the image, but the layer is writable instead of read-only.
# You can have many containers using the same image. Each will use the same read-only image and have its own writable layer on top.
# Containers can be used to create images using the commit command, essentially converting the writable layer to a read-only layer in an image.

# The relationship between images and containers aside, run is used to run a command on top of an image.
# A container can be stopped and started again. ls is used to list containers. It is aliased to ps and list as well.
# Read through the other commands in the list to see what else is available for working with containers.

docker run hello-world
docker run --name web-server -d -p 8080:80 nginx:1.12
docker ps
docker ps -a
docker stop web-server
docker start web-server
docker logs web-server
docker exec -it web-server /bin/bash
docker exec web-server ls /etc/nginx
docker search "Microsoft .NET Core"


# Python v3 base layer
FROM python:3
# Set the working directory in the image's file system
WORKDIR /usr/src/app
# Copy everything in the host working directory to the container's directory
COPY . .
# Install code dependencies in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
# Indicate that the server will be listening on port 5000
EXPOSE 5000
# Set the default command to run the app
CMD [ "python", "src/app.py" ]


docker build -t flask-content-advisor:latest .

curl ipecho.net/plain; echo

docker run --name advisor -p 80:5000 flask-content-advisor
