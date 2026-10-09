$ErrorActionPreference = 'Stop'
docker start takeo-de-env
docker exec takeo-de-env service ssh start
docker exec takeo-de-env service mysql start
docker exec takeo-de-env mkdir -p /home/takeo/ravi-iphone-project/logs /home/takeo/ravi-iphone-project/data /home/takeo/ravi-iphone-project/sql
foreach($folderName in @('data','sql')) {
    docker cp "$PSScriptRoot/$folderName/." "takeo-de-env:/home/takeo/ravi-iphone-project/$folderName/"
}
foreach($fileName in @('pipeline.py','env.sh','start-services.sh','PROJECT_INFO.txt','README.md','PROJECT_REPORT.md')) {
    docker cp "$PSScriptRoot/$fileName" "takeo-de-env:/home/takeo/ravi-iphone-project/$fileName"
}
docker exec takeo-de-env chown -R takeo:takeo /home/takeo/ravi-iphone-project
docker exec -u takeo takeo-de-env bash /home/takeo/ravi-iphone-project/start-services.sh
Write-Host 'Course services started. Consult README.md for pipeline and evidence commands.'
