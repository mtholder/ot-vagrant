#!/bin/bash
set -x
if ! test -f vagrant-provision-opentree.sh
then
    echo "This script must be run from the dir which corresponds to the ot-vagrant repository. Sorry 'bout that..."
    exit 1
fi

export VAGRANT_SHARED_DIR="$PWD"
export VAGRANT_HOME_DIR="$PWD/nonvagrant-user"
export VAGRANT_USERNAME="$USER"

echo about to run "sudo bash bootstrap.sh" ...
sudo VAGRANT_SHARED_DIR="$VAGRANT_SHARED_DIR" \
    VAGRANT_HOME_DIR="$VAGRANT_HOME_DIR" \
    VAGRANT_USERNAME="$VAGRANT_USERNAME" \
    bash bootstrap.sh
