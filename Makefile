NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml
SUDO ?= sudo

all: up

build:
	$(SUDO) docker compose -f $(COMPOSE_FILE) build

up:
	$(SUDO) docker compose -f $(COMPOSE_FILE) up -d

down:
	$(SUDO) docker compose -f $(COMPOSE_FILE) down

restart:
	$(SUDO) docker compose -f $(COMPOSE_FILE) down
	$(SUDO) docker compose -f $(COMPOSE_FILE) up -d

logs:
	$(SUDO) docker compose -f $(COMPOSE_FILE) logs

ps:
	$(SUDO) docker compose -f $(COMPOSE_FILE) ps

secrets:
	@mkdir -p srcs/secrets
	@bash -c '\
		umask 077; \
		read -r -s -p "MariaDB root password: " DB_ROOT; echo; \
		read -r -s -p "MariaDB user password: " DB_PASSWORD; echo; \
		read -r -s -p "WordPress admin password: " WP_ADMIN; echo; \
		read -r -s -p "WordPress second user password: " WP_SECOND; echo; \
		printf "%s" "$$DB_ROOT" > srcs/secrets/db_root_password.txt; \
		printf "%s" "$$DB_PASSWORD" > srcs/secrets/db_password.txt; \
		printf "%s" "$$WP_ADMIN" > srcs/secrets/wp_admin_password.txt; \
		printf "%s" "$$WP_SECOND" > srcs/secrets/wp_second_password.txt; \
		echo "Docker secrets created." \
	'
volumes:
	$(SUDO) docker volume ls
	$(SUDO) docker volume inspect srcs_mariadb_data
	$(SUDO) docker volume inspect srcs_wordpress_data

tls:
	$(SUDO) docker exec srcs-nginx-1 nginx -T 2>&1 | grep ssl_protocols
	$(SUDO) docker exec srcs-nginx-1 nginx -T 2>&1 | grep -E 'ssl_certificate|ssl_certificate_key'

check:
	@echo "=== Container status ==="
	@$(MAKE) ps
	@echo ""
	@echo "=== HTTPS ==="
	@curl -k -I --max-time 5 https://ckappe.42.fr
	@echo ""
	@echo "=== HTTP (should fail) ==="
	@curl -I --max-time 5 http://ckappe.42.fr || true
	@echo ""
	@echo "=== Volumes ==="
	@$(MAKE) volumes
	@echo ""
	@echo "=== TLS ==="
	@$(MAKE) tls
	@echo ""
	@echo "=== Network ==="
	@$(SUDO) docker network inspect srcs_inception

fclean:
	$(SUDO) docker compose -f $(COMPOSE_FILE) down --rmi all --volumes

re:
	$(MAKE) fclean
	$(MAKE) build
	$(MAKE) up

.PHONY: all build up down restart logs ps volumes tls check db-check secrets fclean re

# Command		Purpose
# make			Build/start the infrastructure
# make build	Build the three Docker images
# make up		Start the containers
# make down		Stop/remove containers, keep volumes
# make restart	Stop and start everything
# make logs		Show container logs
# make ps		Show container status
# make clean	Same as down
# make fclean	Remove containers, images and volumes
# make re		Full rebuild from scratch
