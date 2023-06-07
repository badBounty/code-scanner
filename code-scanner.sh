#! /bin/bash

if [[ $1 == "-t" && $2 != "" && $3 == "-s" && $4 != "" && $5 == "-o" && $6 != "" && $7 == "-e" && $8 != "" ]]; then
    REPO_TECH="$2"
    PATH_TO_REPO="$4"
    PATH_TO_OUTPUT="$6"
    DOJO_ENG="$8"
else
    echo "Error: argumentos mal especificados"
    exit 1;
fi

DOJO_PATH_TO_UPLOADER= #path where dojo-uploader.py is located
DOJO_API_KEY= #defect-dojo apikey
DOJO_PRODUCT_ID= #Product ID

SONAR_URL= #SonarQube url + port
SONAR_API_KEY= #SonarQube apikey
REPO_NAME=$(basename "$PATH_TO_REPO")


echo "This will scan your local repository on $PATH_TO_REPO, with name output in $PATH_TO_OUTPUT for $REPO_NAME"

echo "----------------------------------"

echo "Semgrep Scan:"
echo "Running docker..."

docker run --rm -v $PATH_TO_REPO:/src -v $PATH_TO_OUTPUT:/results returntocorp/semgrep semgrep \
	--config=auto --output /results/$REPO_NAME-semgrep.json --json

echo "Uploading results to DefectDojo..."

python3 $DOJO_PATH_TO_UPLOADER --host "127.0.0.1:8080" --api_key $DOJO_API_KEY --engagement_id $DOJO_ENG --product_id $DOJO_PRODUCT_ID --lead_id 1 --environment "Production" --result_file "$PATH_TO_OUTPUT/$REPO_NAME-semgrep.json" --scanner "Semgrep JSON Report"

echo "----------------------------------"
 
echo "Trufflehog Scan:"
echo "Running docker..."

docker run --rm -it -v $PATH_TO_REPO:/src trufflesecurity/trufflehog \
    filesystem -j /src > $PATH_TO_OUTPUT/$REPO_NAME-trufflehog.json

python3 $DOJO_PATH_TO_UPLOADER --host "127.0.0.1:8080" --api_key $DOJO_API_KEY --engagement_id $DOJO_ENG --product_id $DOJO_PRODUCT_ID --lead_id 1 --environment "Production" --result_file "$PATH_TO_OUTPUT/$REPO_NAME-trufflehog.json" --scanner "Trufflehog Scan"


echo "----------------------------------"

echo "SonarQube Scan:"
echo "Running docker..."

docker run  --network=host \
    --rm \
    -e SONAR_HOST_URL="http://localhost:9000" \
    -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=$REPO_NAME" \
    -e SONAR_LOGIN=$SONAR_API_KEY \
    -v "$PATH_TO_REPO:/usr/src" \
    sonarsource/sonar-scanner-cli

echo "----------------------------------"

echo "RetireJS Scan:"
echo "NPM install:"

cd $PATH_TO_REPO && npm install
echo "Running docker..."

docker run --rm -it -v $PATH_TO_REPO:/src -v $PATH_TO_OUTPUT:/results retire \
	--path /src --outputformat json --outputpath /results/$REPO_NAME-retirejs.json

python3 $DOJO_PATH_TO_UPLOADER --host "127.0.0.1:8080" --api_key $DOJO_API_KEY --engagement_id $DOJO_ENG --product_id $DOJO_PRODUCT_ID --lead_id 1 --environment "Production" --result_file "$PATH_TO_OUTPUT/$REPO_NAME-retirejs.json" --scanner "Retire.js Scan"

echo "----------------------------------"

echo "DependencyCheck Scan:"
echo "Running docker..."

docker run --rm \
    -e user=$USER \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    --volume $(pwd):/src:z \
    --volume "$PATH_TO_REPO":/usr/share/dependency-check/data:z \
    --volume $PATH_TO_OUTPUT:/results:z \
    owasp/dependency-check:latest \
    --scan /src \
    --format "XML" \
    --project "$REPO_NAME" \
    --out /results/$REPO_NAME-dependency-check-report.xml

python3 $DOJO_PATH_TO_UPLOADER --host "127.0.0.1:8080" --api_key $DOJO_API_KEY --engagement_id $DOJO_ENG --product_id $DOJO_PRODUCT_ID --lead_id 1 --environment "Production" --result_file "$PATH_TO_OUTPUT/$REPO_NAME-dependency-check-report.xml" --scanner "Dependency Check Scan"

echo "----------------------------------"

if [[ $REPO_TECH == "nodejs" ]]; then

    echo "Nodejs Scan:"
    echo "Running docker..."

    docker run --rm -it -v $PATH_TO_REPO:/src -v $PATH_TO_OUTPUT:/results opensecurity/njsscan /src --sarif -o /results/$REPO_NAME-nodejs --missing-controls

    echo "----------------------------------"

    echo "npmAudit Scan:"
    cd $PATH_TO_REPO && npm audit --json #> $PATH_TO_OUTPUT/$REPO_NAME-npmAudit.json
    #python3 $DOJO_PATH_TO_UPLOADER --host "127.0.0.1:8080" --api_key $DOJO_API_KEY --engagement_id $DOJO_ENG --product_id $DOJO_PRODUCT_ID --lead_id 1 --environment "Production" --result_file "$PATH_TO_OUTPUT/$REPO_NAME-npmAudit.json" --scanner "NPM Audit Scan"
    echo "----------------------------------"

    echo "Bearer Scan:"
    docker run --rm -v $PATH_TO_REPO:/tmp/scan -v $PATH_TO_OUTPUT:/results bearer/bearer:latest-amd64 scan /tmp/scan -f json --output /results/$REPO_NAME-bearer.json
    echo "----------------------------------"
else
    echo "error"
fi
: '    if [[ $REPO_TECH == "dotnet" ]]; then


    else
        if [[ $REPO_TECH == "java" ]]; then

        else
            if [[ $REPO_TECH == "php" ]]; then

            else 
                exit 1;
            fi
        fi
    fi
fi
'