# Makefile for building shakeout-app container
IMAGE_NAME := quay.io/bryonbaker/fedora-bootc
TAG := latest
SSH_PUB_KEY := $(shell cat $(HOME)/.ssh/id_rsa.pub)


.PHONY: all build push clean boot

all: clean build push boot

build:
	podman build \
		--build-arg sshpubkey="$(SSH_PUB_KEY)" \
		-f Containerfile \
		-t $(IMAGE_NAME):$(TAG)

push:
	podman push $(IMAGE_NAME):$(TAG)

clean:
	podman rmi -f $(IMAGE_NAME):$(TAG) || true

boot:
	sudo podman run --rm -it --privileged -v .:/output:Z \
	registry.redhat.io/rhel9/bootc-image-builder \
	--type qcow2 $(IMAGE_NAME):$(TAG)
