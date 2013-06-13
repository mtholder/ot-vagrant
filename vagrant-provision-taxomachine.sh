#!/bin/sh
if test -z "${TAXOMACHINE_ROOT}" 
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
    echo IT WILL OVERWRITE your taxomachine configuration files.
    exit 1
fi

set -x

apt-get install -y openjdk-7-jdk || exit
apt-get install -y maven || exit

cd "${TAXOMACHINE_ROOT}" || exit
sh mvn_install_forester.sh || exit
sh mvn_cmdline.sh || exit
# read in the ott2.0 into the taxomachine
java -Xmx10g \
     -XX:-UseConcMarkSweepGC \
     -Dopentree.taxomachine.num.transactions=1000 \
     -jar target/taxomachine-0.0.1-SNAPSHOT-jar-with-dependencies.jar \
     loadtaxsyn \
     ott \
     "$OPEN_TREE_DATA_DIR/ott/$OTT_WITH_VERSION_NAME/taxonomy" \
     "$OPEN_TREE_DATA_DIR/ott/$OTT_WITH_VERSION_NAME/synonyms" \
     "$TAXOMACHINE_NEO4J_HOME/data/ott.db"
sh mvn_serverplugins.sh || exit