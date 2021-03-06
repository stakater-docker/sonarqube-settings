# SonarQube Settings 
Dockerfile for image to POST sonarqube settings via sonarqube web API

API Reference: https://sonarqube.bordeaux.inria.fr/sonarqube/web_api/api/settings


## How to Run

Mount a directory containing settings.properties to /opt/app/settings.
```
    docker run -v /sonar-settings/:/opt/app/settings stakater/sonarqube-settings
```
Alternatively you can mount the directory having properties file with any name on any path inside the container by updating the enviornment variable SETTINGS_PROPERIES_PATH. 

### Sensitive Properties
Secret properties such as passwords and secrets are set explicitly from Enviornment variables instead of the properties file. There details are mentioned in the section below.

Currently supported : `ADMIN_PASSOWRD`, `OIDC_CLIENT_ID` & `OIDC_CLIENT_ID`

##Environment variables:

`SONARQUBE_URL`: URL of SonarQube (default: `http://localhost:9000`)

`RETRY_LIMIT`: Number of tries, with a 3 second interval, to connect to SonarQube before failing (default: `20`)

`ADMIN_PASSWORD`: New password for SonarQube `admin` user (default: `admin`)

`SETTINGS_PROPERTIES_PATH`: Path to the settings properties file from which properties are read and posted to sonarqube  (default: `${HOME}/settings/settings.properties`)

`OIDC_CLIENT_ID`: Client ID for OpenID Connect

`OIDC_CLIENT_SECRET`: Client Secret for OpenID Connect

## Example sonar.properties file

```
sonar.core.serverBaseUrl=https://sonarqube.org
sonar.someProperty=someValue
```