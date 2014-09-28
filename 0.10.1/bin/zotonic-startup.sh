#!/bin/bash

set -e

echo "Configuring default database connection and admin password from environment"
TMPFILE=$(mktemp /tmp/zotonic_config.XXXX) && chown zotonic:zotonic $TMPFILE
su zotonic -c "/usr/local/bin/zotonic_config.awk -v defaults=true /srv/zotonic/priv/config.in > $TMPFILE"
su zotonic -c "cat $TMPFILE > /srv/zotonic/priv/config && rm $TMPFILE"

echo "Fixing site folder user and group"
chown -R zotonic:zotonic /srv/zotonic/user

echo "Overriding site specific configurations from environent"
cd /srv/zotonic/priv/sites
pattern='^.*[^/]'
for D in */; do
    [[ $D =~ $pattern ]]
    if [[ ${BASH_REMATCH[0]} != "zotonic_status" && ${BASH_REMATCH[0]} != "testsandbox" ]]; then
	TMPFILE=$(mktemp /tmp/zotonic_site_config.XXXX) && chown zotonic:zotonic $TMPFILE
	su zotonic -c "/usr/local/bin/zotonic_config.awk ${BASH_REMATCH[0]}/config > $TMPFILE"
	su zotonic -c "cat $TMPFILE > ${BASH_REMATCH[0]}/config && rm $TMPFILE"
    fi
done

echo "Setting default environment values for site generation"
if [[ -z $DBHOST ]]; then
    DBHOST=$(awk -F'"' '/.{dbhost,/{print $2}' /srv/zotonic/priv/config)
    if [[ $DBHOST ]]; then
	echo "export DBHOST=$DBHOST">>/home/zotonic/.bashrc
    fi
fi
if [[ -z $DBPORT ]]; then
    DBPORT=$(awk -F'[,}]' '/.{dbport,/{print $2}' /srv/zotonic/priv/config)
    if [[ $DBPORT ]]; then
	echo "export DBPORT=$DBPORT">>/home/zotonic/.bashrc
    fi
fi
echo "export DO_LINK=false">>/home/zotonic/.bashrc
echo "export TARGETDIR=/srv/zotonic/priv/sites">>/home/zotonic/.bashrc

echo "Building site(s)"
cd /srv/zotonic && su zotonic -c make

if [[ $1 = "start" ]]; then
    echo "Starting Zotonic"
    su zotonic -c "/srv/zotonic/bin/zotonic $@" && su zotonic -c "/srv/zotonic/bin/zotonic logtail"
else
    echo "Starting Zotonic with custom parameters"
    su zotonic -c "/srv/zotonic/bin/zotonic $@"
fi
