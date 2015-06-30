FROM tomcat:7

# Download zip file and decompress into /usr/src
# TODO: Allow changing version, but keep in mind the .properties file is related to the version
RUN \
    curl -SL http://sourceforge.net/projects/jasperserver/files/JasperServer/JasperReports%20Server%20Community%20Edition%206.1.0/jasperreports-server-cp-6.1.0-bin.zip -o /tmp/jasperserver.zip && \
    unzip /tmp/jasperserver.zip -d /usr/src/ && \
    mv /usr/src/jasperreports-server-cp-6.1.0-bin /usr/src/jasperreports-server && \
    rm -rf /tmp/*

# Install JDK and set JAVA_HOME to prepare for js-ant build
RUN apt-get update && apt-get install -y -q openjdk-7-jdk && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/

# TODO: Allow using different db backends for open source
COPY postgresql_master.properties /usr/src/jasperreports-server/buildomatic/default_master.properties

# Only build the webapp part, the DB should be done separately before running container using db-initialization.sh
# (see README)
RUN cd /usr/src/jasperreports-server/buildomatic && ./js-ant deploy-webapp-ce

# Use an entrypoint to do env var to DB setting translation
COPY entrypoint.sh /
COPY db-initialize.sh /usr/local/bin/db-initialize.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["catalina.sh", "run"]
