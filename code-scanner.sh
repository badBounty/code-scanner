#! /bin/bash

if [[ $1 == "--path" && $2 != "" && $3 == "--name" && $4 != "" && $5 == "--tech" && $6 != "" ]]; then
    PATH_TO_REPO="$2"
    REPO_NAME="$4"
    REPO_TECH="$6"
else
    echo "Error: Path mal especificado "
    exit 1;
fi

DOJO_PATH_TO_UPLOADER= #path where dojo-uploader.py is located
DOJO_API_KEY= #defect-dojo apikey

SONAR_URL= #SonarQube url + port
SONAR_API_KEY= #SonarQube apikey


echo "This will scan your local repository on $PATH_TO_REPO, with name $REPO_NAME"

echo "----------------------------------"

echo "Semgrep Scan:"
echo "Running docker..."
docker run --rm -v $PATH_TO_REPO:/src -v $PATH_TO_REPO/../results:/results returntocorp/semgrep semgrep \
	--config=auto --output /results/$REPO_NAME-semgrep.json --json
echo "Uploading results to DefectDojo..."
python3 $PATH_TO_UPLOADER --host "127.0.0.1:8080" --api_key $API_KEY --engagement_id 5 --product_id 1 --lead_id 1 --environment "Production" --result_file "$PATH_TO_REPO/../results/$REPO_NAME-semgrep.json" --scanner "Semgrep JSON Report"

echo "----------------------------------"

echo "Trufflehog Scan:"
echo "Running docker..."
docker run --rm -it -v $PATH_TO_REPO:/src -v $PATH_TO_REPO/../results:/results trufflesecurity/trufflehog \
    filesystem -j /src | tail -n +1 | > $PATH_TO_REPO/../results/$REPO_NAME-trufflehog.json
python3 $PATH_TO_UPLOADER --host "127.0.0.1:8080" --api_key $API_KEY --engagement_id 5 --product_id 1 --lead_id 1 --environment "Production" --result_file "$PATH_TO_REPO/../results/$REPO_NAME-trufflehog.json" --scanner "Trufflehog Scan"


echo "----------------------------------"

echo "SonarQube Scan:"
echo "Running docker..."
docker run  --network=host \
    --rm \
    -e SONAR_HOST_URL= $SONAR_URL \
    -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=$REPO_NAME" \
    -e SONAR_LOGIN=$SONAR_API_KEY \
    -v "$PATH_TO_REPO:/usr/src" \
    sonarsource/sonar-scanner-cli

echo "----------------------------------"

echo "RetireJS Scan:"
echo "NPM install:"
cd $PATH_TO_REPO && npm install
echo "Running docker..."
docker run --rm -it -v $PATH_TO_REPO:/src -v $PATH_TO_REPO/../results:/results retire \
	--path /src --outputformat json --outputpath /results/$REPO_NAME-retirejs.json
python3 $PATH_TO_UPLOADER --host "127.0.0.1:8080" --api_key $API_KEY --engagement_id 5 --product_id 1 --lead_id 1 --environment "Production" --result_file "$PATH_TO_REPO/../results/$REPO_NAME-retirejs.json" --scanner "Retire.js Scan"
echo "----------------------------------"

echo "DependencyCheck Scan:"
echo "Running docker..."
docker run --rm \
    -e user=$USER \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    --volume $(pwd):/src:z \
    --volume "$PATH_TO_REPO":/usr/share/dependency-check/data:z \
    --volume $PATH_TO_REPO/../results:/results:z \
    owasp/dependency-check:latest \
    --scan /src \
    --format "XML" \
    --project "$REPO_NAME" \
    --out /results
python3 $PATH_TO_UPLOADER --host "127.0.0.1:8080" --api_key $API_KEY --engagement_id 5 --product_id 1 --lead_id 1 --environment "Production" --result_file "$PATH_TO_REPO/../results/dependency-check-report.xml" --scanner "Dependency Check Scan"

