FROM ruriat/zotonic:0.11.1

# Allow specifying sites and configuration in sub-container
ONBUILD COPY config /home/zotonic/.zotonic
ONBUILD COPY sites /srv/zotonic/user/sites
