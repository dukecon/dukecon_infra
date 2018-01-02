#!/bin/bash

set +e
set -u

if test -r ~/.vagrantenv; then
    cp -p ~/.vagrantenv .
    source ./.vagrantenv
else
    rm -f ./.vagrantenv
fi

cmd=up
test $# -gt 0 && cmd=$1 && shift

exec vagrant ${cmd} "$@"
