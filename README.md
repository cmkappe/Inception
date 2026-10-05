*This project has been created as part of the 42 curriculum by ckappe.*

# Inception

## Description

Inception is a system administration and Docker project from the 42 curriculum. The goal is to build a small multi-container infrastructure using Docker Compose, with each service running in its own container and each Docker image built from a custom Dockerfile.

The infrastructure consists of three services:

* **NGINX** — the only publicly exposed service. It provides HTTPS using TLS 1.2 and TLS 1.3.
* **WordPress** — runs WordPress together with PHP-FPM. It communicates with MariaDB through the Docker network.
* **MariaDB** — provides the WordPress database.

The services communicate through a dedicated Docker bridge network. WordPress website files and MariaDB data are stored persistently using Docker named volumes backed by `/home/ckappe/data/` inside the Docker VM.

The project also uses Docker secrets for passwords instead of storing credentials directly in the Docker Compose environment configuration.

### Project Structure

```text
Inception/
├── Makefile
├── README.md
├── DEV_DOC.md
├── USER_DOC.md
└── srcs/
    ├── .env
    ├── docker-compose.yml
    ├── secrets/
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/setup.sh
        └── mariadb/
            ├── Dockerfile
            └── tools/setup.sh
```

## Instructions

### Prerequisites

The project requires:

* Docker
* Docker Compose
* A Linux virtual machine
* `make`
* Git

The project is designed to run inside a virtual machine. During development, Colima was used to provide the Linux VM and Docker environment on macOS.


### Configuration

The project uses environment variables from:

```text
srcs/.env
```

Passwords are not stored in `.env`. They are provided through Docker secrets.

Create the local secret files with:

```bash
make secrets
```

This asks for:

* MariaDB root password
* MariaDB user password
* WordPress administrator password
* WordPress second-user password

The generated files are stored under:

```text
srcs/secrets/
```

This directory is excluded from Git.

### Build and start

Build all images:

```bash
make build
```

Start the infrastructure:

```bash
make up
```

Check the running containers:

```bash
make ps
```

The available services should be:

```text
mariadb
wordpress
nginx
```


### Accessing WordPress

The configured domain is:

```text
ckappe.42.fr
```

The domain must resolve to the local IP address of the virtual machine.

NGINX is exposed only through HTTPS:

```text
https://ckappe.42.fr
```

Because the project uses a self-signed TLS certificate, browsers may display a certificate warning during local development.

### Other Makefile commands

```bash
make down       # Stop and remove the containers and network
make restart    # Restart the infrastructure
make logs       # Display container logs
make ps         # Display container status
make fclean     # Remove containers, images and volumes
make re         # Full rebuild
```

`make re` performs a full cleanup followed by a new image build and startup.

## Resources

### Official documentation






## Project Description

### Use of Docker










### Virtual Machines vs Docker

A **virtual machine** virtualizes an entire operating system, including its kernel. Each VM can therefore run a complete independent operating system, but this generally requires more memory and storage.

**Docker containers** share the host system's kernel while isolating applications and their dependencies. Containers are therefore generally lighter and faster to start than full virtual machines.

This project uses both concepts for different purposes:

* the required Linux environment is provided by a virtual machine;
* Docker runs the individual infrastructure services inside that environment.













### Docker Volumes vs Bind Mounts

Both Docker volumes and bind mounts allow data to survive after a container is removed.

With a **bind mount**, you directly tell Docker to use a specific folder from the host inside the container. For example:

```text
/home/ckappe/data/wordpress:/var/www/html
```

This means: “Take this exact folder from the host and make it available at `/var/www/html` inside the container.”

With a **Docker volume**, Docker manages the storage instead. The container uses a named volume, such as:

```text
wordpress_data
```

Docker then handles where and how that volume is connected to the container.

This project uses **Docker named volumes**:

```text
mariadb_data
wordpress_data
```

They are configured to store their data under:

```text
/home/ckappe/data/mariadb
/home/ckappe/data/wordpress
```

This satisfies the project requirement to use Docker volumes while keeping the data persistent inside the Docker VM.

The main difference is therefore:

* **Bind mount:** the service directly uses a specific host folder.
* **Docker volume:** the service uses a Docker-managed volume, which is configured separately from the service itself.
