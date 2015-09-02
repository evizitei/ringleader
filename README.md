## Ringleader

(perhaps also known as "docker-register + arbitrary config info in ruby", special thanks
to https://github.com/jwilder/docker-register)

Ringleader sets up a container running [docker-gen][https://github.com/jwilder/docker-gen].  It then watches
for containers with the right metadata and sends their exposed configuration data
through to etcd, which can be queried by other services.

### Usage

#### With internal etcd
If you don't pass an ETCD_HOST env var when the container starts,
ringleader will start up an internal etcd instance exposed on 2379 and 4001 to
make config information available to etcd clients in other containers without
having to run a seperate etcd container.  Startup ringleader like this:

```bash
$ docker run -p 4001:4001 -p 2380:2380 -p 2379:2379 -v /var/run/docker.sock:/var/run/docker.sock evizitei/ringleader
```

The ports are necessary for letting etcd clients talk to the process in this container. If
using in conjunction with https://github.com/jwilder/nginx-proxy (which I recommend),
then you'll want to pass -e VIRTUAL_HOST=etcd.docker or something to make sure other clients
don't have to find the docker host IP or anything, and that would look like this:

```bash
$ docker run -e VIRTUAL_HOST=etcd.docker -p 4001:4001 -p 2380:2380 -p 2379:2379 -v /var/run/docker.sock:/var/run/docker.sock evizitei/ringleader
```

#### Without internal etcd (you care about one process per container in dev)
You'll need some etcd store either running in a different container, or available
at a host accessible to the ringleader instance. use the ETCD_HOST environment variable
to provide the hostname or IP at which etcd is running.  For an example configuration
for a containerized etcd that has been tested with ringleader, you could use this:

```bash
#/bin/bash
docker run -p 4001:4001 -p 2380:2380 -p 2379:2379 --name etcd quay.io/coreos/etcd:latest \
  -advertise-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
  -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001
```

now 4001 is exposed as a port on your docker host to talk to etcd over, and you could
use the IP of your docker host as the value for ETCD_HOST in the ringleader container.

To build ringleader locally from the Dockerfile:

    $ docker build -t evizitei/ringleader:latest .

To run ringleader once an image has been built:

    $ docker run -e ETCD_HOST=1.2.3.4 -v /var/run/docker.sock:/var/run/docker.sock evizitei/ringleader

Now ringleader is running and watching for any containers with labels (https://docs.docker.com/userguide/labels-custom-metadata/) that look like this:

```Dockerfile
LABEL etcd_conf_key="base_key"
LABEL etcd_conf_data="{\"key1\"=\"value1\",\"key2\"=\"value2\"}"
```

The 'etcd_conf_key' is the url bucket in etcd into which the data will be placed,
and the 'etcd_conf_data' is a json hash of the data you want the container to expose.
For example, if you launched some application container with the above labels in
them, ringleader would talk to etcd and you'd end up with this:

```bash
$> curl http://etcd-host:4001/v2/keys/base_key
{
  "action":"get",
  "node":{
    "key":"/base_key",
    "dir":true,
    "nodes":[
    {
      "key":"/base_key/key1",
      "value":"value1",
      "modifiedIndex":34,
      "createdIndex":34
    },{
      "key":"/base_key/key2",
      "value":"value2",
      "modifiedIndex":35,
      "createdIndex":35
    }
    ],
    "modifiedIndex":32,
    "createdIndex":32
  }
}
```

And now other containers can ask for configuration information relevant to the "base_key" app.
