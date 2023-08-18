`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸
##############################################################################################################
| INSTRUCTION ||  Description                                                                                | 
| °°°°°°°°°°° ||  °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° |
| FROM        ||  it sets the Base Image for subsequent instructions.                                        |
| MAINTAINER  ||  it sets the Author field of the generated images.                                          |
| RUN         ||  it will execute any commands when Docker image will be created.                            |
| CMD         ||  it will execute any commands when Docker container will be executed.                       |
| ENTRYPOINT  ||  it will execute any commands when Docker container will be executed.                       |
| LABEL       ||  it adds metadata to an image.                                                              |
| EXPOSE      ||  it informs Docker that the container will listen on the specified network ports at runtime.|
| ENV         ||  it sets the environment variable.                                                          |
| ADD         ||  it copies new files, directories or remote file URLs.                                      |
| COPY        ||  it copies new files or directories => The differences of [ADD] are that it's impossible to |
|             ||     specify remore URL and also it will not extract archive files automatically.            |
| VOLUME      ||  it creates a mount point with the specified name and marks it as holding externally        |
|             ||     mounted volumes from native host or other containers                                    |
| USER        ||  it sets the user name or UID.                                                              |
| WORKDIR     ||  it sets the working directory.                                                             |
##############################################################################################################
¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`¸'`
==============================================================================================================
...  ..................................  ...
###  Create Dockerfile (with e.g. nano)  ###
°°°  °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°  °°°

,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
| FROM ubuntu:2204                                                       |
| MAINTAINER ServerWorld <admin@srv.world>                               |
| RUN apt -y install nginx                                               |
| RUN echo "Dockerfile Test on Nginx" > /usr/share/nginx/html/index.html |
| EXPOSE 80                                                              |
| CMD ["/usr/sbin/nginx", "-g", "daemon off;"]                           |
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
...  ..................................................  ...
###  Build Image | docker build -t [image name]:[tag] .  ###
°°°  °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°  °°°
[root@IP ~]$ podman build -t srv.world/centos-nginx:latest .
# STEP 1: FROM debian:11
# STEP 2: MAINTAINER ServerWorld <admin@srv.world>
# --> ebbbd7990da
# STEP 3: RUN apt -y install nginx
# STEP 6: CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
# STEP 7: COMMIT srv.world/centos-nginx:latest
# --> 857fd2f5a02
# 857fd2f5a02678346c1d2da28f11b25c396679d0fafc621b6bb2800e9a7b5d48

[root@IP ~]$ podman images
# REPOSITORY                  TAG     IMAGE ID      CREATED             SIZE
# srv.world/centos-nginx      latest  857fd2f5a026  About a minute ago  298 MB
# srv.world/centos-httpd      latest  6a4b6e2cae37  17 minutes ago      322 MB
# registry.centos.org/centos  stream8 2f3766df23b6  3 months ago        217 MB

...  .............  ...
###  run container  ###
°°°  °°°°°°°°°°°°°  °°°
[root@IP ~]$ podman run -d -p 80:80 srv.world/centos-nginx
# bb1f145aa93b8f65a8e88c04ddefe5a215876b03f365d40499cff28d7e620740

[root@IP ~]$ podman ps
# CONTAINER ID  IMAGE                   COMMAND               CREATED         STATUS             PORTS               NAMES
# bb1f145aa93b  srv.world/centos-nginx  /usr/sbin/nginx -...  11 seconds ago  Up 11 seconds ago  0.0.0.0:80->80/tcp  nervous_shirley

...  ...............  ...
###  verify accesses  ###
°°°  °°°°°°°°°°°°°°°  °°°
[root@IP ~]$ curl localhost
# Dockerfile Test on Nginx

...  .............................................  ...
###  also possible to access via container network  ###
°°°  °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°  °°°
[root@IP ~]$ podman inspect -l | grep \"IPAddress
#            "IPAddress": "10.88.0.17",
#                    "IPAddress": "10.88.0.17",
[root@IP ~]$ curl 10.88.0.17
# Dockerfile Test on Nginx


https://www.server-world.info/en/note?os=CentOS_Stream_8&p=podman&f=4