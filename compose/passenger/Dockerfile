FROM phusion/passenger-ruby23
MAINTAINER mejelly

# Set correct environment variables.
ENV HOME /root

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs \
    ca-certificates bzip2 libfontconfig git-core wget

RUN wget -q -O /tmp/phantomjs.tar.bz2 https://assets.membergetmember.co/software/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN mkdir /tmp/phantomjs
RUN tar --strip-components=1 -C /tmp/phantomjs -xjf /tmp/phantomjs.tar.bz2
RUN mv /tmp/phantomjs/bin/phantomjs /usr/local/bin/

ADD . /mejelly
ENV APPLICATION_ROOT /mejelly
WORKDIR $APPLICATION_ROOT
RUN touch /mejelly/log/production.log
RUN chmod 664 /mejelly/log/production.log
RUN chown app. /mejelly/log/production.log
RUN bundle install

COPY compose/passenger/entrypoint.sh /entrypoint.sh
COPY compose/passenger/start-dev.sh /start-dev.sh

RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
ENV DOCKER_DIR compose/passenger
ADD $DOCKER_DIR/mejelly.conf /etc/nginx/sites-enabled/mejelly.conf
ADD $DOCKER_DIR/secret_key.conf /etc/nginx/main.d/secret_key.conf

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=TH"
RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 1024
ADD $DOCKER_DIR/self-signed.conf /etc/nginx/snippets/self-signed.conf
ADD $DOCKER_DIR/ssl-params.conf /etc/nginx/snippets/ssl-params.conf

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
