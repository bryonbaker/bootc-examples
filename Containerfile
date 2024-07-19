#FROM quay.io/fedora/fedora-bootc:40
FROM registry.redhat.io/rhel9/rhel-bootc
RUN <<EOF
    dnf install -y cockpit
    dnf clean all
    systemctl enable cockpit.socket
EOF

# Copy the files and directories from the build context into the image.
ADD etc etc
ADD usr usr

# Update some defaults
# This prevents the mailbox warning when creating the user.
ENV USERADD=/etc/default/useradd
RUN <<EOF
    if grep -q '^CREATE_MAIL_SPOOL=' $USERADD;
    then 
        sed -i '/^CREATE_MAIL_SPOOL=/c\CREATE_MAIL_SPOOL=no' $USERADD;
    else
        sed -i '$aCREATE_MAIL_SPOOL=no' $USERADD;
    fi
EOF

# Set the sudoers permissions
RUN chmod 0440 /etc/sudoers.d/wheel

# Add user and SSH public key
ARG sshpubkey
RUN <<EOF
    if test -z "$sshpubkey"; then 
        echo "Must provide an ssh public key"; 
        exit 1; 
    fi;
    useradd -G wheel user1
    mkdir -p /home/user1/.ssh
    chmod 0700 /home/user1/.ssh
    echo "$sshpubkey" > /home/user1/.ssh/authorized_keys
    chmod 0600 /home/user1/.ssh/authorized_keys
    chown -R user1:user1 /home/user1
EOF
