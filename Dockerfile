FROM websphere-liberty:microProfile2
# Install opentracing usr feature
USER 0
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -t 10 -x -nd -P /opt/ibm/wlp/usr https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.3/liberty-opentracing-zipkintracer-1.3-sample.zip \
    && cd /opt/ibm/wlp/usr \
    && unzip liberty-opentracing-zipkintracer-1.3-sample.zip \
    && rm liberty-opentracing-zipkintracer-1.3-sample.zip \
    && apt-get purge --auto-remove -y unzip \
    && apt-get purge --auto-remove -y wget \
    && rm -rf /var/lib/apt/lists/* \
    && chown -R 1001:0 /opt/ibm/wlp/usr/extension
USER 1001

#COPY with chown to support liberty non-root default user account. This option supported only docker version >= 17.09
#Liberty docker image doc (https://hub.docker.com/_/websphere-liberty/)
COPY --chown=1001:0 /target/liberty/wlp/usr/servers/defaultServer /config/
COPY --chown=1001:0 src/main/liberty/config/server.xml /config/server.xml
COPY --chown=1001:0 /src/main/liberty/config/jvmbx.options /config/jvm.options
COPY --chown=1001:0 target/acmeair-mainservice-java-2.0.0-SNAPSHOT.war /config/apps/

# https://github.com/WASdev/ci.docker/#enterprise-functionality
ARG HTTP_ENDPOINT=true
ARG MP_MONITORING=true
RUN configure.sh 
