FROM ruby:2.2.3

RUN apt-get update && apt-get install -y wget bash
RUN gem install etcd

RUN mkdir /app
WORKDIR /app

#install docker-gen
RUN wget https://github.com/jwilder/docker-gen/releases/download/0.4.0/docker-gen-linux-amd64-0.4.0.tar.gz
RUN tar xvzf docker-gen-linux-amd64-0.4.0.tar.gz -C /usr/local/bin

#install etcd
RUN wget https://github.com/coreos/etcd/releases/download/v2.2.0-rc.0/etcd-v2.2.0-rc.0-linux-amd64.tar.gz
RUN tar xzvf etcd-v2.2.0-rc.0-linux-amd64.tar.gz
RUN cp etcd-v2.2.0-rc.0-linux-amd64/etcd /usr/local/bin/etcd

# Install Forego
RUN wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego \
 && chmod u+x /usr/local/bin/forego

ADD . /app

ENV DOCKER_HOST unix:///var/run/docker.sock

CMD ["./startup"]
