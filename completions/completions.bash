#!/usr/bin/env bash

function _wikiman_completions()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-q -a -p -k -c -R -S -W -v -h"

    if [[ ${cur} == -* ]] ; then
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        return 0
    fi

    case ${prev} in
        -W)
            COMPREPLY=($(compgen -W "bash zsh" -- ${cur}));;
        *)
            COMPREPLY=($(compgen -W "${opts}" -- ${cur}));;
    esac

}

complete -F _wikiman_completions wikiman
