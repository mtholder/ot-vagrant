#!/bin/sh
if test -z "${TREEMACHINE_ROOT}" -o "${TREEMACHINE_NEO4J_HOME}"
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
    echo IT WILL OVERWRITE your treemachine configuration files.
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
if test -f "${OPEN_TREE_DATA_DIR}/ott/${OTT_WITH_VERSION_NAME}/taxonomy"
then
    # add the taxonomy
    java -Xmx10g \
        -XX:-UseConcMarkSweepGC \
        -jar target/taxomachine-0.0.1-SNAPSHOT-jar-with-dependencies.jar \
        inittax \
        "${OPEN_TREE_DATA_DIR}/taxonomy" \
        "${OPEN_TREE_DATA_DIR}/synonyms" \
        "${TREEMACHINE_NEO4J_HOME}/data/gol.db"

    # add the metadatanode
    java -Xmx10g \
        -XX:-UseConcMarkSweepGC \
        -jar target/taxomachine-0.0.1-SNAPSHOT-jar-with-dependencies.jar \
        addtaxonomymetadatanodetoindex 3 "${TREEMACHINE_NEO4J_HOME}/data/gol.db"

    cd .. 
    git clone https://bitbucket.org/blackrim/avatol_nexsons.git
    cd ${TREEMACHINE_ROOT}
    for i in $(ls $PWD/../avatol_nexsons*)
    do
        # filter for numeric file names
        if test $(basename $i) -gt 0 2>/dev/null
        then
            java -Xmx10g \
                -XX:-UseConcMarkSweepGC \
                -jar target/taxomachine-0.0.1-SNAPSHOT-jar-with-dependencies.jar \
                pgloadind "${TREEMACHINE_NEO4J_HOME}/data/gol.db" "$i"
        else
            echo Skipping non-numeric filename: $i
        fi
    done
fi
sh mvn_serverplugins.sh || exit