FROM stakater/base-centos:7

ARG HOME="/opt/app"

ENV HOME=${HOME} \
    SONARQUBE_URL="http://localhost:9000" \
    RETRY_LIMIT=10 \
    SETTINGS_PROPERTIES_PATH="${HOME}/settings/settings.properties" \
    ADMIN_PASSWORD="admin" 
# TODO: Mount from secret


ADD ./run.sh ${HOME}

# TODO: mount 
RUN mkdir -p ${HOME}/settings
ADD ./settings.properties ${HOME}/settings/

CMD [ "/bin/bash", "-c" ]
ENTRYPOINT [ "/opt/app/run.sh" ]