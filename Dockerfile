FROM ville/zotonic:master

# Allow specifying sites and configuration in sub-container
ONBUILD COPY config /home/zotonic/.zotonic
ONBUILD COPY sites /srv/zotonic/user/sites
