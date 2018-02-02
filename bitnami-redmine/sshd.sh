#!/bin/bash -e
. /opt/bitnami/base/functions
. /opt/bitnami/base/helpers

info "Starting ssh daemon..."
mkdir -p /etc/ssh/keys


# Setup SSH HostKeys if needed
for algorithm in rsa dsa ecdsa ed25519
do
  keyfile=/etc/ssh/keys/ssh_host_${algorithm}_key
  [ -f $keyfile ] || ssh-keygen -q -N '' -f $keyfile -t $algorithm
  grep -q "HostKey $keyfile" /etc/ssh/sshd_config || echo "HostKey $keyfile" >> /etc/ssh/sshd_config
done
# Disable unwanted authentications
sed -i -E -e 's/^#?(\w+Authentication)\s.*/\1 no/' -e 's/^(PubkeyAuthentication) no/\1 yes/' /etc/ssh/sshd_config
# Disable sftp subsystem
sed -i -E 's/^Subsystem\ssftp\s/#&/' /etc/ssh/sshd_config

# Fix permissions at every startup
chown -R git:git ~git

# Setup gitolite admin
if [ ! -f ~git/.ssh/authorized_keys ]; then
    [ -n "$SSH_KEY_NAME" ] || SSH_KEY_NAME=admin

    mkdir -p /opt/bitnami/redmine/ssh_keys
    ssh-keygen -N '' -f /opt/bitnami/redmine/ssh_keys/redmine_gitolite_admin_id_rsa
    cp /opt/bitnami/redmine/ssh_keys/redmine_gitolite_admin_id_rsa.pub /opt/bitnami/redmine/gitolite/
    chown git /opt/bitnami/redmine/gitolite/redmine_gitolite_admin_id_rsa.pub
    chown redmine /opt/bitnami/redmine/ssh_keys/redmine_gitolite_admin_id_rsa*

    su - git -c "mkdir -p /opt/bitnami/redmine/gitolite/local/hooks/common/post-receive.d"
    su - git -c "cp /notify-jenkins /opt/bitnami/redmine/gitolite/local/hooks/common/post-receive.d/"

    su - git -c "gitolite setup -pk redmine_gitolite_admin_id_rsa.pub"

    su - git -c "sed -i -e \"s|''|'.*'|g\" .gitolite.rc"
    su - git -c 'sed -i -e "s|# LOCAL_CODE                =>  [\"]\$ENV|LOCAL_CODE                =>  \"\$ENV|g" .gitolite.rc'

# Check setup at every startup
else
  su - git -c "gitolite setup"
fi

/usr/sbin/sshd
