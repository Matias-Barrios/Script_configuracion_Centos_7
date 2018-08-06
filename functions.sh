#/bin/bash

function Parse_value() {
    if [[ -z $1 ]] || [[ -z $2 ]]
    then
        echo ""
        return
    fi

    if [[ "$1" =~ '=' ]]
    then
        echo ""
        return
    fi

    echo "$2" | grep -E "^${1}[ ]*=" | tail -1 | sed -E "s/^([^=]+)(=)([ ]*)([^ ]+)([ ]*)/\4/g"

}

