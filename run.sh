#!/bin/bash
set -eo pipefail

HOME=${HOME:-/opt/app}

retries=${RETRY_LIMIT:-10};
SONARQUBE_URL=${SONARQUBE_URL:-http://localhost:9000}
SETTINGS_PROPERTIES_PATH=${SETTINGS_PROPERTIES_PATH:-"${HOME}/settings/settings.properties"}

function postSetting() {
    local key=$1
    local value=$2
    echo "Updating setting: '${key}'"
    status=$(curl -s -o /dev/null -w "%{http_code}" -XPOST "${SONARQUBE_URL}/api/settings/set?key=${key}&value=${value}" --user admin:${ADMIN_PASSWORD})
    echo "Response Status: ${status}"
}

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
echo "Waiting for 10 seconds ..."
sleep 10s

# Update admin password
echo "Updating Admin Password for SonarQube"
pw_status=$(curl -s -o /dev/null -w "%{http_code}" -XPOST --user admin:admin  \
    "${SONARQUBE_URL}/api/users/change_password?login=admin&previousPassword=admin&password=${ADMIN_PASSWORD}")

echo "Response Status: ${pw_status}"
echo ""

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
        postSetting ${key} ${value}
    done
fi

# Explicitly set OIDC props from env varaibles
if [ ! -z "${OIDC_CLIENT_ID}" ];
then 
    postSetting "sonar.auth.oidc.clientId.secured" ${OIDC_CLIENT_ID}
fi

if [ ! -z "${OIDC_CLIENT_SECRET}" ];
then 
    postSetting "sonar.auth.oidc.clientSecret.secured" ${OIDC_CLIENT_SECRET}
fi

echo "Sleeping for Inifinity"
sleep infinity