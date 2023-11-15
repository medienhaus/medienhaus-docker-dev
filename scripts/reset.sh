#!/usr/bin/env bash

set -euo pipefail

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

docker compose down

rm -rf data/etherpad

#rm -rf data/lldap

rm -rf data/matrix-synapse

rm -rf data/spacedeck

docker compose up -d --build --force-recreate --wait

./scripts/init.sh

docker compose up -d --force-recreate medienhaus-spaces --wait

printf "\n-- %s --\n\n" "$0: finished successfully"
