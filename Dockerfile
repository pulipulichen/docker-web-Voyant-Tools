#
# Dockerfile for Voyant Tools server
#
# FROM openjdk:23-slim-bullseye
FROM tomcat:9-jre11

RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV VOYANT_ZIP_URL https://github.com/voyanttools/VoyantServer/releases/download/2.6.13/VoyantServer2_6_13.zip
# https://github.com/voyanttools/VoyantServer/releases/download/2.6.13/VoyantServer2_6_13.zip
ENV VOYANT_DIR /opt/VoyantServer

# Install wget and unzip

# Create directory for VoyantServer
RUN mkdir -p $VOYANT_DIR

RUN echo $VOYANT_ZIP_URL

# Download, unzip, and rename VoyantServer
RUN wget $VOYANT_ZIP_URL -O /tmp/VoyantServer.zip
RUN    unzip /tmp/VoyantServer.zip -d /tmp && \
    mv /tmp/VoyantServer*/* $VOYANT_DIR && \
    rm /tmp/VoyantServer.zip && \
    rm -r /tmp/VoyantServer*

WORKDIR /opt/VoyantServer

EXPOSE 8888

# For docker-web & Colab default
COPY ./docker-build/console.sh /console.sh
COPY ./docker-build/startup.sh /startup.sh
CMD ["bash", "/startup.sh"]

# For docker-web & Colab customize
ENV LOCAL_PORT=8888

# For docker-web & Colab in docker-compose-template.yml
ENV STARTUP_COMMAND="java -Djava.awt.headless=true -Dfile.encoding=UTF-8 -jar VoyantServer.jar headless=true"
ENV LOCAL_VOLUMN_PATH=/data
ENV SERVER_DEFAULT_URI=/
