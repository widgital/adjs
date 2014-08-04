FROM ubuntu:14.04
MAINTAINER Afsheen Bigdeli <afsheen@adjs.io>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update 
RUN apt-get install -y curl build-essential git zip libyaml-dev libpcre3-dev 
RUN apt-get clean


RUN mkdir -p /var/www/adjs && cd /var/www/adjs && git init . && git remote add origin git@github.com:adjs/adjs.git
WORKDIR /var/www/adjs
ADD . /var/www/adjs/
RUN git config --global user.name "Deploy User"
RUN git config --global user.email "no-reply@adjs.io"
RUN git pull --depth=1 origin master

RUN sudo apt-get -y install nodejs npm
RUN ln -s /usr/bin/nodejs /usr/bin/node 
RUN  /bin/bash -l -c 'cd /var/www/adjs/ && sudo npm install' 
RUN npm install -g bower grunt-cli karma-cli watchify karma gulp cake envify json browserify uglify-js aws-sdk
RUN  /bin/bash -l -c 'cd /var/www/adjs/ && npm install -g' 
RUN  /bin/bash -l -c 'cd /var/www/adjs/ && npm install json' 
WORKDIR /var/www/adjs
CMD /bin/bash -c "git pull origin master && ls -la ."
