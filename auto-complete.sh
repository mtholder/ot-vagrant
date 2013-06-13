
# autocompletion for treemachine commands...
_treemachine()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    if test $prev = "treemachine"
    then
        # if the previous word was treemachine, prompt with the commands
        COMPREPLY=( $(compgen -W "inittax addnewick addnexson reprocess deletetrees jsgol fulltree fulltree_sources fulltreelist mrpdump graphml csvdump justtrees sourceexplorer sourcepruner listsources biparts mapsupport getlicanames counttips diversity labeltips labeltax checktax nexson2newick synthesizedrafttree synthesizedrafttreelist extractdrafttree extractdraftsubtreefornodes addtaxonomymetadatanodetoindex makeprunedbipartstestfiles getupdatedlist" -- $cur))
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
