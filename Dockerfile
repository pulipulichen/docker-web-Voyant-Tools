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

CMD [ "java", "-Djava.awt.headless=true", "-Dfile.encoding=UTF-8", "-jar", "VoyantServer.jar", "headless=true" ]

EXPOSE 8888

# For Colab
COPY ./docker-build/console.sh /console.sh
COPY ./docker-build/startup.sh /startup.sh
ENV LOCAL_PORT=8888
ENV LOCAL_VOLUMN_PATH=/opt