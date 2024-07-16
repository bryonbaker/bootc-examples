# Makefile for building shakeout-app container
IMAGE_NAME := quay.io/bryonbaker/fedora-bootc
TAG := latest
SSH_PUB_KEY := $(shell cat $(HOME)/.ssh/id_rsa.pub)


.PHONY: all build push clean

all: build push

build:
	podman build \
		--build-arg sshpubkey="$(SSH_PUB_KEY)" \
		-f Containerfile \
		-t $(IMAGE_NAME):$(TAG)

push:
	podman push $(IMAGE_NAME):$(TAG)

clean:
	podman rmi -f $(IMAGE_NAME):$(TAG) || true