FROM ubuntu:17.10
MAINTAINER Fabian Stäber, fabian@fstab.de

ENV LAST_UPDATE=2018-01-20

RUN apt-get update && \
    apt-get upgrade -y

# Tools necessary for installing and configuring Ubuntu

RUN apt-get install -y \
    apt-utils \
    locales \
    tzdata

# Timezone

RUN echo "Europe/Berlin" | tee /etc/timezone && \
    ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Locale with UTF-8 support

RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && \
    locale-gen && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Basic tools

RUN apt-get install -y \
    curl \
    git \
    netcat \
    telnet \
    sudo \
    tmux \
    unzip \
    vim

# Java development

RUN cd /opt && \
    curl --silent --location --cookie "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz && \
    tar xfz jdk-8u161-linux-x64.tar.gz && \
    curl --silent -O http://ftp.fau.de/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz && \
    tar xfz apache-maven-3.5.2-bin.tar.gz

ENV JAVA_HOME=/opt/jdk1.8.0_161
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV MAVEN_HOME=/opt/apache-maven-3.5.2
ENV PATH="$MAVEN_HOME/bin:$PATH"

# Go development

RUN apt-get install -y golang

# User fabian

RUN adduser --disabled-login --gecos '' fabian
RUN echo "fabian ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER fabian
WORKDIR /home/fabian
RUN echo 'set -o vi' >> /home/fabian/.bashrc
RUN echo 'unbind C-b' >> /home/fabian/.tmux.conf && \
    echo 'set -g prefix C-a' >> /home/fabian/.tmux.conf && \
    echo 'setw -g mode-keys vi' >> /home/fabian/.tmux.conf && \
    echo 'set-option -g history-limit 8000' >> /home/fabian/.tmux.conf

# ---------------- FOSDEM 2018 | tools --------------------------------------

RUN mkdir tools
WORKDIR /home/fabian/tools

# grok_exporter

USER root
RUN apt-get install -y libonig-dev
USER fabian

RUN mkdir /home/fabian/go
ENV GOPATH=/home/fabian/go
ENV PATH=$GOPATH/bin:$PATH
RUN go get github.com/fstab/grok_exporter && \
    cd $GOPATH/src/github.com/fstab/grok_exporter && \
    git submodule update --init --recursive

# Blackbox exporter

RUN curl -sLO https://github.com/prometheus/blackbox_exporter/releases/download/v0.11.0/blackbox_exporter-0.11.0.linux-amd64.tar.gz && \
    tar xfz blackbox_exporter-0.11.0.linux-amd64.tar.gz
ENV PATH=/home/fabian/tools/blackbox_exporter-0.11.0.linux-amd64:$PATH

# JMX exporter

RUN git clone https://github.com/prometheus/jmx_exporter.git && \
    cd jmx_exporter && \
    mvn clean verify

# Promagent

RUN git clone https://github.com/fstab/promagent.git && \
    cd promagent/promagent-framework && \
    mvn clean install && \
    cd ../promagent-example && \
    mvn clean package && \
    cd ..

# ---------------- FOSDEM 2018 | demo --------------------------------------

RUN mkdir demo
WORKDIR /home/fabian/demo

# Legacy Java application

COPY --chown=fabian:fabian legacy-java-application /home/fabian/demo/legacy-java-application
RUN cd legacy-java-application && \
    mvn clean verify && \
    cd ..
EXPOSE 8080
EXPOSE 9999

# Logfile example

COPY --chown=fabian:fabian logfile-example /home/fabian/demo/logfile-example
RUN ln -s $GOPATH/src/github.com/fstab/grok_exporter/logstash-patterns-core/patterns/ logfile-example/patterns
EXPOSE 9144

# Blackbox example

COPY --chown=fabian:fabian blackbox-example/blackbox.yml /home/fabian/demo/blackbox-example/blackbox.yml
COPY --chown=fabian:fabian blackbox-example/print-url.sh /home/fabian/demo/blackbox-example/print-url.sh
EXPOSE 9115

# JMX example

COPY --chown=fabian:fabian jmx-exporter/tomcat.yml /home/fabian/demo/jmx-exporter/tomcat.yml
EXPOSE 1234

# Promagent example

COPY --chown=fabian:fabian promagent-example /home/fabian/demo/promagent-example
EXPOSE 9300

# ---------------- FOSDEM 2018 | slides --------------------------------------

RUN mkdir /home/fabian/slides
WORKDIR /home/fabian/slides
USER root
RUN apt-get install -y patat
USER fabian
COPY --chown=fabian:fabian slides/presentation.md /home/fabian/slides/presentation.md
COPY --chown=fabian:fabian slides/show-slides.sh /home/fabian/slides/show-slides.sh

# -----------------------------------------------------------------------------

WORKDIR /home/fabian
CMD /usr/bin/tmux
