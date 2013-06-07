#!/usr/bin/env bash
set -x
source /vagrant/web2py_passwords.sh
source /vagrant/env_with_urls.sh || exit

apt-get update || exit
apt-get install -y apache2 || exit
rm -rf /var/www || exit
ln -fs /vagrant /var/www || exit
apt-get install -y git || exit


################################################################################
# set up some helpful env vars and store them in an opentree-shell.sh file in the home
#   that you can "source" when you "vagrant ssh" into the box
####################
echo 'source /vagrant/env_with_urls.sh' > /home/vagrant/opentree-shell.sh || exit
export OPEN_TREE_ROOT=/vagrant/open-tree || exit
echo 'export OPEN_TREE_ROOT=/vagrant/open-tree' >> /home/vagrant/opentree-shell.sh || exit
if ! test -d "${OPEN_TREE_ROOT}"
then
    mkdir  "${OPEN_TREE_ROOT}" || exit
fi

################################################################################
# Add the sourcing of the opentree-shell to the default log in (once)
####################
if test -f /home/vagrant/.bashrc.BAK
then
    cp /home/vagrant/.bashrc.BAK /home/vagrant/.bashrc
else
    cp /home/vagrant/.bashrc.BAK /home/vagrant/.bashrc
fi
echo 'source /home/vagrant/opentree-shell.sh' >> /home/vagrant/.bashrc || exit


################################################################################
# Create a data dir for large files needed to bootstrap the various databases.
####################

if test -z "$OPEN_TREE_DATA_DIR"
then
    cd "${OPEN_TREE_ROOT}"
    if ! test -d data
    then
        mkdir data || exit
    fi
    export OPEN_TREE_DATA_DIR="${OPEN_TREE_ROOT}/data"
    echo 'export OPEN_TREE_DATA_DIR="${OPEN_TREE_ROOT}/data"' >> /home/vagrant/opentree-shell.sh
else
    if ! test -d  "$OPEN_TREE_DATA_DIR"
    then
        echo OPEN_TREE_DATA_DIR defined but it does not point to a directory: \" ${OPEN_TREE_DATA_DIR}\"
        exit 1
    fi
fi


################################################################################
# Grab phylografter repo (webapp for tree ingest and name normalization)
####################
if test -z "$PHYLOGRAFTER_ROOT"
then
    cd "${OPEN_TREE_ROOT}"
    if ! test -d phylografter
    then
        git clone git://github.com/OpenTreeOfLife/phylografter.git || exit
    fi
    export PHYLOGRAFTER_ROOT="${OPEN_TREE_ROOT}/phylografter"
    echo 'export PHYLOGRAFTER_ROOT="${OPEN_TREE_ROOT}/phylografter"' >> /home/vagrant/opentree-shell.sh
else
    if ! test -d  "$PHYLOGRAFTER_ROOT"
    then
        echo PHYLOGRAFTER_ROOT defined but it does not point to a directory: \" ${PHYLOGRAFTER_ROOT}\"
        exit 1
    fi
fi

# temp to be replaced with 
#     sh "${PHYLOGRAFTER_ROOT}/vagrant-provision-phylografter.sh
# after that script is moved to the phylografter repo
source /vagrant/vagrant-provision-phylografter.sh
