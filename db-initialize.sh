#!/bin/bash
set -e

echo "\$1: $1"

pushd /usr/src/jasperreports-server/buildomatic
if [[ ! "$1" == "--skip-create" ]]; then
  ./js-ant create-js-db
fi
./js-ant init-js-db-ce
./js-ant import-minimal-ce
popd
