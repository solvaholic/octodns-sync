#!/usr/bin/make -f

SHELL = /bin/bash

srcdir = .

default: lint

lint: lint-yaml lint-shell

lint-yaml:
	@echo "Linting all the YAML things..."
	@docker run --rm \
	-v "$(realpath .)":"/tmp/lint":ro \
	--entrypoint /usr/local/bin/yamllint \
	github/super-linter --no-warnings /tmp/lint
	@echo "All the YAML things linted!"

lint-shell:
	@echo "Linting all the shell things..."
	@docker run --rm --workdir /tmp/lint \
	--entrypoint /usr/bin/shellcheck \
	-v "$(realpath .)":"/tmp/lint":ro \
	github/super-linter ./scripts/*.sh
	@echo "All the shell things linted!"
