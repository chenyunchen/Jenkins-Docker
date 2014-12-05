FROM ubuntu:14.04
MAINTAINER Alex Sanz <asans@evirtualpost.com>

# First, let us install Jenkins - as per https://github.com/cloudbees/jenkins-docker
RUN apt-get update
RUN echo deb http://pkg.jenkins-ci.org/debian binary/ >> /etc/apt/sources.list
RUN apt-get install -y wget curl git
RUN wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN apt-get update
# installs the newest jenkins version
RUN apt-get install -y jenkins

# now we install docker in docker - thanks to https://github.com/jpetazzo/dind
# We install existing host docker version into our docker in docker container
RUN echo deb http://archive.ubuntu.com/ubuntu precise universe > /etc/apt/sources.list.d/universe.list
RUN apt-get update -qq
RUN apt-get install -qqy iptables ca-certificates lxc
ADD https://get.docker.io/builds/Linux/x86_64/docker-latest /usr/local/bin/docker
ADD wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/docker /usr/local/bin/wrapdocker
RUN docker -v | cat > .version

# expose the port
EXPOSE 8080
# required to make docker in docker to work
VOLUME /var/lib/docker

# default jenkins home directory
ENV JENKINS_HOME /var/jenkins
# set our user home to the same location
ENV HOME /var/jenkins

CMD wrapdocker && java -jar /usr/share/jenkins/jenkins.war
