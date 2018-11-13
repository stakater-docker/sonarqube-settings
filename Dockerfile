FROM stakater/base-centos:7

ARG HOME="/opt/app"

ENV HOME=${HOME} \
    SONARQUBE_URL="http://localhost:9000" \
    RETRY_LIMIT=20 \
    SETTINGS_PROPERTIES_PATH="${HOME}/settings/settings.properties" \
    ADMIN_PASSWORD="admin" \
    OIDC_CLIENT_ID="" \
    OIDC_CLIENT_SECRET=""

ADD ./run.sh ${HOME}
RUN mkdir -p ${HOME}/settings

CMD [ "/bin/bash", "-c" ]
ENTRYPOINT [ "/opt/app/run.sh" ]