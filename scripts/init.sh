#!/usr/bin/env bash

set -euo pipefail

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

# -- register matrix-synapse account for medienhaus-spaces application ---------

docker exec matrix-synapse \
  register_new_matrix_user http://localhost:8008 \
    -c /etc/matrix-synapse/homeserver.yaml \
    --user "medienhaus-admin" \
    --password "change_me" \
    --admin

# -- retrieve access_token for created matrix-synapse account ------------------

MEDIENHAUS_ADMIN_ACCESS_TOKEN=$(docker exec -i matrix-synapse \
  curl "http://localhost:8008/_matrix/client/r0/login" \
    --silent \
    --request POST \
    --data-binary @- << EOF | sed -n 's/.*"access_token":"\([^"]*\).*/\1/p'
{
  "type": "m.login.password",
  "user": "medienhaus-admin",
  "password": "change_me"
}
EOF
)

# -- disable ratelimit for created matrix-synapse account ----------------------

docker exec -i matrix-synapse \
  curl "http://localhost:8008/_synapse/admin/v1/users/@medienhaus-admin:matrix.localhost/override_ratelimit" \
    --header "Authorization: Bearer ${MEDIENHAUS_ADMIN_ACCESS_TOKEN}" \
    --silent \
    --output /dev/null \
    --request POST \
    --data-binary @- << EOF
{
  "messages_per_second": 0,
  "burst_count": 0
}
EOF

# -- create root context space for medienhaus-spaces and retrieve room_id ------
# -- if `medienhaus-spaces/structure.json` exists, create context structure ----
#
# -- NOTE: valid context structures can be generated with `medienhaus-dev-tools`
# -- https://github.com/medienhaus/medienhaus-dev-tools ------------------------

if [[ -r medienhaus-spaces/structure.json ]]; then
  MEDIENHAUS_ROOT_CONTEXT_SPACE_ID=$(docker run \
    --name context-structure.js \
    --network=medienhaus-docker-dev_default \
    --rm \
    --volume ./medienhaus-spaces/structure.json:/opt/structure.json \
    node:lts-alpine \
      sh -c "
        wget \
          --quiet \
          --output-document=/opt/context-structure.js \
          https://raw.githubusercontent.com/medienhaus/medienhaus-dev-tools/main/cli/createStructure.js \
        && \
        node /opt/context-structure.js \
          -b \"http://matrix-synapse:8008\" \
          -s \"matrix.spaces.local\" \
          -t \"${MEDIENHAUS_ADMIN_ACCESS_TOKEN}\" \
          -f /opt/structure.json \
          -r
      "
  )
else
  MEDIENHAUS_ROOT_CONTEXT_SPACE_ID=$(docker exec -i matrix-synapse \
    curl "http://localhost:8008/_matrix/client/r0/createRoom?access_token=${MEDIENHAUS_ADMIN_ACCESS_TOKEN}" \
      --silent \
      --request POST \
      --data-binary @- << EOF | sed -n 's/.*"room_id":"\([^"]*\).*/\1/p'
{
  "name": "medienhaus/ root context",
  "preset": "private_chat",
  "visibility": "private",
  "power_level_content_override": {
    "events_default": 100,
    "invite": 50
  },
  "topic": "medienhaus/ root context — https://github.com/medienhaus/",
  "creation_content": {
    "type": "m.space"
  },
  "initial_state": [
    {
      "type": "m.room.history_visibility",
      "content": {
        "history_visibility": "world_readable"
      }
    },
    {
      "type": "dev.medienhaus.meta",
      "content": {
        "type": "context",
        "template": "context"
      }
    }
  ]
}
EOF
  )
fi

# -- write room_id to ./medienhaus-spaces/.env ---------------------------------

cat << EOF > ./medienhaus-spaces/.env.local
MEDIENHAUS_ROOT_CONTEXT_SPACE_ID=${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}
EOF

# -- print happy little success message ----------------------------------------
#
printf "\n-- %s --\n\n" "$0: finished successfully"
