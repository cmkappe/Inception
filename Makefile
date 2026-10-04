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

fclean:
	docker compose -f $(COMPOSE_FILE) down --rmi all --volumes

re:
	$(MAKE) fclean
	$(MAKE) build
	$(MAKE) up

.PHONY: all build up down restart logs ps clean fclean re

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