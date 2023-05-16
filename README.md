# code-scanner
Code-scanner consta de una serie de contenedores en docker que se ejecutan de manera secuencial para el analisis de codigo fuente localmente. Una vez finalizado cada scan, su correspondiente output sera enviado a "DefectDojo".

## DefectDojo
DefectDojo es un projecto open-source el cual nos permite visualizar de una manera ordenada los findings en los diferentes repositorios que se scaneen.
Este servicio debera encontrarse en ejecucion antes de realizar cualquier scan.
Asi mismo, debera crearse un engagement (normalmente con el nombre del cliente) y diferentes productos (con los nombres de los repositorios a analizar). Estos nos otorgaran un engagementid y un productid el cual deberemos indicar (por el momento) en el script de bash.

Mas informacion en:
- https://github.com/DefectDojo/django-DefectDojo


## Quick start
./code-scanner.sh --path /path/to/local/repo --name "repoName" --tech "tech"

## TODO
- output predeterminado
- scans por tecnologia utilizada
- integracion con SonarQube (resultados solo se ven en la GUI de SonarQube)
- eliminacion de codigo fuente una vez analizado (para que no mate el espacio)

## Bugs/Not-working
- Trufflehog -> no muestra findings en defectdojo