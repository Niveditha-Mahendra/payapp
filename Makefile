# Project namespace:  by default
NAMESPACE ?= foundation
# Image name
NAME := redeemapp
# Docker registry
REGISTRY ?= ${REGISTRY}
# Docker image reference
IMG := ${REGISTRY}/${NAMESPACE}/${NAME}
# Fetch the git branch name if it is not provided
BRANCH ?= $$(git symbolic-ref --short HEAD)
# Create  an image tag based on the branch name
BRANCH_TAG := $$(echo ${BRANCH} | tr / _)
# Fetch the latest commit hash
COMMIT_HASH := $$(git rev-parse HEAD)

# set proxy if exist
BUILD_ARGS := --build-arg http_proxy=${http_proxy} --build-arg https_proxy=${https_proxy} \
							--build-arg HTTP_PROXY=${HTTP_PROXY} --build-arg HTTPS_PROXY=${HTTPS_PROXY} \
				--build-arg APP_VERSION=$$(bash bin/version)
# Get ruby version
RUBY_VERSION := $$(<.ruby-version)
# Get ruby gemset name
RUBY_GEMSET := $$(<.ruby-gemset)
# Bundler version related to project
BUNDLER_VERSION := $$(tail -n 1 Gemfile.lock | xargs)
# RVM version
RVM_VERSION := $$(rvm -v)

# Command for starting the container
COMMAND := web

# Always use login bash shell
SHELL := /bin/bash --login

# Exposed port
PORT := -p 3000:8080

# Environment variables needed to start container
CONTAINER_ENV = -e RAILS_ENV=production  -e RAILS_LOG_TO_STDOUT=true

# Make sure recipes are always executed
.PHONY: config build push run clean shell start rm stop

# Make the necessary configuration for the build
config:
	{ \
	set -e ;\
	echo "Running configuration ..."; \
	echo ${RVM_VERSION} ;\
	rvm use ruby-${RUBY_VERSION} --install ;\
	rvm gemset use ${RUBY_GEMSET}_${BRANCH_TAG} --create ;\
	gem install bundler -v ${BUNDLER_VERSION}; \
	rm -rf .bundle; \
	rm -rf vendor/cache; \
	bundle install; \
	rm -rf .bundle;\
	}

# Return the latest commit hash, useful for upstream pipeline
get_commit_hash:
	@echo ${COMMIT_HASH}

# Display build parameters
test_config:
	{ \
	set -e ;\
	echo "Testing configuration ..." ;\
	echo ${BUILD_PARAMS} ;\
	}

# Build and tag Docker image
build: test_config
	{ \
	set -e ;\
	echo ">>> Building Docker Image of ${IMG} image with hash ${COMMIT_HASH} from branch ${BRANCH}" ;\
	docker build ${BUILD_PARAMS} ${BUILD_ARGS} -t ${IMG}:${COMMIT_HASH} . ;\
	docker tag ${IMG}:${COMMIT_HASH} ${IMG}:${BRANCH_TAG} ;\
	}

# Push Docker image
push:
	{ \
	set -e ;\
	echo ">>> Pushing Docker image ${IMG}:${BRANCH_TAG}" ;\
	docker push ${IMG}:${COMMIT_HASH} ;\
	docker push ${IMG}:${BRANCH_TAG} ;\
	}

# Clean up the created images locally and remove rvm gemset
clean:
	{ \
	set -e ;\
	docker rmi -f ${IMG}:${BRANCH_TAG} ${IMG}:${COMMIT_HASH} ;\
	rvm --force gemset delete ruby-${RUBY_VERSION}@${RUBY_GEMSET}_${BRANCH_TAG} ;\
	}

# Start a shell session inside docker container
shell:
	docker run --rm --name ${NAME}-${BRANCH_TAG} ${CONTAINER_ENV} -it ${PORT} ${IMG}:${COMMIT_HASH} sh

# Start a Docker container in the foreground
run:
	docker run --rm --name ${NAME}-${BRANCH_TAG} ${CONTAINER_ENV} -it ${PORT} ${IMG}:${COMMIT_HASH} ${COMMAND}

# Start Docker container in the background
start:
	docker run -d --name ${NAME}-${BRANCH_TAG} ${CONTAINER_ENV} ${PORT} ${IMG}:${COMMIT_HASH} ${COMMAND}

# Stop running Docker container
stop:
	docker stop ${NAME}-${BRANCH_TAG}

# Remove Docker container
rm:
	docker rm ${NAME}-${BRANCH_TAG}

# Release Docker image: build and push
release: config build
	$(MAKE)  push
