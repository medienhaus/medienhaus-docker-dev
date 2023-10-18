#!/usr/bin/env bash

set -euo pipefail

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

docker compose down

rm -rf data/

docker compose up -d --build --force-recreate --wait

sh scripts/init.sh

docker compose up -d --force-recreate medienhaus-spaces --wait

printf "\n-- %s --\n\n" "$0: finished successfully"
