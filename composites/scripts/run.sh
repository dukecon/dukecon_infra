#!/bin/bash

set -eu

set -o pipefail

dir=`dirname $0`

modulesdir=/vagrant/modules
test -d ${modulesdir} || modulesdir=${dir}/../../modules

compositesdir=/vagrant/composites
test -d ${compositesdir} || compositesdir=${dir}/..

for comp in "$*"
do
    echo '************************************************************'
    echo "Applying '${comp}'"
    echo '************************************************************'
    modules=`grep -v '^#' ${compositesdir}/lists/${comp}`

    for module in ${modules}
    do
        ${modulesdir}/${module}/scripts/init.sh
    done
done

