
# pulls from Docker Hub
FROM debian:bookworm

# Update the package list, install nginx and OpenSSL,
# then remove the cached package lists to keep the image smaller.
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Create a directory for the TLS certificate and private key.
# Generate a self-signed RSA certificate for our local domain.
# -x509: create a self-signed certificate
# -nodes: do not encrypt the private key with a password
# -days 365: certificate is valid for one year
# -newkey rsa:2048: create a new 2048-bit RSA key
# -keyout: path where the private key is saved
# -out: path where the certificate is saved
# -subj: set the certificate's subject/domain
# -addext: add the domain as a Subject Alternative Name (SAN)
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/CN=ckappe.42.fr" \
    -addext "subjectAltName=DNS:ckappe.42.fr"

# copy file on the right into container on the left
COPY conf/nginx.conf /etc/nginx/nginx.conf

# runs every time container starts -> main process, here nginx
CMD [ "nginx", "-g", "daemon off;" ]

# order of commands matter since Docker works in snapshots and pnly rebuilds changed parts