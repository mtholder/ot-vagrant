#!/usr/bin/env bash
set -x
if test -z $VAGRANT_SHARED_DIR
then
    export VAGRANT_SHARED_DIR=/vagrant
    export VAGRANT_HOME_DIR=/home/vagrant
    export VAGRANT_USERNAME="vagrant"
fi
source $VAGRANT_SHARED_DIR/web2py_passwords.sh || exit
source $VAGRANT_SHARED_DIR/env_with_urls.sh || exit

apt-get update || exit
apt-get install -y apache2 || exit
echo "Commented out:  rm -rf /var/www"
echo "Commented out:  ln -fs $VAGRANT_SHARED_DIR /var/www"
apt-get install -y git || exit


################################################################################
# set up some helpful env vars and store them in an opentree-shell.sh file in the home
#   that you can "source" when you "vagrant ssh" into the box
####################
echo "source $VAGRANT_SHARED_DIR/env_with_urls.sh" > ${VAGRANT_HOME_DIR}/opentree-shell.sh || exit
export OPEN_TREE_ROOT=${VAGRANT_HOME_DIR}/open-tree || exit
echo "export OPEN_TREE_ROOT=${VAGRANT_HOME_DIR}/open-tree" >> ${VAGRANT_HOME_DIR}/opentree-shell.sh || exit
if ! test -d "${OPEN_TREE_ROOT}"
then
    mkdir  "${OPEN_TREE_ROOT}" || exit
fi

################################################################################
# Add the sourcing of the opentree-shell to the default log in (once)
####################
if test -f ${VAGRANT_HOME_DIR}/.bashrc.BAK
then
    cp ${VAGRANT_HOME_DIR}/.bashrc.BAK ${VAGRANT_HOME_DIR}/.bashrc
else
    cp ${VAGRANT_HOME_DIR}/.bashrc ${VAGRANT_HOME_DIR}/.bashrc.BAK
fi
echo "source ${VAGRANT_HOME_DIR}/opentree-shell.sh" >> ${VAGRANT_HOME_DIR}/.bashrc || exit


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
    echo 'export OPEN_TREE_DATA_DIR="${OPEN_TREE_ROOT}/data"' >> ${VAGRANT_HOME_DIR}/opentree-shell.sh
else
    if ! test -d  "$OPEN_TREE_DATA_DIR"
    then
        echo OPEN_TREE_DATA_DIR defined but it does not point to a directory: \" ${OPEN_TREE_DATA_DIR}\"
        exit 1
    fi
fi


################################################################################
# Grab opentree repo (main web app, smasher code that generates OTT, etc)
####################
if test -z "$OPEN_TREE_WEBAPP_ROOT"
then
    cd "${OPEN_TREE_ROOT}"
    if ! test -d opentree
    then
         git clone git://github.com/OpenTreeOfLife/opentree.git || exit
    fi
    export OPEN_TREE_WEBAPP_ROOT="${OPEN_TREE_ROOT}/opentree"
    echo 'export OPEN_TREE_WEBAPP_ROOT="${OPEN_TREE_ROOT}/opentree"' >> ${VAGRANT_HOME_DIR}/opentree-shell.sh
else
    if ! test -d  "$OPEN_TREE_WEBAPP_ROOT"
    then
        echo OPEN_TREE_WEBAPP_ROOT defined but it does not point to a directory: \" ${OPEN_TREE_WEBAPP_ROOT}\"
        exit 1
    fi
fi
cd "${OPEN_TREE_WEBAPP_ROOT}"
git pull origin
cd --
# temp to be replaced with 
#     sh "${OPEN_TREE_WEBAPP_ROOT}/vagrant-provision-opentree.sh
# after that script is moved to the opentree repo
source $VAGRANT_SHARED_DIR/vagrant-provision-opentree.sh

cd "${OPEN_TREE_ROOT}"

if test -z "NEO4J_TARBALL"
then
    export NEO4J_TARBALL="$PWD/$NEO4J_TARBALL_NAME"
fi
if ! test -f "${NEO4J_TARBALL}"
then
    wget -O "$NEO4J_TARBALL_NAME" "$URL_FOR_NEO4J"
fi

if ! test -d neo4j-community-1.9.M05-treemachine
then
    tar xfvz "${NEO4J_TARBALL}"
    mv "$NEO4J_TARBALL_UNPACKED_NAME" neo4j-community-1.9-treemachine
    export TREEMACHINE_NEO4J_HOME="${OPEN_TREE_ROOT}/neo4j-community-1.9-treemachine"
    echo "export TREEMACHINE_NEO4J_HOME=\"${TREEMACHINE_NEO4J_HOME}\"" >> ${VAGRANT_HOME_DIR}/opentree-shell.sh
    chown -R "$VAGRANT_USERNAME" "${TREEMACHINE_NEO4J_HOME}"
fi
if ! test -d neo4j-community-1.9.M05-taxomachine
then
    tar xfvz "${NEO4J_TARBALL}"
    mv "$NEO4J_TARBALL_UNPACKED_NAME" neo4j-community-1.9-taxomachine
    export TAXOMACHINE_NEO4J_HOME="${OPEN_TREE_ROOT}/neo4j-community-1.9-taxomachine"
    echo "export TAXOMACHINE_NEO4J_HOME=\"${TAXOMACHINE_NEO4J_HOME}\"" >> ${VAGRANT_HOME_DIR}/opentree-shell.sh
    chown -R "$VAGRANT_USERNAME" "${TAXOMACHINE_NEO4J_HOME}"
fi



################################################################################
# Grab taxomachine repo (services, such as TNRS, for dealing with OTT)
####################
if test -z "$TAXOMACHINE_ROOT"
then
    cd "${OPEN_TREE_ROOT}"
    if ! test -d taxomachine
    then
         git clone git://github.com/OpenTreeOfLife/taxomachine.git || exit
    fi
    export TAXOMACHINE_ROOT="${OPEN_TREE_ROOT}/taxomachine"
    echo 'export TAXOMACHINE_ROOT="${OPEN_TREE_ROOT}/taxomachine"' >> ${VAGRANT_HOME_DIR}/opentree-shell.sh
else
    if ! test -d  "$TAXOMACHINE_ROOT"
    then
        echo TAXOMACHINE_ROOT defined but it does not point to a directory: \" ${TAXOMACHINE_ROOT}\"
        exit 1
    fi
fi
cd "${TAXOMACHINE_ROOT}"
git pull origin
cd --
# temp to be replaced with 
#     sh "${TAXOMACHINE_ROOT}/vagrant-provision-taxomachine.sh
# after that script is moved to the taxomachine repo
source $VAGRANT_SHARED_DIR/vagrant-provision-taxomachine.sh


################################################################################
# Grab treemachine repo (code for setting up and interacting with the Graph
#   of Life)
####################
if test -z "$TREEMACHINE_ROOT"
then
    cd "${OPEN_TREE_ROOT}"
    if ! test -d treemachine
    then
         git clone git://github.com/OpenTreeOfLife/treemachine.git || exit
    fi
    export TREEMACHINE_ROOT="${OPEN_TREE_ROOT}/treemachine"
    echo 'export TREEMACHINE_ROOT="${OPEN_TREE_ROOT}/treemachine"' >> ${VAGRANT_HOME_DIR}/opentree-shell.sh
else
    if ! test -d  "$TREEMACHINE_ROOT"
    then
        echo TREEMACHINE_ROOT defined but it does not point to a directory: \" ${TREEMACHINE_ROOT}\"
        exit 1
    fi
fi
cd "${TREEMACHINE_ROOT}"
git pull origin
cd --
# temp to be replaced with 
#     sh "${TREEMACHINE_ROOT}/vagrant-provision-treemachine.sh
# after that script is moved to the treemachine repo
source $VAGRANT_SHARED_DIR/vagrant-provision-treemachine.sh


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
    echo 'export PHYLOGRAFTER_ROOT="${OPEN_TREE_ROOT}/phylografter"' >> ${VAGRANT_HOME_DIR}/opentree-shell.sh
else
    if ! test -d  "$PHYLOGRAFTER_ROOT"
    then
        echo PHYLOGRAFTER_ROOT defined but it does not point to a directory: \" ${PHYLOGRAFTER_ROOT}\"
        exit 1
    fi
fi
cd "${PHYLOGRAFTER_ROOT}"
git pull origin
cd --
# temp to be replaced with 
#     sh "${PHYLOGRAFTER_ROOT}/vagrant-provision-phylografter.sh
# after that script is moved to the phylografter repo
source $VAGRANT_SHARED_DIR/vagrant-provision-phylografter.sh



################################################################################
# Grab test suite repo 
####################
cd "${OPEN_TREE_ROOT}"
if ! test -d opentree-testrunner
then
    git clone git://github.com/OpenTreeOfLife/opentree-testrunner.git || exit
fi
cd opentree-testrunner
git pull origin
cp local.conf test.conf
cd --


################################################################################
# Get the web2py web framework and set up links to phylografter and opentree
#   this is all that needs to be done to "install" those web apps into web2py
####################
cd "${OPEN_TREE_ROOT}"
if ! test -d web2py
then
    git clone git://github.com/web2py/web2py.git || exit
fi
cd web2py || exit
git checkout R-2.4.6 || exit
cd applications  || exit
if ! test -L phylografter
then
    ln -s  "${PHYLOGRAFTER_ROOT}" . || exit
fi
if ! test -L opentree
then
    ln -s  "${OPEN_TREE_WEBAPP_ROOT}" . || exit
fi


chown -R "$VAGRANT_USERNAME" "${OPEN_TREE_ROOT}"
chown "$VAGRANT_USERNAME" "${VAGRANT_HOME_DIR}/opentree-shell.sh"
chown "$VAGRANT_USERNAME" ${VAGRANT_HOME_DIR}/.bashrc.BAK
chown "$VAGRANT_USERNAME" ${VAGRANT_HOME_DIR}/.bashrc
chown -R "$VAGRANT_USERNAME" ${VAGRANT_HOME_DIR}/.cache 
chown -R "$VAGRANT_USERNAME" ${VAGRANT_HOME_DIR}/.m2
chown -R "$VAGRANT_USERNAME" "${TAXOMACHINE_NEO4J_HOME}"
chown -R "$VAGRANT_USERNAME" "${TREEOMACHINE_NEO4J_HOME}"
