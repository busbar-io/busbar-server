#
# Dockerfile - Build and Setup Busbar Container
#

# Base Image
FROM ruby:2.3.1-onbuild

# Update git client
RUN echo "deb http://ftp.us.debian.org/debian/ buster main contrib non-free" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get remove -y binutils --force-yes \
    && apt-get install -t buster -y git --force-yes \
    && apt-get clean all

# Add kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/v1.16.2/bin/linux/amd64/kubectl /usr/bin/kubectl
RUN chmod a+x /usr/bin/kubectl

# Add docker
ADD https://download.docker.com/linux/static/stable/x86_64/docker-19.03.4.tgz /tmp/docker.tgz
RUN tar xf /tmp/docker.tgz -C /usr/bin --strip-components=1 && rm -f /tmp/docker.tgz

# Add Github and Bitbucket keys
RUN mkdir /root/.ssh && chmod 0700 /root/.ssh
RUN ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
RUN ssh-keyscan -t rsa bitbucket.org >> /root/.ssh/known_hosts
