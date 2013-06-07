#!/bin/sh
if test -z "${TAXOMACHINE_ROOT}" 
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
    echo IT WILL OVERWRITE your taxomachine configuration files.
    exit 1
fi

set -x

apt-get install -y openjdk-7-jdk || exit
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386 || exit
echo 'export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386' >> /home/vagrant/opentree-shell.sh || exit
apt-get install -y maven || exit

cd "${TAXOMACHINE_ROOT}" || exit
sh mvn_install_forester.sh || exit
sh mvn_cmdline.sh || exit

sh mvn_serverplugins.sh || exit