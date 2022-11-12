.PHONY: help clean build vendor test

SYMFONY_ENV ?= dev
SYMFONY_ASSETS_INSTALL ?= relative
COMPOSER_ARGS ?=
PHP=php

ifneq ($(SYMFONY_ENV), dev)
    COMPOSER_ARG = --optimize-autoloader --no-dev --no-suggest --no-interaction --classmap-authoritative
    SYMFONY_ASSETS_INSTALL = hard
endif

COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m

## Help
help:
	@printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	@printf " make [target]\n\n"
	@printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	@awk '/^[a-zA-Z\-\0-9\.@]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${COLOR_INFO}%-16s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

# SOURCE : http://stackoverflow.com/questions/10858261/abort-makefile-if-variable-not-set
# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
	$(strip $(foreach 1,$1, \
		$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
	$(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))))


#######################
# BUILDING TASKS
#######################

## Build and Run project
run: build
	@printf "Available at: http://localhost:8910\n"

## Install all package dependencies and assets
build: docker

## Install and run docker
docker: vendor
	docker-compose up -d

## Install vendor folder
vendor: composer.lock
	composer config extra.symfony-assets-install $(SYMFONY_ASSETS_INSTALL)
	composer install $(COMPOSER_ARGS)

## Update / create composer.lock file
composer.lock:
	composer update --lock $(COMPOSER_ARGS)

## Clean vendors, cache, logs, assets, etc.
clean:
	rm -rf vendor/ var/cache/* var/logs/* .docker/

#######################
# TESTING TASKS
#######################

## Run all tests
test:
	test `find ./src -iname "*.php" | xargs -n1 -P6 php -l | grep -Fv "No syntax errors" | wc -l` -eq 0