#!/bin/sh
if test -z "${TREEMACHINE_ROOT}" 
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
    echo IT WILL OVERWRITE your treemahine configuration files.
    exit 1
fi

set -x

apt-get install -y openjdk-7-jdk || exit
if true
then
     export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64 || exit
else
    export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386 || exit
fi
echo "export JAVA_HOME=\"$JAVA_HOME\"" >> ${VAGRANT_HOME_DIR}/opentree-shell.sh || exit
apt-get install -y maven || exit

cd "${TREEMACHINE_ROOT}" || exit
sh mvn_cmdline.sh || exit

sh mvn_serverplugins.sh || exit