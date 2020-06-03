FROM ubuntu:trusty

LABEL maintainer="Kassiel Batista <kbatista@vertigo.com.br>"
LABEL name="yara-devops-example"

RUN \
  apt-get update && \
  apt-get install -y openjdk-7-jdk && \
  rm -rf /var/lib/apt/lists/*

ARG WAR_FILE
ARG JAR_FILE

RUN useradd --create-home helloworld
ADD bin /home/helloworld/bin
ADD ${WAR_FILE} /home/helloworld/bin/helloworld.war
ADD ${JAR_FILE} /home/helloworld/bin/jetty-runner.jar

EXPOSE 8080
USER helloworld

ENTRYPOINT /home/helloworld/bin/run.sh