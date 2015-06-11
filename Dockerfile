FROM phusion/baseimage:0.9.16

MAINTAINER Naftuli Tzvi Kay <rfkrocktk@gmail.com>

# pin go server to a specific version because we want a consistent build for a specific
# version ONLY of Go server. if we want a later version, a new image should be produced
ENV GO_SERVER_VERSION 15.1.0-1863
ENV GO_KEY_FINGERPRINT 9A439A18CBD07C3FF81BCE759149B0A6173454C7

# install apt repository for go and go server
RUN echo "deb https://dl.bintray.com/gocd/gocd-deb /" > /etc/apt/sources.list.d/go.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key $GO_KEY_FINGERPRINT >/dev/null 2>&1 \
    && apt-get update > /dev/null \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes rsync openjdk-7-jre-headless go-server=$GO_SERVER_VERSION >/dev/null 2>&1

# create backup of default configuration and database if they're present
RUN mkdir -p /usr/share/go-server/default/conf \
    && rsync --delete -az /etc/go/ /usr/share/go-server/default/conf/

RUN mkdir -p /usr/share/go-server/default/lib \
    && rsync --delete -az /var/lib/go-server/ /usr/share/go-server/default/lib/

# disable daemon mode for the server, we want it to run in foreground
RUN sed -i 's:^DAEMON=Y:DAEMON=N:' /etc/default/go-server

# install scripts
ADD scripts/install-default-config.sh /etc/my_init.d/01_install_default_config.sh
RUN chmod 0755 /etc/my_init.d/01_install_default_config.sh

ADD scripts/install-default-lib.sh /etc/my_init.d/02_install_default_lib.sh
RUN chmod 0755 /etc/my_init.d/02_install_default_lib.sh

ADD scripts/fix-permissions.sh /etc/my_init.d/03_fix_permissions.sh
RUN chmod 0755 /etc/my_init.d/03_fix_permissions.sh

ADD scripts/service.sh /etc/service/go-server/run
RUN chmod 0755 /etc/service/go-server/run

# cleanup
RUN apt-get clean && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get purge --yes rsync >/dev/null 2>&1

# volumes
VOLUME /var/log/go-server
VOLUME /var/lib/go-server
VOLUME /etc/go

# port
EXPOSE 8153

CMD ["/sbin/my_init"]
