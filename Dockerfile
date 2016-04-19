FROM alpine
MAINTAINER Kyle Rich <kyle.rich@dealertrack.com>

ENV MAVEN_VERSION 3.3.9

RUN apk update && \
    apk upgrade && \
    apk add openjdk7 \
            ca-certificates \
            openssl \
            ttf-dejavu \
            graphviz \
            git && \
    rm -rf /var/cache/apk/*
RUN find /usr/share/ca-certificates/mozilla/ -name "*.crt" -exec keytool -import -trustcacerts \
    -keystore /usr/lib/jvm/java-1.7-openjdk/jre/lib/security/cacerts -storepass changeit -noprompt \
    -file {} -alias {} \; && \
    keytool -list -keystore /usr/lib/jvm/java-1.7-openjdk/jre/lib/security/cacerts --storepass changeit
RUN wget http://apache.cs.utah.edu/maven/maven-3/"$MAVEN_VERSION"/binaries/apache-maven-"$MAVEN_VERSION"-bin.tar.gz -O - | tar xzv && \
    mv apache-maven-"$MAVEN_VERSION" /usr/lib/mvn

ENV JAVA_HOME /usr/lib/jvm/java-1.7-openjdk
ENV JAVA=$JAVA_HOME/bin
ENV M2_HOME=/usr/lib/mvn
ENV M2=$M2_HOME/bin
ENV PATH $PATH:$JAVA_HOME:$JAVA:$M2_HOME:$M2

WORKDIR /opt/plantuml-server
RUN git clone https://github.com/plantuml/plantuml-server.git .
RUN mvn install
RUN mvn jetty:help

EXPOSE 8080
ENTRYPOINT ["mvn", "jetty:run"]
