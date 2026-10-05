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




### Build and start



### Accessing WordPress







## Resources

### Official documentation






## Project Description

### Use of Docker
