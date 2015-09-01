ringleader sets up a container running [docker-gen][https://github.com/jwilder/docker-gen].  It then watches
for containers with the right metadata and sends their exposed configuration data
through to etcd, which can be queried by other services.

### Usage

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

After that, any container that starts with labels matching the convention will have their
information pushed into etcd.
