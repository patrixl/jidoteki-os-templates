#!/bin/bash
#
# Bootstrap script for setting up Debian as a vagrant .box
#
# Copyright (c) 2013 Alex Williams, Unscramble <license@unscramble.jp>

TAR=`which tar`

fail_and_exit() {
        echo "Provisioning failed"
        exit 1
}

# Install some dependencies
apt-get update && \
apt-get install -y python-pip unzip && \
pip install --use-mirrors PyYAML Jinja2 || fail_and_exit

UNZIP=`which unzip`

pushd /root
  # Extract ansible and install it
  $TAR -zxvf v1.3.3.tar.gz || fail_and_exit
  pushd ansible-1.3.3
    # Install Ansible
    make install && \
    source hacking/env-setup || fail_and_exit
  popd

  # Extract public provisioning scripts
  $UNZIP -o beta-v2.zip || fail_and_exit
  pushd jidoteki-os-templates-beta-v2/provisioning/vagrant
    # Run ansible in local mode
    chmod 644 hosts && \
    ansible-playbook vagrant.yml -i hosts || fail_and_exit
  popd

  # Cleanup
  rm -rf v1.3.3.tar.gz ansible-1.3.3 beta-v2.zip jidoteki-os-templates-beta-v2 bootstrap_debian.sh || fail_and_exit
  history -c
popd

echo "Provisioning completed successfully"
exit 0
