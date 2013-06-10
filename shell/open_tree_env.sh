#!/bin/sh
export TREE_NEO4J_HOME="${OPEN_TREE_ROOT}/neo4j-community-1.9.M05-treemachine"
export TAXO_NEO4J_HOME="${OPEN_TREE_ROOT}/neo4j-community-1.9.M05-taxomachine"
export OPEN_TREE_INSTALL_DIR="${OPEN_TREE_ROOT}/install"
export OPEN_TREE_BIN_DIR="${OPEN_TREE_INSTALL_DIR}/bin"
export OPEN_TREE_LIB_DIR="${OPEN_TREE_INSTALL_DIR}/lib"
export PATH="${OPEN_TREE_BIN_DIR}:${PATH}"
export LD_LIBRARY_PATH="${OPEN_TREE_LIB_DIR}/ncl:${OPEN_TREE_LIB_DIR}:${LD_LIBRARY_PATH}"
export JAVA_OPTS='-Xms384M -Xmx1024M -XX:MaxPermSize=256M'

_treemachine()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    if test $prev = "treemachine"
    then
        # if the previous word was treemachine, prompt with the commands
        COMPREPLY=( $(compgen -W "addnewick addnexson reprocess deletetrees jsgol fulltree fulltree_sources fulltreelist mrpdump graphml csvdump justtrees sourceexplorer sourcepruner listsources biparts mapsupport getlicanames counttips diversity labeltips getupdatedlist" -- $cur))
    else
        #otherwise do file completion.  Which seems tougher than it should be...
        COMPREPLY=()
        if test "${cur:0:1}" = '$'
        then
            if test $(expr match "${cur}" ".*/.*") -eq 0
            then
                # arg starts with env var and does not have a /
                COMPREPLY=( $(compgen -P \$ -e "${cur:1}") )
            else
                # arg starts with an env var and has path separators
                COMPREPLY=( $(compgen -o default "${cur}") )
            fi
        else
            # arg does not start with a env var. Do normal file completion
            COMPREPLY=( $(compgen -f "${cur}") )
        fi
        if test "$COMPREPLY" = "${cur}" -a -d "${cur}" -a "${cur:(-1)}" != "/"
        then
            #arg is a dir, add the / and expand on that
            COMPREPLY=( $(compgen -f "${cur}/") )
        fi
        return 0
    fi
}
complete -F _treemachine treemachine


#old stuff...
#export NCL_TOP="/Users/mholder/Documents/projects/open-tree/bootstrap-open-tree-software/ncl"
#export CLASSPATH="${NEO4J_HOME}/plugins"
#export OTTOL_ROOT="${OPEN_TREE_SOURCE_DIR}/ottol"
#export OTTOL_TAXONOMY="${OTTOL_ROOT}/OTToL4taxomachine.txt"
#export PATH="${OTTOL_ROOT}/scripts:${PATH}"
export GBIF_PARENT="${OPEN_TREE_ROOT}/taxonomy/input/gbif"
#export GBIF_TAXA=$GBIF_PARENT/taxon.txt
