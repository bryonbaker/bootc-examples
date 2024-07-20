# Makefile for building shakeout-app container
IMAGE_NAME := quay.io/bryonbaker/rhel9-bootc
TAG := latest
SSH_PUB_KEY := $(shell cat $(HOME)/.ssh/id_rsa.pub)
RHEL_IMAGE_BUILDER := registry.redhat.io/rhel9/bootc-image-builder:latest
CENTOS_IMAGE_BUILDER := quay.io/centos-bootc/bootc-image-builder:latest 
IMAGE_BUILDER := $(RHEL_IMAGE_BUILDER)

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
	$(IMAGE_BUILDER) --type iso \
	$(IMAGE_NAME):$(TAG)