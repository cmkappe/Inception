NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml

all: up

build:
	docker compose -f $(COMPOSE_FILE) build

up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

restart:
	docker compose -f $(COMPOSE_FILE) down
	docker compose -f $(COMPOSE_FILE) up -d

logs:
	docker compose -f $(COMPOSE_FILE) logs

ps:
	docker compose -f $(COMPOSE_FILE) ps

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
	docker volume ls
	docker volume inspect srcs_mariadb_data
	docker volume inspect srcs_wordpress_data

tls:
	docker exec srcs-nginx-1 nginx -T 2>&1 | grep ssl_protocols
	docker exec srcs-nginx-1 nginx -T 2>&1 | grep -E 'ssl_certificate|ssl_certificate_key'

fclean:
	docker compose -f $(COMPOSE_FILE) down --rmi all --volumes

re:
	$(MAKE) fclean
	$(MAKE) build
	$(MAKE) up

.PHONY: all build up down restart logs ps volumes tls secrets fclean re

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