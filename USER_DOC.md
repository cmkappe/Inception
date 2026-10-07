# User Documentation

## 1. Services

This project provides a WordPress website consisting of three services:

* **NGINX** — serves the website over HTTPS.
* **WordPress** — provides the website and administration panel.
* **MariaDB** — stores the WordPress data.

The services work together automatically when the project is started.

---

## 2. Starting the Project

Make sure Docker is running, then start the project from the project directory:

```bash
make up
```

To check that all services are running:

```bash
make ps
```

The three services should show a running status:

```text
nginx
wordpress
mariadb
```

---

## 3. Stopping the Project

To stop the project:

```bash
make down
```

This stops and removes the containers.

The WordPress website and database data are stored persistently and are not normally deleted when the containers are stopped.

To start the project again:

```bash
make up
```

---

## 4. Accessing the Website

The website is available at:

```text
https://ckappe.42.fr
```

The website uses HTTPS on port 443.

HTTP on port 80 is not provided.

A basic check can be performed with:

```bash
curl -k -I https://ckappe.42.fr
```

A working website should return:

```text
HTTP/1.1 200 OK
```

---

## 5. WordPress Administration

The WordPress administration panel is available at:

```text
https://ckappe.42.fr/wp-admin
```

The administrator account is:

```text
Username: chiara
```

The administrator password is stored in:

```text
srcs/secrets/wp_admin_password.txt
```

After logging in, the administrator can manage the website, including posts, pages, users, and comments.

---

## 6. Second WordPress User

A second WordPress user is created during the initial WordPress setup.

The account is:

```text
Username: visitor
```

The password is stored in:

```text
srcs/secrets/wp_second_password.txt
```

This account has the `subscriber` role and can log in and interact with the website according to the permissions of that role.

---

## 7. Credentials

Passwords are stored locally in:

```text
srcs/secrets/
```

The directory contains:

```text
db_password.txt
db_root_password.txt
wp_admin_password.txt
wp_second_password.txt
```

These files contain sensitive information and must not be committed to Git or shared publicly.

The MariaDB root and database-user credentials are intended for database administration rather than normal website use.

---

## 8. Checking the Services

Check whether all containers are running:

```bash
make ps
```

Expected services:

```text
nginx
wordpress
mariadb
```

To view the service logs:

```bash
make logs
```

For a specific service:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

To verify that the website responds:

```bash
curl -k -I https://ckappe.42.fr
```

A response containing:

```text
HTTP/1.1 200 OK
```

indicates that the website is responding successfully.

---

## 9. Data Persistence

WordPress and MariaDB data is stored persistently.

The data is located at:

```text
/home/ckappe/data/wordpress
/home/ckappe/data/mariadb
```

Stopping and recreating the containers does not normally remove this data.

This means that WordPress content, users, comments, and database information remain available after restarting the project.
