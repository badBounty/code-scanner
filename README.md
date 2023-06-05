# code-scanner
Code-scanner consta de una serie de contenedores en docker que se ejecutan de manera secuencial para el análisis de código fuente localmente. Una vez finalizado cada scan, su correspondiente output sera enviado a "DefectDojo"(siempre y cuando el formato del output sea soportado).

Actualmente este script utiliza las siguientes tools para el análisis de repositorios localmente:

- Semgrep
- Trufflehog
- SonarQube
- RetireJS
- DependencyCheck
- trivy

Por tecnologia:

nodejs:
- njsscan
- bearer
- npm audit

dotnet: 
- puma
- security code scan
- PVS-Studio

java: 
- findsecbugs

php: 
- PHPStan
- enlightn
- composer
- ASST
- phpcs-security-audit



## DefectDojo
DefectDojo es un projecto open-source el cual nos permite visualizar de una manera ordenada los findings en los diferentes repositorios que se scanneen.

Este servicio debera encontrarse en ejecucion antes de realizar cualquier scan.

Asi mismo, debera crearse un producto (normalmente con el nombre del cliente) y diferentes engagements (con los nombres de los repositorios a analizar y su branch). Estos nos otorgaran un engagementid y un productid el cual deberemos indicar (por el momento) en el script de bash.

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
Mientras el setup.sh no se encuentre operacional, por el momento debemos:
- Descarga de imagenes de herramientas y/o buildeado
- Configurar defect-dojo
- SonarQube debe estar funcionandoo (ya que se ejecuta desde consola pero con el servicio levantado)
- Configurar constantes en code-scanner file
- Crear engagement en defectdojo (solo la primera vez)
- Clonar repo a analizar y hacer el cambio de branch de ser necesario
- Utilizar code scan indicando los parametros necesarios
- Ver resultados en defect-dojo

## TODO
- scans por tecnologia utilizada (in process)
- integracion con SonarQube (resultados solo se ven en la GUI de SonarQube)

## Bugs/Not-working
- Trufflehog -> no muestra findings en defectdojo
- Setup.sh no funciona (revisar steps)
- si el sonarqube no levanta, probar con esto: sysctl -w vm.max_map_count=262144 (se debe tirar en cada reboot del sistema)
- Algunos output no se estan subiendo a defectdojo