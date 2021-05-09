#!/usr/bin/make -f

SHELL = /bin/bash

srcdir = .

default: lint

lint: lint-super-linter

lint-super-linter:
	@echo "Linting all the things..."
	@docker run --rm \
    -e VALIDATE_ENV=false \
    -e RUN_LOCAL=true \
    -v "$(realpath .)":"/tmp/lint":ro \
    github/super-linter
	@echo "All the things linted!"
