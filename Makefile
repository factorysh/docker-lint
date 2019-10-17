
include Makefile.lint
include Makefile.build_args

GOSS_VERSION := 0.3.6

all: pull build

pull:
	docker pull bearstech/debian:stretch
	docker pull hadolint/hadolint:latest

build:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/lint:latest \
		-f Dockerfile \
		.

push:
	docker push bearstech/lint:latest

remove_image:
	docker rmi bearstech/lint:latest

down:

tests:
