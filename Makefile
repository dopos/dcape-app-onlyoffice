# dcape-app-nextcloud Makefile
SHELL               = /bin/sh
CFG                ?= .env
# docker image version from dcape
IMAGE_VER          ?= 6.1
# Config vars are described below in section `define CONFIG_...`
APP_SITE           ?= office.dev.lan
USE_TLS            ?= false
IMAGE              ?= onlyoffice/documentserver
PROJECT_NAME       ?= $(shell basename $$PWD)
DCAPE_TAG          ?= dcape
DCAPE_NET          ?= $(DCAPE_TAG)
APP_ROOT           ?= $(PWD)
DC_VER             ?= latest

define CONFIG_DEF
# ------------------------------------------------------------------------------
# Nextcloud: general config

# Site host
APP_SITE=$(APP_SITE)

# Use TLS (true|false)
USE_TLS=$(USE_TLS)

# ------------------------------------------------------------------------------
# Nextcloud: internal config

# Host dir for app data
APP_ROOT=$(APP_ROOT)

# Docker details

# Used by docker-compose
# Docker-compose project name (container name prefix)
PROJECT_NAME=$(PROJECT_NAME)

# dcape container name prefix
DCAPE_TAG=$(DCAPE_TAG)

# dcape network attach to
DCAPE_NET=$(DCAPE_NET)

# docker image name
IMAGE=$(IMAGE)

# docker  image tag
IMAGE_VER=$(IMAGE_VER)

endef
export CONFIG_DEF

-include $(CFG)
export

-include $(CFG).bak
export

.PHONY: all $(CFG) start start-hook stop update up reup down dc help

all: help

# ------------------------------------------------------------------------------
# webhook commands

start: db-create up

start-hook: db-create reup

stop: down

update: reup

# ------------------------------------------------------------------------------
# docker commands

## старт контейнеров
up:
up: CMD=up -d
up: dc

## рестарт контейнеров
reup:
reup: CMD=up --force-recreate -d
reup: dc

## остановка и удаление всех контейнеров
down:
down: CMD=rm -f -s
down: dc

# ------------------------------------------------------------------------------

# $$PWD используется для того, чтобы текущий каталог был доступен в контейнере по тому же пути
# и относительные тома новых контейнеров могли его использовать
## run docker-compose
dc: docker-compose.yml
	@docker run --rm  \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $$PWD:$$PWD \
	  -w $$PWD \
	  docker/compose:$(DC_VER) \
	  -p $$PROJECT_NAME \
	  $(CMD)

# ------------------------------------------------------------------------------

$(CFG).sample:
	@echo "$$CONFIG_DEF" > $@

config: $(CFG).sample
# ------------------------------------------------------------------------------

## List Makefile targets
help:
	@grep -A 1 "^##" Makefile | less

##
## Press 'q' for exit
##
