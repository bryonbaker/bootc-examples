FROM quay.io/fedora/fedora-bootc:40
RUN dnf install -y cockpit && dnf clean all
RUN systemctl enable cockpit.socket

# Copy the files and directories from the build context into the image.
ADD etc etc
ADD usr usr

# Set the sudoers permissions
RUN chmod 0440 /etc/sudoers.d/wheel

# Add user and SSH public key
ARG sshpubkey
RUN if test -z "$sshpubkey"; then echo "Must provide an ssh public key"; exit 1; fi; \
    useradd -G wheel bryon && \
    mkdir -p /home/bryon/.ssh && \
    chmod 0700 /home/bryon/.ssh && \
    echo "$sshpubkey" > /home/bryon/.ssh/authorized_keys && \
    chmod 0600 /home/bryon/.ssh/authorized_keys && \
    chown -R bryon:bryon /home/bryon
