#!/usr/bin/env bash

if [ -z "$TODOFILE" ]; then
    TODOFILE=".dodo-todos"
fi

_err_cannot_find_todos_file(){
    echo "ERR: cannot list todos because $TODOFILE is missing in this folder."
}

_new(){
    if [ ! -e $TODOFILE ]; then
        echo "{\"todos\":[]}" > $TODOFILE
    fi

    cat $TODOFILE | jq \
        --arg dt "$(date +%Y-%m-%d)" \
        --arg tt "$(echo $@)" \
        '.todos += [{date: $dt, title: $tt}]' > $TODOFILE
}

_list(){
    if [ ! -f $TODOFILE ]; then
        _err_cannot_find_todos_file
        return 1
    fi

    cat $TODOFILE | jq -j '.todos[].title + "\n"'
}

_main(){
    local cmd=$1

    # I assume users want to add a new item when first argument contains the word
    # followed by more words. But if their args is just the word "list" then I
    # assume users want to see a list of added todos.
    if [ $cmd = "list" ] && [ ! -z $2 ]; then
        cmd="new"
    fi

    # if args are empty, expect the list of todos
    if [ -z "$cmd" ]; then
        cmd="list"
    fi

    case $cmd in 
        n|new)
            _new $@
        ;;
        l|list)
            _list
        ;;
        *)
            _new $@
            exit
    esac
}