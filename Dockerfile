FROM ville/zotonic:0.12.3-onbuild

# Allow specifying sites and configuration in sub-container
ONBUILD COPY config /home/zotonic/.zotonic
ONBUILD COPY sites /srv/zotonic/user/sites
