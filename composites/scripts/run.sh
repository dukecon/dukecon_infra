#!/bin/bash

set -e

dir=`dirname $0`

modulesdir=/vagrant/modules
test -d ${modulesdir} || modulesdir=${dir}/../../modules

compositesdir=/vagrant/composites
test -d ${compositesdir} || compositesdir=${dir}/..

for comp in "$*"
do
    echo "Applying '${comp}'"
    modules=`cat ${compositesdir}/lists/${comp}`

    for module in ${modules}
    do
        ${modulesdir}/${module}/scripts/init.sh
    done
done

