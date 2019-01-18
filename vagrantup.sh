#!/bin/bash

set +e
set -u

: ${VAGRANT_PROVIDER:="virtualbox"}

if test -r ~/.vagrantenv; then
    cp -p ~/.vagrantenv .
    source ./.vagrantenv
else
    rm -f ./.vagrantenv
fi

cmd="up"
test $# -gt 0 && cmd=$1 && shift

if test "${cmd}" = "up"; then
    cmd="${cmd} --provider ${VAGRANT_PROVIDER}"
fi

exec vagrant ${cmd} "$@"
