#!/bin/sh
if test -z ${OPEN_TREE_ROOT}
then
    echo OPEN_TREE_ROOT must be in your env to find the tree machine jar.
    exit 1
fi
cd "$OPEN_TREE_ROOT/opentree-testrunner"
sh run_phylografter_tests.sh
