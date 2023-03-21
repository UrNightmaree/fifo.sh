#!/usr/bin/env bash
# @name fifo.sh
# @brief An implementation of FIFO without using `mkfifo`
# @description
#   fifo.sh is an implementation of FIFO without using `mkfifo` which sometimes can be annoying to use.
#
#   To use fifo.sh, you need at least Bash 4.3+ and coreutils.

# @description Creates a FIFO object (an associative array)
#
# @arg $1 string FIFO object variable name
# @arg $@ any Any data to be passed into FIFO
#
# @example
#   fifo_new myfifo data1 data2 data3
fifo_new() {
    local name="$1"; shift

    declare -gA "$name"
    local -n FIFO_OBJ="$name"

    declare -ga "_${name}_data"; local -n FIFO_OBJ_DATA="_${name}_data"
    FIFO_OBJ['data']="_${name}_data"
    FIFO_OBJ['head']=1
    FIFO_OBJ['tail']=0
    FIFO_OBJ['empty']=fifo_empty_default

    for v in "$@"; do
        FIFO_OBJ['tail']=$(( FIFO_OBJ['tail'] + 1 ))
        FIFO_OBJ_DATA+=("$v")
    done
}

fifo_empty_default() {
    >&2 echo "fifo.sh: FIFO is empty!"
    exit 1
}

# @description Get length of a FIFO
#
# @arg $1 FIFO-object A FIFO object
#
# @stdout Length of the FIFO
#
# @example
#   fifo_length myfifo #=> 3
fifo_length() {
    # shellcheck disable=SC2178 # it's a nameref
    local -n FIFO_OBJ="$1"
    
    echo $(( FIFO_OBJ['tail'] - FIFO_OBJ['head'] + 1 ))
}

# @description Get data from FIFO without removing it from the FIFO
#
# @arg $1 FIFO-object A FIFO object
# @arg $2 integer? Index of FIFO data, defaults to 1
#
# @stdout Value of data
#
# @example
#   fifo_peek myfifo   #=> data1
#   fifo_peek myfifo 3 #=> data3
fifo_peek() {
    # shellcheck disable=SC2178 # it's a nameref
    local -n FIFO_OBJ="$1"
    local n=$(( ${2:-1} - 1 ))

    local index=$(( FIFO_OBJ['head'] - 1 + n ))
    if (( index > FIFO_OBJ['tail'] )); then
        return 1
    else
        # shellcheck disable=SC2178
        local -n FIFO_OBJ_DATA="${FIFO_OBJ['data']}"
        echo "${FIFO_OBJ_DATA[$index]}"
    fi

}

# @description Push value into FIFO
#
# @arg $1 FIFO-object A FIFO object
# @arg $2 any Any value to be pushed
#
# @example
#   fifo_push myfifo data4
fifo_push() {
    # shellcheck disable=SC2178 # it's a nameref
    local -n FIFO_OBJ="$1"
    local v="$2"

    FIFO_OBJ['tail']=$(( FIFO_OBJ['tail'] + 1 ))
    # shellcheck disable=SC2178
    local -n FIFO_OBJ_DATA="${FIFO_OBJ['data']}"
    FIFO_OBJ_DATA+=("$v")
}

# @description Pop a data inside FIFO
#
# @arg $1 FIFO-object A FIFO object
#
# @stdout Value of the data
#
# @example
#   fifo_pop myfifo #=> data4
fifo_pop() {
    # shellcheck disable=SC2178 # it's a nameref
    local -n FIFO_OBJ="$1"
    # shellcheck disable=SC2178
    local -n FIFO_OBJ_DATA="${FIFO_OBJ['data']}"

    local head="${FIFO_OBJ['head']}" tail="${FIFO_OBJ['tail']}"

    if (( head > tail )); then
        "${FIFO_OBJ['empty']}"
        return 1
    fi

    local v="${FIFO_OBJ_DATA[$(( head - 1 ))]}"
    FIFO_OBJ_DATA["$(( head - 1 ))"]=''
    # shellcheck disable=SC2206 # refresh array index
    FIFO_OBJ_DATA=(${FIFO_OBJ_DATA[*]})
    FIFO_OBJ['head']=$(( FIFO_OBJ['head'] + 1 ))
    echo "$v"
}

# @description Insert value into FIFO with custom index
#
# @arg $1 FIFO-object A FIFO object
# @arg $2 integer Index to be inserted
# @arg $3 any Any value to be inserted at index
#
# @example
#   fifo_insert myfifo 10 data-custom
fifo_insert() {
    # shellcheck disable=SC2178
    local -n FIFO_OBJ="$1"
    # shellcheck disable=SC2178
    local -n FIFO_OBJ_DATA="${FIFO_OBJ['data']}"

    local n="$2" v="$3"

    local head="${FIFO_OBJ['head']}" tail="${FIFO_OBJ['tail']}"

    if (( n <= 0 || head + n > tail + 2 )); then
        echo "fifo.sh: bad index to fifo_insert"
        return 1
    fi

    local p=$(( (head - 1) + n - 1 ))
    if [[ "$p" -le "$(( (head + tail)/2 ))" ]]; then
        for i in $(seq "$head" "$p"); do
            FIFO_OBJ_DATA[i-1]="${FIFO_OBJ_DATA[$i]}"
        done
        FIFO_OBJ_DATA[p-1]="$v"
        FIFO_OBJ['head']=$(( FIFO_OBJ['head'] - 1 ))
    else
        for i in $(seq "$tail" -1 "$p"); do
            FIFO_OBJ_DATA[i]="${FIFO_OBJ_DATA[$((i-1))]}"
        done
        FIFO_OBJ_DATA[p]="$v"
        FIFO_OBJ['tail']=$(( FIFO_OBJ['tail'] + 1 ))
    fi
}

# @description Remove data from FIFO at index
#
# @arg $1 FIFO-object A FIFO object
# @arg $2 integer Index to be remkved
#
# @stdout The value of the removed data
#
# @example
#   fifo_remove myfifo 10 #=> data-custom
fifo_remove() {
    # shellcheck disable=SC2178 # it's a nameref
    local -n FIFO_OBJ="$1"
    # shellcheck disable=SC2178
    local -n FIFO_OBJ_DATA="${FIFO_OBJ['data']}"

    local n="$2"
    
    if (( n <= 0 )); then
        echo "bad index to fifo_remove"
        return 1
    fi

    local p=$(( head + n - 1 ))
    local v="${FIFO_OBJ_DATA[$p]}"

    if [[ "$p" -le "$(( (head + tail)/2 ))" ]]; then
        for i in $(seq "$p" -1 "$head"); do
            FIFO_OBJ_DATA[i]="${FIFO_OBJ_DATA[$((i-1))]}"
        done
        FIFO_OBJ['head']=$(( FIFO_OBJ['head'] + 1 ))
    else
        for i in $(seq "$p" "$tail"); do
            FIFO_OBJ_DATA[i]="${FIFO_OBJ_DATA[$((i+1))]}"
        done
        FIFO_OBJ['tail']=$(( FIFO_OBJ['tail'] - 1 ))
    fi

    echo "$v"
}

# @description Set empty function
#
# @arg $1 FIFO-object A FIFO object
# @arg $2 function Function to be executed when empty
fifo_setempty() {
    # shellcheck disable=SC2178
    local -n FIFO_OBJ="$1"
    local fn="$2"

    FIFO_OBJ['empty']="$fn"
}

# @description fifo.sh version
declare -r FIFO_VERSION="fifo.sh 0.1"

export -f fifo_new
export -f fifo_peek
export -f fifo_push
export -f fifo_pop
export -f fifo_length
export -f fifo_insert
export -f fifo_remove
export -f fifo_setempty
export -f fifo_empty_default
export FIFO_VERSION
