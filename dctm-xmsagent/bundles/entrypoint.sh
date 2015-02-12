#!/bin/sh

dockerUsage() {
    cat 2>&1 <<EOF
This container must be linked with a broker (as 'broker') server.
Something like:
  docker run -dP --name bps -h bps --link broker:broker bps
EOF
  exit 2
}

# check container links
[ -z "${BROKER_NAME}" ] && dockerUsage

CATALINA_OPTS="${CUSTOM_CATALINA_OPTS} ${CATALINA_OPTS}"
JAVA_OPTS="${CUSTOM_JAVA_OPTS} ${JAVA_OPTS}"
CATALINA_OUT="${CUSTOM_CATALINA_OUT}"

export CATALINA_OPTS JAVA_OPTS CATALINA_OUT

# configure dfc
DFC_DATADIR=${CATALINA_HOME}/temp/dfc
[ -d ${DFC_DATADIR} ] || mkdir -p ${DFC_DATADIR}

cat << __EOF__ >> ${CATALINA_HOME}/conf/dfc.properties
dfc.name=xms-agent
dfc.data.dir=${DFC_DATADIR}
dfc.tokenstorage.enable=false
dfc.docbroker.host[0]=${DOCBROKER_ADR:-$BROKER_PORT_1489_TCP_ADDR}
dfc.docbroker.port[0]=${DOCBROKER_PORT:-$BROKER_PORT_1489_TCP_PORT}
dfc.session.secure_connect_default=try_native_first
dfc.globalregistry.repository=${REGISTRY_NAME:-devbox}
dfc.globalregistry.username=${REGISTRY_USER:-dm_bof_registry}
dfc.globalregistry.password=${REGISTRY_CRYPTPWD:-AAAAEGksM99HhP8PaQO7r43ADePXDPKXd+lEei1ddxmWgnBv}
dfc.session.allow_trusted_login = false
__EOF__

echo "xcp.repository.name=${REPOSITORY_NAME}" > conf/deployment.properties

echo "DFC Config file:"
cat conf/dfc.properties

echo "Using CATALINA_OPTS:   ${CATALINA_OPTS}"
echo "Using JAVA_OPTS:       ${JAVA_OPTS}"
exec "$@"
