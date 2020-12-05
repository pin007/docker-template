#!make
## This makefile is simple wrapper for building and publishing docker images into registry.
## Copyright (c) 2020 Antonin Faltynek <tonda@kaf.cz>
##
## Custom configuration
##   For configuration use file `.env` where you can override any variables used here.
##


# Docker registry path
REGISTRY=docker.io
REGISTRY_USER=pin007
# Name of docker image, by default parent directory of current one
IMAGE_NAME != pwd | sed -r -e 's/.*[/](docker-)?//g'
# Image version, generally you want to specify in `.env` file
# image tag from branch: `git branch --show-current | sed -r -e 's/(master|main)/latest/'`
# image tag from git tag: `git describe --tags --abbrev=0`
IMAGE_TAG != git branch --show-current | sed -r -e 's/(master|main)/latest/'
# Additional arguments for `docker build`, generally you want to specify this in `.env` file
DOCKER_BUILD_ARGS =
# Docker run arguments for test
DOCKER_RUN_ARGS =
# Command that should be invoked during test
CMD =

IMAGE_NAME := ${REGISTRY_USER}/${IMAGE_NAME}

ifneq (,$(wildcard .env))
	include .env
	export
endif


build: ## Build and tag docker image locally
	@echo "Building ${IMAGE_NAME}:${IMAGE_TAG}"
	docker build ${DOCKER_BUILD_ARGS} -t ${IMAGE_NAME}:${IMAGE_TAG} .

release: build ## Build docker image and release it into registry, see `REGISTRY` parameter
	docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
	docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

test: build ## Build docker image and run it, conditionally you can pass command to execute, e.g. `make test CMD=bash`
	docker run --rm -ti ${DOCKER_RUN_ARGS} ${IMAGE_NAME}:${IMAGE_TAG} ${CMD}

.PHONY: clean
clean: ## Clean locally built docker image
	-docker image rm ${IMAGE_NAME}:${IMAGE_TAG}
	-docker image rm ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

.PHONY: prune
prune: clean ## Clean locally build docker image and prune any dangling images
	-docker image prune -f

.PHONY: help
help: ## Show this help
	@grep -h -E '^##.*$$' $(MAKEFILE_LIST) | sed -r 's/^## ?//'
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
