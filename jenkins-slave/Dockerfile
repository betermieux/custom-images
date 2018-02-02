FROM jenkins/jnlp-slave:3.16-1

USER root:staff

# Install maven 3.5.2
RUN wget http://www-eu.apache.org/dist/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz && \
    tar -zxf apache-maven-3.5.2-bin.tar.gz && \
    mv apache-maven-3.5.2 /usr/local && \
    rm -f apache-maven-3.5.2-bin.tar.gz && \
    ln -s /usr/local/apache-maven-3.5.2/bin/mvn /usr/local/bin/mvn && \
    ln -s /usr/local/apache-maven-3.5.2 /usr/local/apache-maven

COPY --chown=jenkins:jenkins settings.xml /usr/local

USER jenkins:jenkins

ENTRYPOINT ["jenkins-slave"]
