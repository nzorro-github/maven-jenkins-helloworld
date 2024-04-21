FROM ubuntu:latest

RUN apt update -y && apt install -y default-jdk

WORKDIR /opt
ADD https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.20/bin/apache-tomcat-10.1.20.tar.gz .
RUN tar -xvzf apache-tomcat-10.1.20.tar.gz
RUN mv apache-tomcat-10.1.20 tomcat

COPY ./*.war  /opt/tomcat/webapps/
 
EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]
