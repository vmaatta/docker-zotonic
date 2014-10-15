FROM ubuntu:14.04

MAINTAINER Ville Määttä

RUN groupadd -r zotonic && useradd -r -m -g zotonic zotonic

COPY lib/erlang-solutions_1.0_all.deb /usr/local/lib/
RUN dpkg -i /usr/local/lib/erlang-solutions_1.0_all.deb
RUN apt-get update && apt-get install -y build-essential imagemagick\
	git exif erlang-base erlang-tools erlang-parsetools\
	erlang-inets erlang-ssl erlang-eunit erlang-dev\
	erlang-xmerl erlang-src 

# install Zotonic
RUN git clone git://github.com/zotonic/zotonic.git /srv/zotonic
# [review] - Check with Erlang 17.4 / patched 17.3
# Manually add rebar due to OTP SNI bug:
# http://erlang.org/pipermail/erlang-questions/2014-September/081107.html
ADD bin/rebar /srv/zotonic/
# [review] - Workaround for https://github.com/zotonic/zotonic/issues/841
COPY lib/config/master/zotonic.config /home/zotonic/.zotonic/zotonic.config
COPY lib/config/master/erlang.config /home/zotonic/.zotonic/erlang.config
RUN chown -R zotonic:zotonic /srv/zotonic && chown -R zotonic:zotonic /home/zotonic/.zotonic
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
