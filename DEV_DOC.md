# Developer Documentation

## 1. Prerequisites

The project requires:

* Docker
* Docker Compose
* `make`
* A Linux environment or compatible Docker VM

On the development Mac, Docker runs through Colima.

Check the installation:

```bash
docker --version
docker compose version
make --version
```

Check Colima:

```bash
colima status
```

If necessary:

```bash
colima start
```

---

## 2. Project Configuration

The main Docker Compose configuration is:

```text
srcs/docker-compose.yml
```

Non-sensitive configuration is stored in:

```text
srcs/.env
```

The `.env` file contains values such as:

* MariaDB database name
* MariaDB username
* MariaDB hostname
* domain name
* WordPress usernames and email addresses

Passwords are not stored in `.env`.

### Secrets

Passwords are stored in:

```text
srcs/secrets/
```

The required files are:

```text
srcs/secrets/
├── db_password.txt
├── db_root_password.txt
├── wp_admin_password.txt
└── wp_second_password.txt
```

For a fresh setup, create them with:

```bash
make secrets
```

The secrets are mounted into the containers under `/run/secrets/`.

The `srcs/secrets/` directory is excluded from Git.

---

## 3. First-Time Setup

For a fresh checkout, create the secrets before starting the project:

```bash
make secrets
```

Then build the Docker images:

```bash
make build
```

Start the project:

```bash
make up
```

Check the containers:

```bash
make ps
```

The three services should be running:

```text
nginx
wordpress
mariadb
```

Test the website:

```bash
curl -k -I https://ckappe.42.fr
```

A successful response should contain:

```text
HTTP/1.1 200 OK
```

The complete first-time setup is therefore:

```bash
make secrets
make build
make up
make ps
```

---

## 4. Makefile Commands

### Build

Build all three custom images:

```bash
make build
```

### Start

Create and start all containers:

```bash
make up
```

### Stop

Stop and remove the Compose containers and network:

```bash
make down
```

Persistent application data is normally retained.

### Restart

Stop and start the containers again:

```bash
make restart
```

### Status

Show the status of all services:

```bash
make ps
```

### Logs

Show logs from all services:

```bash
make logs
```

For one service:

```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

Press `Ctrl+C` to stop following the logs.

### Clean rebuild

Remove the Compose containers, images, and Docker volume objects, then rebuild and start:

```bash
make re
```

This runs:

```text
make fclean
make build
make up
```

---

## 5. Docker Compose

The project is managed with:

```text
srcs/docker-compose.yml
```

It defines three services:

* `nginx`
* `wordpress`
* `mariadb`

It also defines the Docker network, persistent volumes, and secrets.

The services communicate through the Docker network using their service names.

Only NGINX publishes a host port:

```text
443:443
```

WordPress and MariaDB do not publish ports to the host.

---

## 6. Persistent Data and Volumes

The project uses named Docker volumes for persistent application data.

The MariaDB data is stored in:

```text
/home/ckappe/data/mariadb
```

The WordPress data is stored in:

```text
/home/ckappe/data/wordpress
```

The named volumes can be inspected with:

```bash
docker volume ls
```

and:

```bash
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```

The `device` field should show:

```text
/home/ckappe/data/mariadb
/home/ckappe/data/wordpress
```

The persistent data remains when the containers are stopped, removed, and recreated.

The WordPress volume contains the WordPress installation and its content.

The MariaDB volume contains the database files.

---

## 7. Managing Containers

Check running containers:

```bash
docker ps
```

or:

```bash
make ps
```

Open a shell inside a container when debugging:

```bash
docker exec -it srcs-nginx-1 bash
docker exec -it srcs-wordpress-1 bash
docker exec -it srcs-mariadb-1 bash
```

Inspect Docker networks:

```bash
docker network ls
```

Inspect Docker volumes:

```bash
docker volume ls
```

---

## 8. Resetting Persistent Data

A completely fresh WordPress and MariaDB installation requires deleting the persistent data.

Stop the project first:

```bash
make down
```

The persistent data is stored inside the Colima VM at:

```text
/home/ckappe/data/mariadb
/home/ckappe/data/wordpress
```

### Reset only MariaDB

To remove the MariaDB data:

```bash
colima ssh -- sudo sh -c 'rm -rf /home/ckappe/data/mariadb/*'
```

### Reset only WordPress

To remove the WordPress data:

```bash
colima ssh -- sudo sh -c 'rm -rf /home/ckappe/data/wordpress/*'
```

### Reset both

To completely reset the WordPress and MariaDB installation:

```bash
colima ssh -- sudo sh -c 'rm -rf /home/ckappe/data/mariadb/* /home/ckappe/data/wordpress/*'
```

After clearing the data, rebuild and start the project:

```bash
make build
make up
```

MariaDB and WordPress will then perform their first-start initialization again.

**Warning:** Removing these directories permanently deletes the corresponding database and WordPress data. Only perform this reset when a completely fresh installation is intentional.
