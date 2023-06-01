#! /bin/bash

docker build .
docker-compose up -d

dotnet tool install --global security-scan --version 5.6.7

git clone https://github.com/DefectDojo/django-DefectDojo.git

./django-DefectDojo/dc-build.sh

./django-DefectDojo/dc-up.sh

docker-compose logs initializer | grep "Admin password:"