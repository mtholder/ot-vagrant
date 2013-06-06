#!/usr/bin/env bash
# these should pro
source /vagrant/env_with_urls.sh || exit

apt-get update
apt-get install -y apache2
rm -rf /var/www
ln -fs /vagrant /var/www
apt-get install -y openjdk-7-jdk
apt-get install -y maven2

################################################################################
# Install mysql and create the user accounts that the web apps will use.
####################
debconf-set-selections <<< 'mysql-serer-5.5 mysql-server/root_password password testBoxMsqlPass'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password testBoxMsqlPass'
apt-get install -y mysql-server-5.5
# this uses the shared file created from set-up-web2py-user.mysql.txt.Example in the
#   opentree-vagrant git repo
mysql -u root --password=testBoxMsqlPass < /vagrant/set-up-web2py-user.mysql.txt

apt-get install -y git


easy_install pip
apt-get install python-setuptools

#phylografter prereqs
pip install lxml

################################################################################
# set up some helpful env vars and store them in an opentree-shell.sh file in the home
#   that you can "source" when you "vagrant ssh" into the box
####################
echo 'source /home/vagrant/env_with_urls.sh' > /home/vagrant/opentree-shell.sh
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386
echo 'export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386' >> /home/vagrant/opentree-shell.sh
export OPEN_TREE=/vagrant/open-tree
echo 'export OPEN_TREE=/vagrant/open-tree' >> /home/vagrant/opentree-shell.sh
echo 'source /home/vagrant/opentree-shell.sh' >> /home/vagrant/.bashrc

if ! test -d "${OPEN_TREE}"
then
    mkdir  "${OPEN_TREE}"
fi

################################################################################
# Grab opentree repo (main web app, smasher code that generates OTT, etc)
####################
cd "${OPEN_TREE}"
if ! test -d opentree
then
    git clone git://github.com/OpenTreeOfLife/opentree.git
fi

################################################################################
# Grab treemachine repo (code for setting up and interacting with the Graph
#   of Life)
####################
cd "${OPEN_TREE}"
if ! test -d treemachine
then
    git clone git://github.com/OpenTreeOfLife/treemachine.git
fi


################################################################################
# Grab taxomachine repo (services, such as TNRS, for dealing with OTT)
####################
cd "${OPEN_TREE}"
if ! test -d taxomachine
then
    git clone git://github.com/OpenTreeOfLife/taxomachine.git
fi

################################################################################
# Grab phylografter repo (webapp for tree ingest and name normalization)
####################
cd "${OPEN_TREE}"
if ! test -d phylografter
then
    git clone git://github.com/OpenTreeOfLife/phylografter.git
fi

################################################################################
# Grab test suite repo 
####################
cd "${OPEN_TREE}"
if ! test -d opentree-testrunner
then
    git clone git://github.com/OpenTreeOfLife/opentree-testrunner.git
fi

################################################################################
# Get the web2py web framework and set up links to phylografter and opentree
#   this is all that needs to be done to "install" those web apps into web2py
####################
cd "${OPEN_TREE}"
if ! test -d web2py
then
    git clone git://github.com/web2py/web2py.git
fi
cd web2py
git checkout R-2.4.6
cd applications 
ln -s  "${OPEN_TREE}/phylografter" .
ln -s  "${OPEN_TREE}/opentree" .


################################################################################
# Create a data dir for large files needed to bootstrap the various databases.
####################
cd "${OPEN_TREE}"
if ! test -d data
then
    mkdir data
fi

################################################################################
# Grab the open tree taxonomy (OTT) dump See docs at https://github.com/OpenTreeOfLife/opentree/wiki/Open-Tree-Taxonomy
#####################
cd  "${OPEN_TREE}/data"
if ! test -d ott
then
    mkdir ott
fi
if ! test -d ott/OTT_WITH_VERSION_NAME
then
    cd ott
    wget "${URL_FOR_OTT_DUMP}"
    tar xfvz "${OTT_WITH_VERSION_NAME}.tgz"
fi

################################################################################
# Grab phylografter ready to run...
#####################
# get a snapshot of the DB
cd  "${OPEN_TREE}/data"
if ! test -d phylografter
then
    mkdir phylografter
fi
cd  "${OPEN_TREE}/data/phylografter"
if ! test -f "${PHYLOGRAFTER_DB_DUMP_NAME}"
then
    wget "${URL_FOR_PHYLOGRAFTER_DB_DUMP}"
fi



# if ! test -f ottol_dumpv1_w_preottol_ids_uniqunames.tar.gz
# then
#     wget https://bitbucket.org/blackrim/avatol-taxonomies/downloads/ottol_dumpv1_w_preottol_ids_uniqunames.tar.gz
# fi
# if ! test -f ottol_dump_w_uniquenames_preottol_ids
# then
#     tar xf ottol_dumpv1_w_preottol_ids_uniqunames.tar.gz
# fi




# build treemachine...
#cd "${OPEN_TREE}/treemachine"
#sh mvn_cmdline.sh
