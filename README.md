docker-zotonic
==============

Overview
--------

[Zotonic][] is the open source, high speed, real-time web framework  and content
management system, built with Erlang. It is flexible, extensible and designed
from the ground up to support dynamic, interactive websites and mobile
solutions.

> [zotonic.com](http://zotonic.com)


Supported tags and respective ```Dockerfile``` links
----------------------------------------------------

* [0.13.1][], [latest][]
* [0.13.0][]
* [0.13][]
* [0.13-onbuild], [onbuild][]
* [0.12.4][]
* [0.12-onbuild][]
* [0.11.1][]
* [0.11-onbuild][]
* [master][]
* [master-onbuild][]


Ingredients
-----------

* ```debian:wheezy``` [base docker image][]
* Latest [Erlang Solutions][] [Erlang OTP][] using DEB install.
* [Zotonic][] versions 0.10.1 - 0.13.1 and a rolling build from git ```master```.

Docker packaging for Zotonic. Different versions of the Dockerfile and context
adapted for different versions of Zotonic live in different branches.

Numbered version branches contain packaging using ZIP release versions of
Zotonic repackaged as tarballs. This is because a tarball works better as
a source format for Docker. The ```master``` branch is the bleeding edge that
clones Zotonic ```master``` on image build.


How-to
------

To run Zotonic you need a PostgreSQL database server running. Assuming that
database is to be run in a container as well the following order would be a
simple example of how to run these two together:

1. Start Postgres container.
2. Start Zotonic container, linking to Postgres container with name ```db```.

The Zotonic container supports adding new sites with command ```addsite```,
starting in production with ```start``` and during development getting the more
detailed logging and Zotonic shell capabilities with ```debug```. Additional
options to the given command are passed in as is.

For example to start a new site you may run the ```addsite``` command passing
arguments as described in Zotonic documentation for the version in question:

```bash
docker run -ti --volumes-from zotonic-data -v \
	/mnt/sites:/srv/zotonic/user/sites --link postgres:db --rm \
	ruriat/zotonic:0.13.0 'addsite -s blog -n testsite testsite'
```

Note that the addsite and arguments are wrapped in single quotes. The new
blog-type site is created into a host mounted volume.

It should never be necessary but if you would need to enter a container to for
example check some issues during development you need to explicitly use
```--entrypoint bash```.

You can also build a container based on a ```-onbuild``` variant of
docker-zotonic. Essentially all you need to do is to provide ```config``` and
```sites``` folders in the same folder as your empty ```Dockerfile``` which
builds ```FROM``` one of the ```-onbuild``` versions. Once built you can run
the container normally but with your sites and configuration build into the
container. There is more information about OnBuild containers in section
[Adding data as a daughter container](#adding-data-as-a-daughter-container).

Below you can read in more detail about [Environment variables](#environment-variables), [Data
Volumes][] and [Linking](#linking). At the end are more [Examples](#examples) of docker-zotonic
usage.


Environment variables
---------------------

On container startup both global default configuration file and each site
specific configuration is run through a conversion script. This script will
check for the existence of environment variables and if the environment
variable is set, it will replace the value of the variable in the file with
the one from the environment variable.

For the global defaults file all of the variables listed below are considered.
For the site specific configuration only database connection parameters
are considered. This is so that a database provided by container linking can
be connected to. The connection details may not be known before the container
is running with a link.

Use the usual Docker mechanisms to set variables that you need to override
defaults from configuration files. Please note that modifying site specific
configuration files provided from a data volume or similar is likely a better
option than setting environment variables.

Easiest option for setting parameters is using an ```env``` file and using the
```--env-file``` option for ```docker run```.

### Global default admin password

`ADMINPASSWORD=supersecret`

### Database variables

Host and port are likely to be set by linking but can be overridden by variable.
You can set protocol to anything, like 'tcp', but the value is not used.
It is important that the value is in the 3 colon format however.

```
DB_PORT=<protocol>://<host_or_ip>:<port>

DB_USERPASS=<database_user>:<database_password>
or
DBPASSWORD=<database_password>
DBUSER=<database_user>

DB_DATABASE=<database_name>
DB_SCHEMA=<database_schema>
```

Linking
-------

The most likely option for connecting to a database is linking to a container
running PostgreSQL. Please see [Postgres at Docker Hub][] for details on running
a postgres instance in a container.

Once the PostgreSQL container is running, and populated with any site data if
necessary, you may link to it with the ```--link postgres:db``` option for
```docker run```. **NOTE**: The name of the container running postgres is not
relevant but it is very important that the alias used is **db**. The alias is
used for environment variables inside the container and those are parsed
to override Zotonic site configuration.

Data Volumes
------------

A good way to add site data is to use [data volume containers][]. As an example
let's assume there is a container called ```sites-data``` running which has
been setup with [data volumes][] for sites and other necessary data. The
Zotonic container can then be started using the ```--volumes-from sites-data```
option for ```docker run```.

Also note that a data volume can also be just a single file as seen in the case
of the global ```config.in``` file below. You may provide a modified version of the
config.in file for example to set SMTP settings and on container start the
database settings are set by the script as described in [Environment variables](#environment-variables)

However data volumes are set up Zotonic should have access to the following
locations [^containerlocations] as persistent [data volumes][]:

### Zotonic 0.11 and later ###

```
/home/zotonic/.zotonic/0.11/
/srv/zotonic/priv/log
/srv/zotonic/user/sites
```

### Zotonic 0.10.1 and prior ###

```
/srv/zotonic/priv/config.in
/srv/zotonic/priv/log
/srv/zotonic/priv/sites
```

[^containerlocations]: The locations shown are the path inside a Zotonic
container. The host path may be something completely different.

Adding data as a daughter container
----------------------------------

Another way of adding sites and configuration data, and good for production, is
to add the data in a daughter container. That is, to use ```FROM``` Docker command
to base a container on this and add data in the build.

docker-zotonic contains ```OnBuild``` instructions to collect ```config``` and
```sites``` folders from build context into the daughter container being built
and populate ```/home/zotonic/.zotonic``` and ```/srv/zotonic/user/sites```
respectively.

1. Create a folder and into the folder add the following:

```bash
.
./Dockerfile
./config
./config/0.11
./config/0.11/erlang.config
./config/0.11/zotonic.config
./config/0.12
./config/0.12/erlang.config
./config/0.12/zotonic.config
./config/0.13
./config/0.13/erlang.config
./config/0.13/zotonic.config
./config/user
./config/user/modules
./sites
./sites/samplesite
./sites/samplesite/config
./sites/samplesite/controllers
./log
./log/console.log
./log/crash.log
./log/error.log
…
…
```

**NOTE**: Better include initially empty `log` folder and files because a freshly
starting Zotonic might crash expecting those files to be present.

2. Dockerfile can be as simple as this:

```
FROM ruriat/zotonic:onbuild
# sites and config placed by upstream OnBuild

MAINTAINER John Doe
```

3. Build and run

```bash
docker build -t zotonic-packaged:latest .
docker run -p 80:8000 -p 443:8443 --link postgres:db --rm zotonic-packaged start
```


Examples
--------

### Start a database container with data from host ###

```bash
$sudo docker run -d --name db -v /mnt/db/data:/var/lib/postgresql/data postgres
```

### Run a data volume container for persistent data ###
```bash
$sudo docker run -v /mnt/sites/:/srv/zotonic/priv/sites/ \
  -v /mnt/zotonic/priv/config.in:/srv/zotonic/priv/config.in \
  -v /mnt/zotonic/priv/log/:/srv/zotonic/priv/log \
  --name zotonic-data busybox true
```

### Start a Zotonic container

Database is linked to from *db* above and data volumes from *zotonic-data*.
Also note the use of a file containing environment variables.

```bash
$sudo docker run -p 80:8000 -p 443:8443 --volumes-from zotonic-data \
  --link db:db --env-file zotonic.env --rm zotonic
```

```
$cat zotonic.env
ADMINPASSWORD=supersecret_default_pass
```

By default the container will expose port 8000. In this case the site has been
setup to use SSL and the ports are exposed accordingly to the host ports
80 and 443.

### Start Zotonic container to shell bypassing the startup script

```bash
$sudo docker run -p 80:8000 -p 443:8443 --volumes-from zotonic-data --rm -ti \
  --entrypoint /bin/bash zotonic
```


Issues & contributions
----------------------

If you have any problems with or questions about this image, please add a [GitHub issue][].

Paid support is also avaiable. If you would like for example more substantial custom
work based on this image or contracted support you may [contact Ruriat][].

Contributions are always welcome. Simple fixes can be sent directly as pull
requests in the [GitHub project][]. New features and more substantial changes
should first be discussed in an issue in the same project.

For pull requests please:

* Make changes in a branch from the relevant version branch or tag. I.e. if
  fixing something in the 0.12 build, first branch off the ```HEAD``` of
  ```0.12``` branch and make your changes there.
* If necessary, make the change also to the ```-onbuild``` variant branch.


[contact Ruriat]: https://ruriat.com/contact
[GitHub project]: https://github.com/vmaatta/docker-zotonic
[GitHub issue]: https://github.com/vmaatta/docker-zotonic/issues
[Postgres at Docker Hub]: https://registry.hub.docker.com/_/postgres/
[data volumes]: http://docs.docker.com/userguide/dockervolumes/#data-volumes
[data volume containers]: http://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container
[base docker image]: https://registry.hub.docker.com/_/debian/
[Erlang Solutions]: https://www.erlang-solutions.com
[Erlang OTP]: https://www.erlang-solutions.com/downloads/download-erlang-otp
[Zotonic]: http://zotonic.com/
[0.13.1]: https://github.com/vmaatta/docker-zotonic/blob/0.13.1/Dockerfile
[0.13.0]: https://github.com/vmaatta/docker-zotonic/blob/0.13.0/Dockerfile
[0.13]: https://github.com/vmaatta/docker-zotonic/blob/0.13/Dockerfile
[0.12]: https://github.com/vmaatta/docker-zotonic/blob/0.12/Dockerfile
[0.12.3]: https://github.com/vmaatta/docker-zotonic/blob/0.12.3/Dockerfile
[0.12.4]: https://github.com/vmaatta/docker-zotonic/blob/0.12.4/Dockerfile
[latest]: https://github.com/vmaatta/docker-zotonic/blob/latest/Dockerfile
[0.12-onbuild]: https://github.com/vmaatta/docker-zotonic/blob/0.12-onbuild/Dockerfile
[0.13-onbuild]: https://github.com/vmaatta/docker-zotonic/blob/0.13-onbuild/Dockerfile
[onbuild]: https://github.com/vmaatta/docker-zotonic/blob/0.12-onbuild/Dockerfile
[0.11]: https://github.com/vmaatta/docker-zotonic/blob/0.11/Dockerfile
[0.11-onbuild]: https://github.com/vmaatta/docker-zotonic/blob/0.11-onbuild/Dockerfile
[0.11.1]: https://github.com/vmaatta/docker-zotonic/blob/0.11.1/Dockerfile
[0.10.1]: https://github.com/vmaatta/docker-zotonic/blob/0.10.1/Dockerfile
[master]: https://github.com/vmaatta/docker-zotonic/blob/master/Dockerfile
[master-onbuild]: https://github.com/vmaatta/docker-zotonic/blob/master-onbuild/Dockerfile
