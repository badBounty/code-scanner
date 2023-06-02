# code-scanner
Code-scanner consta de una serie de contenedores en docker que se ejecutan de manera secuencial para el analisis de codigo fuente localmente. Una vez finalizado cada scan, su correspondiente output sera enviado a "DefectDojo".

Tecnologias soportadas:
- nodejs
- dotnet
- java 
- php

## DefectDojo
DefectDojo es un projecto open-source el cual nos permite visualizar de una manera ordenada los findings en los diferentes repositorios que se scaneen.
Este servicio debera encontrarse en ejecucion antes de realizar cualquier scan.
Asi mismo, debera crearse un engagement (normalmente con el nombre del cliente) y diferentes productos (con los nombres de los repositorios a analizar). Estos nos otorgaran un engagementid y un productid el cual deberemos indicar (por el momento) en el script de bash.

Mas informacion en:
- https://github.com/DefectDojo/django-DefectDojo


## Quick start
Este script se encargara de buildear las imagenes necesarias para la utilizacion de esta herramienta. 
Nos devolvera la contraseña de admin de defect-dojo:

```
./setup.sh
```
Primero que nada se deberan modificar las variables de entorno de code-scanner.sh (api key de dojo, sonarqube, puertos usados etc)
Luego:

```
./code-scanner.sh -t <tech> -s /path/to/local/repo -o /path/to/results -e <engagement>
```

## STEPS
(Gran parte se hace de manera automatica, pero ante fallas...)
- Descarga de imagenes de herramientas y/o buildeado
- Configurar defect-dojo
- SonarQube debe estar funcionandoo (ya que se ejecuta desde consola pero con el servicio levantado)
- configurar constantes en code-scanner file
- Clonar repo a analizar
- Utilizar code scan indicando los parametros necesarios
- Ver resultados en defect-dojo

## TODO
- scans por tecnologia utilizada (working)
- integracion con SonarQube (resultados solo se ven en la GUI de SonarQube)
- crear un start.sh que deje activos los contenedores de dojo y sonarqube para poder scanear (first release, need to be tested)

## Bugs/Not-working
- Trufflehog -> no muestra findings en defectdojo
- Aca otro error, el setup.sh no funciona
- si el sonarqube no levanta, probar con esto: sysctl -w vm.max_map_count=262144 (se debe tirar en cada reboot del sistema)