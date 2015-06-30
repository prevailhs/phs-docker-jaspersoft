#!/bin/bash
set -e

pushd /usr/src/jasperreports-server/buildomatic
./js-ant create-js-db
./js-ant init-js-db-ce
./js-ant import-minimal-ce
popd
