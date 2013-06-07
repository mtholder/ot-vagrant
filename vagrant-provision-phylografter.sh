#!/bin/sh
if test -z "${WEB2PY_DB_PASSWD}" \
        -o -z "${WEB2PY_DB_USER}" \
        -o -z "${OPEN_TREE_ROOT}" \
        -o -z "${OPEN_TREE_DATA_DIR}" \
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
# Install mysql and create the user accounts that the web apps will use.
####################
debconf-set-selections <<< 'mysql-serer-5.5 mysql-server/root_password password testBoxMsqlPass'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password testBoxMsqlPass'
apt-get install -y mysql-server-5.5 || exit
# this uses the shared file created from set-up-web2py-user.mysql.txt.Example in the
#   opentree-vagrant git repo
cat >/vagrant/set-up-web2py-user.mysql.txt <<ENDOFHEREDOC
CREATE USER '${WEB2PY_DB_USER}'@'localhost' IDENTIFIED BY '${WEB2PY_DB_PASSWD}' ;
CREATE database phylografter ;
GRANT ALL ON phylografter.* to '${WEB2PY_DB_USER}'@'localhost' ;
FLUSH PRIVILEGES;
ENDOFHEREDOC
mysql -u root --password=testBoxMsqlPass < /vagrant/set-up-web2py-user.mysql.txt

################################################################################
# Grab phylografter snapshot of the DB
#####################
cd  "${OPEN_TREE_ROOT/data}" || exit
if ! test -d phylografter
then
    mkdir phylografter || exit
fi
cd  "${OPEN_TREE_DATA_DIR}/phylografter" || exit
if ! test -f "${PHYLOGRAFTER_DB_DUMP_NAME}"
then
    wget "${URL_FOR_PHYLOGRAFTER_DB_DUMP}" || exit
fi

# Wrapping this is in an env var because it is slow and we don't want to do it unnecessarily...
if test -z ${PHYLOGRAFTER_DB_INSTALLED}
then
    bunzip2 -c ${OPEN_TREE_DATA_DIR}/phylografter/$PHYLOGRAFTER_DB_DUMP_NAME |  mysql --user ${WEB2PY_DB_USER} --password=${WEB2PY_DB_PASSWD} --max_allowed_packet=300M --connect_timeout=6000 phylografter || exit
    echo 'export PHYLOGRAFTER_DB_INSTALLED=1'>> /vagrant/env_with_urls.sh
fi

apt-get install -y libxml2-dev libxslt-dev || exit # lxml prereq
apt-get install -y g++ || exit # scipy prereq
apt-get install -y gfortran || exit # scipy prereq
apt-get install -y liblapack-dev || exit # scipy prereq
apt-get install -y libpng-dev || exit # matplotlib prereq
apt-get install -y libfreetype6-dev || exit # matplotlib prereq
apt-get install -y libjpeg8-dev || exit # matplotlib prereq
easy_install pyparsing==1.5.7 || exit # phylografter prereq
pip install --upgrade numpy || exit  # phylografter prereq
pip install --upgrade scipy || exit  # phylografter prereq
pip install --upgrade biopython || exit  # phylografter prereq
pip install --upgrade ipython || exit  # phylografter prereq
pip install --upgrade lxml || exit  # phylografter prereq
pip install --upgrade PIL || exit  # phylografter prereq
pip install --upgrade requests || exit  # phylografter prereq
pip install --upgrade matplotlib || exit  # phylografter prereq

cd "${PHYLOGRAFTER_ROOT}"
cat private/config.example | sed "s/password=12345/password=${WEB2PY_DB_PASSWD}/" | sed "s/user=guest/user=${WEB2PY_DB_USER}/" > private/config 

