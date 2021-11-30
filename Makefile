
include Makefile.lint
include Makefile.build_args

GOSS_VERSION := 0.3.6

all: pull build

pull:
	docker pull bearstech/python:3.7
	docker pull bearstech/python:3.9
	docker pull hadolint/hadolint:latest

build-37:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg python_version=3.7 \
		-t bearstech/lint:3.7 \
		-f Dockerfile \
		.

build-39:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg python_version=3.9 \
		-t bearstech/lint:3.9 \
		-f Dockerfile \
		.

build: build-37 build-39
	docker tag bearstech/lint:3.9 bearstech/lint:latest


push:
	docker push bearstech/lint:3.7
	docker push bearstech/lint:3.9
	docker push bearstech/lint:latest

remove_image:
	docker rmi bearstech/lint:3.7
	docker rmi bearstech/lint:3.9
	docker rmi bearstech/lint:latest

down:

tests:
