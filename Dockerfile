FROM stakater/base-centos:7

ARG HOME="/opt/app"

ENV HOME=${HOME} \
    SONARQUBE_URL="http://localhost:9000" \
    RETRY_LIMIT=10 \
    SETTINGS_PROPERTIES_PATH="${HOME}/settings/settings.properties" \
    ADMIN_PASSWORD="admin"


ADD ./run.sh ${HOME}
RUN mkdir -p ${HOME}/settings

CMD [ "/bin/bash", "-c" ]
ENTRYPOINT [ "/opt/app/run.sh" ]