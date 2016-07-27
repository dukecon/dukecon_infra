#!/bin/bash

set -eu

test -d /usr/lib/jvm/java-8-oracle
/usr/lib/jvm/java-8-oracle/bin/java -version 2>&1 | grep -q 1.8