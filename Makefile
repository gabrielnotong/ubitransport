# To specify text which are not real files or dir
.PHONY: install help up build prune down app clean

# make|make help, Displays help
.DEFAULT_GOAL = help

# Docker and docker-compose start commands
DOCKER_COMPOSE = docker-compose
DOCKER = docker

EXEC_PHP = $(DOCKER_COMPOSE) exec -T php

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-10s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

up: down ## Wakes up containers in the detached mode
	$(DOCKER_COMPOSE) up -d

install: down clean build up ## Builds containers and run them

build: down prune ## Builds images
	$(DOCKER_COMPOSE) build

prune: down ## Cleans up unused containers and images
	$(DOCKER) system prune -a -f

down: ## Switches off all running containers
	$(DOCKER_COMPOSE) down

bash:
	$(DOCKER_COMPOSE) exec php bash

fixtures: migration ## Makes data available for the application
	$(EXEC_PHP) ./bin/console doctrine:fixtures:load --no-interaction

migration: db-drop db-create ## Updates database schema
	$(EXEC_PHP) ./bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration

db-drop: ## Drops mysql database
	$(EXEC_PHP) ./bin/console doctrine:database:drop --if-exists --force

db-create: ## Creates mysql database
	$(EXEC_PHP) ./bin/console doctrine:database:create --if-not-exists

clean: prune ## Stops and clean all containers and volumes; removes node_modules, vendor and public/build folders
	rm -rf project/node_modules; rm -rf project/vendor; rm -rf project/public/build; rm -rf project/var