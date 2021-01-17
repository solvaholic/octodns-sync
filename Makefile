#!/usr/bin/make -f

SHELL = /bin/bash
NS = solvaholic/octodns-sync
PORTS = -p 1313:1313
VOLUMES = -v "$(realpath ./orgdocs)":/src
NAME = hugo-server
IMAGE = solvaholic/octodns-sync:local

srcdir = .

default: build

lint: lint-dockerfile-lint lint-super-linter
build: lint-dockerfile-lint docker-build

lint-dockerfile-lint:
	@echo "Checking container image policies..."
	@docker run --rm -it -v $(PWD):/root/ \
			projectatomic/dockerfile-lint \
			dockerfile_lint --rulefile .dockerfile_lint/all.yml
	@echo "Container image policies checked!"

lint-super-linter:
	@echo "Linting all the things..."
	@docker run --rm \
    -e VALIDATE_ENV=false \
    -e RUN_LOCAL=true \
    -v "$(realpath .)":"/tmp/lint":ro \
    github/super-linter
	@echo "All the things linted!"

docker-build:
	@echo "Building ${IMAGE} image..."
	@docker build -t ${IMAGE} .
	@echo "${IMAGE} image built!"
	@docker images ${IMAGE}

inspect-labels:
	@echo "Inspecting container image labels..."
	@echo "maintainer set to..."
	@docker inspect --format '{{ index .Config.Labels "maintainer" }}' \
			${NAME}
	@echo "Container image labels inspected!"

