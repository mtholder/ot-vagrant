#!/bin/sh
if test -z "${WEB2PY_DB_PASSWD}" \
        -o -z "${WEB2PY_DB_USER}" \
        -o -z "${OPEN_TREE_ROOT}" \
        -o -z "${OPEN_TREE_DATA_DIR}" \
        -o -z "${OPEN_TREE_WEBAPP_ROOT}" \
        -o -z "${PHYLOGRAFTER_DB_DUMP_NAME}" \
        -o -z "${URL_FOR_PHYLOGRAFTER_DB_DUMP}"
then
    EXIT_WITH_ERR=1
fi
if ! test -d /home/vagrant
then
    EXIT_WITH_ERR=1
fi

if test $EXIT_WITH_ERR = 1
then
    echo Your environment is not configured correctly.
    echo IMPORTANT: this script is intended to be run from within a vagrant provisioning set-up.
    echo IT WILL OVERWRITE your phylografter configuration files.
    exit 1
fi

set -x

apt-get install -y python-dev || exit
apt-get install -y python-setuptools || exit
easy_install pip || exit


################################################################################
# Grab the open tree taxonomy (OTT) dump See docs at https://github.com/OpenTreeOfLife/opentree/wiki/Open-Tree-Taxonomy
#####################
cd  "${OPEN_TREE_DATA_DIR}"
if ! test -d ott
then
    mkdir ott
fi
if ! test -d "ott/${OTT_WITH_VERSION_NAME}"
then
    cd ott || exit
    wget "${URL_FOR_OTT_DUMP}" || exit
    tar xfvz "${OTT_WITH_VERSION_NAME}.tgz" || exit
fi


cd "${OPEN_TREE_WEBAPP_ROOT}/webapp"
cp private/config.local private/config 

################################################################################
# Grab test suite repo 
####################
cd "${OPEN_TREE_ROOT}"
if ! test -d opentree-testrunner
then
    git clone git://github.com/OpenTreeOfLife/opentree-testrunner.git || exit
fi

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
