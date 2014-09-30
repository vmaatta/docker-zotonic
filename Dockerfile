FROM ubuntu:14.04

MAINTAINER Ville Määttä

RUN groupadd -r zotonic && useradd -r -m -g zotonic zotonic

RUN apt-get update && apt-get install -y build-essential imagemagick \
	git erlang-base erlang-tools erlang-parsetools \
	erlang-inets erlang-ssl erlang-eunit erlang-dev \
	erlang-xmerl erlang-src 

# install Zotonic
RUN git clone git://github.com/zotonic/zotonic.git /srv/zotonic
RUN chown -R zotonic:zotonic /srv/zotonic
USER zotonic
WORKDIR /srv/zotonic
RUN make

USER 0:0
ADD bin/zotonic_config.awk /usr/local/bin/
ADD bin/zotonic-startup.sh /usr/local/bin/
CMD ["start"]
VOLUME /srv/zotonic/user/sites
EXPOSE 8000
ENTRYPOINT ["zotonic-startup.sh"]
