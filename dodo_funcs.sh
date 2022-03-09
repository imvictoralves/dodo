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
        '.todos += [{date: $dt, title: $tt, status: "PENDING"}]' > $TODOFILE
}

_list(){
    if [ ! -f $TODOFILE ]; then
        _err_cannot_find_todos_file
        return 1
    fi

    cat $TODOFILE | jq -j '.todos[]| "\(.status) | \(.title)\n"'
}

_delete(){
    cat $TODOFILE | jq \
      --argjson idx "$(($1-1))" \
      'del(.todos[$idx])' > "${TODOFILE}_tmp" 

    # There is this issue with the buffer getting the content from TODOFILE
    # passing through the pipe and push the update inside file again. CRAZY STUFF!
    # Here goes a work around with a tmp file.
    mv "${TODOFILE}_tmp" $TODOFILE
}

_done(){
    cat $TODOFILE | jq -j \
      --argjson idx "$(($1-1))" \
      '(.todos[$idx].status |= "DONE")' > "${TODOFILE}_tmp" 
    mv "${TODOFILE}_tmp" $TODOFILE
}

_main(){
    local cmd=$1

    # list todos by default. if args are empty, expect the list of todos.
    if [ -z "$cmd" ]; then
        cmd="-list"
    fi

    case $cmd in 
        -list)
            _list
        ;;
        -done)
            _done $2
        ;;
        -delete)
            _delete $2
        ;;
        *)
            _new $@
            exit
    esac
}
