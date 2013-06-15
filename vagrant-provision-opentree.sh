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
if ! test -d ${VAGRANT_HOME_DIR}
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

cd "${OPEN_TREE_WEBAPP_ROOT}"
pip install -r requirements.txt

cd "${OPEN_TREE_WEBAPP_ROOT}/webapp"
cp private/config.local private/config 
