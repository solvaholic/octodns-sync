#!/usr/bin/make -f

SHELL = /bin/bash
PORTS = -p 1313:1313
VOLUMES = -v "$(realpath ./orgdocs)":/src
IMAGE = solvaholic/octodns-sync
IMAGE_VER = local
IMAGE_TAG = ${IMAGE}:${IMAGE_VER}

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
	@echo "Building ${IMAGE_TAG} image..."
	@docker build \
		--build-arg image_version="${IMAGE_VER}" \
		-t ${IMAGE_TAG} .
	@echo "${IMAGE_TAG} image built!"
	@docker images ${IMAGE_TAG}

inspect-labels:
	@echo "Inspecting ${IMAGE_TAG} labels..."
	@docker inspect --format \
		" Name: {{ index .Config.Labels \"name\" }}" ${IMAGE_TAG}
	@docker inspect --format \
		" Version: {{ index .Config.Labels \"version\" }}" ${IMAGE_TAG}
	@docker inspect --format \
		" Maintainer: {{ index .Config.Labels \"maintainer\" }}" ${IMAGE_TAG}
	@echo "Container image labels inspected!"
