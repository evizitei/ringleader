ringleader sets up a container running [docker-gen][https://github.com/jwilder/docker-gen].  It then watches
for containers with the right metadata and sends their exposed configuration data
through to etcd, which can be queried by other services.

### Usage

To run it:

    $ docker run -e ETCD_HOST=1.2.3.4 -v /var/run/docker.sock:/var/run/docker.sock evizitei/ringleader

After that, any container that starts with labels matching the convention will have their
information pushed into etcd.
