#!/usr/bin/env bash

set -euo pipefail

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

# -- make sure the docker composition is shut down -----------------------------

docker compose down

# -- remove previously stored data of various services -------------------------

rm -rf data/etherpad

#rm -rf data/lldap

rm -rf data/matrix-synapse

rm -rf data/spacedeck

# -- start docker composition, and make sure to build and force-recreate -------

docker compose up -d --build --force-recreate --wait

# -- run the initialisation script; see comments in the script itself ----------

./scripts/init.sh

# -- re-build and force-recreate medienhaus-spaces after initialisation --------

docker compose up -d --build --force-recreate --wait medienhaus-spaces

printf "\n-- %s --\n\n" "$0: finished successfully"
