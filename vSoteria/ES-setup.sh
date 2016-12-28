sudo su

curl -o docker-compose.yml https://raw.githubusercontent.com/ErezPasternak/Shield/master/vSoteria/docker-compose.yml

curl -o run https://raw.githubusercontent.com/ErezPasternak/Shield/master/vSoteria/run

chmod 777 run

apt-get update

apt-get install docker-engine

service docker start

#Verify that docker is installed correctly by running the hello-world image.
 
docker run hello-world

curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose

chmod +x /usr/bin/docker-compose

docker login #and enter credentials: username:ericomshield1 password: Ericom98765$

./run


