FROM debian:latest

MAINTAINER Ville Määttä

RUN groupadd -r zotonic && useradd -r -m -g zotonic zotonic

COPY lib/erlang-solutions_1.0_all.deb /usr/local/lib/
RUN dpkg -i /usr/local/lib/erlang-solutions_1.0_all.deb
# [todo] - Install only necessary erlang modules.
RUN apt-get update && apt-get install -y \
	build-essential \
	erlang \
	exif \
	git \
	imagemagick

# install Zotonic
ADD lib/zotonic-0.12.4.tar.gz /srv/
RUN chown -R zotonic:zotonic /srv/zotonic
USER zotonic
WORKDIR /srv/zotonic
RUN make

# Run Zotonic EUnit tests
RUN /srv/zotonic/bin/zotonic runtests

USER 0:0
COPY bin/zotonic_config.awk /usr/local/bin/
COPY bin/zotonic-startup.sh /usr/local/bin/

CMD ["start"]
VOLUME /home/zotonic/.zotonic
VOLUME /srv/zotonic/user/sites
VOLUME /srv/zotonic/priv/log
EXPOSE 8000
ENTRYPOINT ["zotonic-startup.sh"]
