#!/bin/sh
# This file is addresses that will change frequently to avoid frequently changing the bootstrapping scripts.
export PHYLOGRAFTER_DB_DUMP_NAME=phylografter.20130611.sql.bz2
export URL_FOR_PHYLOGRAFTER_DB_DUMP="http://reelab.net/~rree/${PHYLOGRAFTER_DB_DUMP_NAME}"
export OTT_WITH_VERSION_NAME=ott2.0
export URL_FOR_OTT_DUMP="http://dev.opentreeoflife.org/${OTT_WITH_VERSION_NAME}/${OTT_WITH_VERSION_NAME}.tgz"
export PHYLOGRAFTER_DB_INSTALLED=1
export URL_FOR_NEO4J="http://download.neo4j.org/artifact?edition=community&version=1.9&distribution=tarball&dlid=1611116"
export NEO4J_TARBALL_NAME="neo4j-community-1.9.M05-unix.tar.gz"
export NEO4J_TARBALL_UNPACKED_NAME="neo4j-community-1.9"