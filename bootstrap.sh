#!/usr/bin/env bash
set -x

source /vagrant/env_with_urls.sh || exit

apt-get update || exit
apt-get install -y apache2 || exit
rm -rf /var/www || exit
ln -fs /vagrant /var/www || exit
apt-get install -y openjdk-7-jdk || exit
apt-get install -y maven2 || exit
apt-get install -y python-dev || exit

################################################################################
# Install mysql and create the user accounts that the web apps will use.
####################
debconf-set-selections <<< 'mysql-serer-5.5 mysql-server/root_password password testBoxMsqlPass'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password testBoxMsqlPass'
apt-get install -y mysql-server-5.5 || exit
# this uses the shared file created from set-up-web2py-user.mysql.txt.Example in the
#   opentree-vagrant git repo
mysql -u root --password=testBoxMsqlPass < /vagrant/set-up-web2py-user.mysql.txt || exit

apt-get install -y git || exit


apt-get install -y python-setuptools || exit
easy_install pip || exit

################################################################################
# set up some helpful env vars and store them in an opentree-shell.sh file in the home
#   that you can "source" when you "vagrant ssh" into the box
####################
echo 'source /vagrant/env_with_urls.sh' > /home/vagrant/opentree-shell.sh || exit
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386 || exit
echo 'export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386' >> /home/vagrant/opentree-shell.sh || exit
export OPEN_TREE=/vagrant/open-tree || exit
echo 'export OPEN_TREE=/vagrant/open-tree' >> /home/vagrant/opentree-shell.sh || exit
echo 'source /home/vagrant/opentree-shell.sh' >> /home/vagrant/.bashrc || exit

if ! test -d "${OPEN_TREE}"
then
    mkdir  "${OPEN_TREE}" || exit
fi

################################################################################
# Grab opentree repo (main web app, smasher code that generates OTT, etc)
####################
cd "${OPEN_TREE}"
if ! test -d opentree
then
    git clone git://github.com/OpenTreeOfLife/opentree.git || exit
fi

################################################################################
# Grab treemachine repo (code for setting up and interacting with the Graph
#   of Life)
####################
cd "${OPEN_TREE}"
if ! test -d treemachine
then
    git clone git://github.com/OpenTreeOfLife/treemachine.git || exit
fi


################################################################################
# Grab taxomachine repo (services, such as TNRS, for dealing with OTT)
####################
cd "${OPEN_TREE}"
if ! test -d taxomachine
then
    git clone git://github.com/OpenTreeOfLife/taxomachine.git || exit
fi

################################################################################
# Grab phylografter repo (webapp for tree ingest and name normalization)
####################
cd "${OPEN_TREE}"
if ! test -d phylografter
then
    git clone git://github.com/OpenTreeOfLife/phylografter.git || exit
fi

################################################################################
# Grab test suite repo 
####################
cd "${OPEN_TREE}"
if ! test -d opentree-testrunner
then
    git clone git://github.com/OpenTreeOfLife/opentree-testrunner.git || exit
fi

################################################################################
# Get the web2py web framework and set up links to phylografter and opentree
#   this is all that needs to be done to "install" those web apps into web2py
####################
cd "${OPEN_TREE}"
if ! test -d web2py
then
    git clone git://github.com/web2py/web2py.git || exit
fi
cd web2py || exit
git checkout R-2.4.6 || exit
cd applications  || exit
if ! test -L phylografter
then
    ln -s  "${OPEN_TREE}/phylografter" . || exit
fi
if ! test -L opentree
then
    ln -s  "${OPEN_TREE}/opentree" . || exit
fi

################################################################################
# Create a data dir for large files needed to bootstrap the various databases.
####################
cd "${OPEN_TREE}"
if ! test -d data
then
    mkdir data || exit
fi

################################################################################
# Grab the open tree taxonomy (OTT) dump See docs at https://github.com/OpenTreeOfLife/opentree/wiki/Open-Tree-Taxonomy
#####################
cd  "${OPEN_TREE}/data"
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

################################################################################
# Grab phylografter ready to run...
#####################
# get a snapshot of the DB

cd  "${OPEN_TREE}/data" || exit
if ! test -d phylografter
then
    mkdir phylografter || exit
fi
cd  "${OPEN_TREE}/data/phylografter" || exit
if ! test -f "${PHYLOGRAFTER_DB_DUMP_NAME}"
then
    wget "${URL_FOR_PHYLOGRAFTER_DB_DUMP}" || exit
fi
bunzip -c $OPEN_TREE/data/phylografter/$PHYLOGRAFTER_DB_DUMP_NAME |  mysql --user tester --password=abc123 --max_allowed_packet=300M --connect_timeout=6000 phylografter || exit

# libxml2-dev and libxslt-dev are (apparently) prerequisites for installation
#       of lxml, but not detected by pip
apt-get install -y libxml2-dev libxslt-dev || exit
easy_install pyparsing==1.5.7 || exit
for module in matplotlib numpy scipy biopython ipython lxml PIL requests
do
    pip install --upgrade "$module" || exit
done
