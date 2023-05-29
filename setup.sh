#! /bin/bash

docker build .
docker-compose up -d

git clone https://github.com/DefectDojo/django-DefectDojo.git

./django-DefectDojo/dc-build.sh

docker-compose logs initializer | grep "Admin password:"

./django-DefectDojo/dc-up.sh