FROM websphere-liberty:microProfile

# Install opentracing usr feature
USER 0
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -t 10 -x -nd -P /opt/ibm/wlp/usr https://repo1.maven.org/maven2/net/wasdev/wlp/tracer/liberty-opentracing-zipkintracer/1.0/liberty-opentracing-zipkintracer-1.0-sample.zip \
    && cd /opt/ibm/wlp/usr \
    && unzip liberty-opentracing-zipkintracer-1.0-sample.zip \
    && rm liberty-opentracing-zipkintracer-1.0-sample.zip \
    && apt-get purge --auto-remove -y unzip \
    && apt-get purge --auto-remove -y wget \
    && rm -rf /var/lib/apt/lists/* \
    && chown -R 1001:0 /opt/ibm/wlp/usr/extension
USER 1001

COPY --chown=1001:0 /target/liberty/wlp/usr/servers/defaultServer /config/
COPY --chown=1001:0 src/main/liberty/config/server.xml /config/server.xml
COPY --chown=1001:0 /src/main/liberty/config/jvmbx.options /config/jvm.options
COPY --chown=1001:0 target/acmeair-mainservice-java-2.0.0-SNAPSHOT.war /config/apps/

# Don't fail on rc 22 feature already installed
RUN installUtility install --acceptLicense defaultServer || if [ $? -ne 22 ]; then exit $?; fi