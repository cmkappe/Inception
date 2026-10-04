
# pulls from Docker Hub
FROM debian:bullseye

# Use a fixed Debian security snapshot because the live Bullseye
# security repository no longer contains some package versions
# referenced by this Debian image.
RUN sed -i 's|^deb http://deb.debian.org/debian-security bullseye-security main|deb http://snapshot.debian.org/archive/debian-security/20260713T000000Z bullseye-security main|' /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
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