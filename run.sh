#!/bin/bash
set -eo pipefail

HOME=${HOME:-/opt/app}

retries=${RETRY_LIMIT:-10};
SONARQUBE_URL=${SONARQUBE_URL:-http://localhost:9000}
SETTINGS_PROPERTIES_PATH=${SETTINGS_PROPERTIES_PATH:-"${HOME}/settings/settings.properties"}


# Wait for SONARQUBE to start up
until $(curl -s -f -o /dev/null --connect-timeout 1 -m 1 --head "${SONARQUBE_URL}/api/server/version"); do
    echo "Waiting for SonarQube to startup ..."
    sleep 3;
    retries=$(($retries-1))
    
    if [[ ${retries} -eq 0 ]]; 
    then 
        echo "Cannot connect to Sonarqube at ${SONARQUBE_URL}: Retry limit reached";
        exit 1;
    fi
done

echo "Sonarqube running at ${SONARQUBE_URL}"

# Authenticate admin
curl -XPOST --user admin:admin "${SONARQUBE_URL}/api/authentication/login?login=admin&password=admin"

# Update admin password
echo "Updating Admin Password for SonarQube"
curl -v -XPOST --user admin:admin "${SONARQUBE_URL}/api/users/change_password?login=admin&previousPassword=admin&password=${ADMIN_PASSWORD}"

# Post settings 
if [ -f ${SETTINGS_PROPERTIES_PATH} ];
then
    echo "Posting settings from properties file to SonarQube on ${SONARQUBE_URL}"
    IFS=$'\r\n' GLOBIGNORE='*' command eval  'props=($(cat ${SETTINGS_PROPERTIES_PATH}))'
    for (( i=0; i<${#props[@]}; i++ ))
    do
        IFS='=' read -ra keyValue <<< "${props[$i]}"
        key=${keyValue[0]}
        value=${keyValue[1]}
        curl -v -XPOST --user admin:${ADMIN_PASSWORD} "${SONARQUBE_URL}/api/settings/set?key=${key}&value=${value}"
    done
fi

echo "Sleeping till Inifinity"
sleep infinity