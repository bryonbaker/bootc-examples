# Makefile for building shakeout-app container
IMAGE_NAME := quay.io/bryonbaker/rhel9-bootc
TAG := latest
SSH_PUB_KEY := $(shell cat $(HOME)/.ssh/id_rsa.pub)
RHEL_IMAGE_BUILDER := registry.redhat.io/rhel9/bootc-image-builder:latest
CENTOS_IMAGE_BUILDER := quay.io/centos-bootc/bootc-image-builder:latest 
IMAGE_BUILDER := $(RHEL_IMAGE_BUILDER)
# Options are: iso, ami, qcow2, raw
OUTPUT_FORMAT := ami
REGION := ap-southeast-2
BUCKET := brbaker-ami

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
ifeq ($(OUTPUT_FORMAT), ami)
	sudo podman run \
	  --rm \
	  -it \
	  --privileged \
	  --pull=newer \
	  -v $(HOME)/.aws:/root/.aws:ro \
	  --env AWS_PROFILE=default \
	  $(IMAGE_BUILDER) \
	  --type ami \
	  --aws-ami-name rhel-bootc-x86 \
	  --aws-bucket $(BUCKET) \
	  --aws-region $(REGION) \
	  $(IMAGE_NAME):$(TAG)
else
	sudo podman run --rm -it --privileged -v .:/output:Z \
	$(IMAGE_BUILDER) --type $(OUTPUT_FORMAT) \
	$(IMAGE_NAME):$(TAG)
endif
