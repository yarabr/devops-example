# Hello World - Java Web App

demonstrate running a .war using jetty-runner
demonstrate docker java container

# build
mvn clean package

# run
java -jar target/dependency/jetty-runner.jar target/helloworld.war

# docker
docker build -t <your username>/helloworld .
docker run -p 49160:8080 -d <your username>/helloworld