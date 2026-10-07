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

## Project Description

### Use of Docker

Docker is used to isolate the three infrastructure services into separate containers while allowing them to communicate through a private Docker network.

Each service has its own custom Dockerfile and image:

* NGINX is built from Debian Bookworm and provides HTTPS and FastCGI communication with WordPress.
* WordPress is built from Debian Bookworm and contains PHP-FPM, WordPress, WP-CLI, and the MariaDB client.
* MariaDB is built from Debian Bookworm and provides the database used by WordPress.

Docker Compose defines the services, network, persistent volumes, secrets, dependencies, and restart policies in one configuration.

The main design choices are:

* one container per service;
* custom Dockerfiles instead of using ready-made service images;
* a private Docker bridge network for service-to-service communication;
* HTTPS as the only publicly exposed endpoint;
* persistent named volumes for WordPress and MariaDB data;
* Docker secrets for passwords;
* automatic initialization through entrypoint scripts.

### Virtual Machines vs Docker

A **virtual machine** virtualizes an entire operating system, including its kernel. Each VM can therefore run a complete independent operating system, but this generally requires more memory and storage.

**Docker containers** share the host system's kernel while isolating applications and their dependencies. Containers are therefore generally lighter and faster to start than full virtual machines.

This project uses both concepts for different purposes:

* the required Linux environment can be provided by a virtual machine;
* Docker runs the individual infrastructure services inside that environment.

Docker therefore provides application-level isolation, while the virtual machine provides the required Linux environment when developing on a non-Linux host.

### Secrets vs Environment Variables

Environment variables are useful for non-sensitive configuration such as:

* database name;
* database username;
* database hostname;
* domain name;
* WordPress usernames and email addresses.

This project stores those values in:
```text
srcs/.env
```

Passwords are treated differently. They are stored as Docker secret files under:
```text
srcs/secrets/
```

and mounted into the containers under:
```text
/run/secrets/
```

This separates normal configuration from sensitive credentials and avoids putting passwords directly into the Compose environment configuration.

### Docker Network vs Host Network

A Docker bridge network provides an isolated network for the containers. Services can communicate using their Compose service names, such as:
```text
wordpress:9000
mariadb
```

The host network mode would instead place containers directly on the host's network stack, removing much of this network isolation and service-level separation.

This project therefore uses a dedicated Docker bridge network. Only NGINX publishes a host port:
```text
443:443
```

WordPress and MariaDB remain accessible only through the internal Docker network.

### Docker Volumes vs Bind Mounts

A **bind mount** directly maps a specific host directory into a container. The host path is part of the container configuration itself.

A **Docker named volume** is managed by Docker and referenced by a volume name. Its storage location is configured separately.

This project uses named Docker volumes:
```text
mariadb_data
wordpress_data
```

They are configured to store persistent data under:
```text
/home/ckappe/data/mariadb
/home/ckappe/data/wordpress
```

This satisfies the requirement to use Docker volumes while ensuring that the WordPress installation and MariaDB database survive container recreation.

## Instructions

### Prerequisites

The project requires:

* Docker
* Docker Compose
* `make`
* Git
* A Linux environment or compatible Docker VM

During development on macOS, Colima was used to provide the Linux environment and Docker runtime.


### Configuration

Non-sensitive configuration is stored in:
```text
srcs/.env
```

Passwords are provided through Docker secrets.

Create the local secret files with:
```bash
make secrets
```

This creates the required files under:
```text
srcs/secrets/
```

The `srcs/secrets/` directory is excluded from Git.


### Build and Start

Build the custom Docker images:
```bash
make build
```

Start the infrastructure:
```bash
make up
```

Check the services:
```bash
make ps
```

The three services are:
```text
nginx
wordpress
mariadb
```

For a complete first-time setup:
```bash
make secrets
make build
make up
make ps
```

The Makefile runs Docker commands with `sudo` automatically, so just use
commands like `make up` and `make down` as usual. `make secrets` does not use
`sudo`; it creates the password files as your current user.


### Accessing WordPress

The configured domain is:
```text
ckappe.42.fr
```

The website is available through HTTPS:
```text
https://ckappe.42.fr
```

NGINX exposes only port 443. HTTP on port 80 is not provided.

Because the project uses a self-signed TLS certificate, a browser may display a certificate warning during local development.


### Other Makefile Commands

```bash
make down       # Stop and remove the containers and network
make restart    # Restart the infrastructure
make logs       # Display container logs
make ps         # Display container status
make volumes    # Inspect Docker volumes and their data paths
make tls        # Check TLS configuration
make check      # Run the main project checks
make db-check   # Check the MariaDB database and users
make fclean     # Remove containers, images and Docker volume objects
make re         # Full rebuild
```

More detailed development and user instructions are provided in:

* `DEV_DOC.md` — setup, Makefile commands, Docker Compose, containers, volumes, and data reset.
* `USER_DOC.md` — starting/stopping the project, website access, WordPress accounts, credentials, and basic checks.


## Resources

### Official Documentation

* Docker documentation
* Docker Compose documentation
* NGINX documentation
* WordPress documentation
* MariaDB documentation
* PHP documentation
* PHP-FPM documentation

### Learning Resources

The project concepts were studied using Docker and containerization documentation, Linux documentation, and the official documentation of the services used in the infrastructure.

### Use of AI

AI tools were used as a learning and development aid during the project.

They were used for:

* understanding Docker and Docker Compose concepts;
* understanding container networking, DNS/service discovery, volumes, and secrets;
* understanding NGINX, FastCGI, PHP-FPM, WordPress, and MariaDB interactions;
* troubleshooting Docker, MariaDB, PHP-FPM, and NGINX configuration issues;
* reviewing implementation decisions and configuration files;
* reviewing and improving project documentation.

AI was used to explain concepts, investigate problems, and review the implementation. The final configuration, scripts, and project behavior were tested and verified by the student.
