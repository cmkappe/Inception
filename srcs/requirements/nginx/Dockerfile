
# pulls from Docker Hub
FROM debian:bullseye

# executes once while building image, NOT when starting container
RUN apt-get update && \
    apt-get install -y nginx

# copy file on the right into container on the left
COPY conf/nginx.conf /etc/nginx/nginx.conf

# runs every time container starts -> main process, here nginx
CMD [ "nginx", "-g", "daemon off;" ]

# order of commands matter since Docker works in snapshots and pnly rebuilds changed parts