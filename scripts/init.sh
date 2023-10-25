#!/usr/bin/env bash

set -euo pipefail

trap "printf \"\n-- %s -- \n\n\" \"$0: was interrupted\" >&2; exit 2" INT TERM

# -- register matrix-synapse account for medienhaus-* --------------------------
# -- NOTE: for now this needs to be an admin account due to ratelimit reasons --

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

# -- create root context space for medienhaus-* and retrieve room_id -----------

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

# -- write room_id to config/medienhaus-spaces.config.js -----------------------

sed "s/\(contextRootSpaceRoomId\): '.*'/\1: '${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}'/g" \
    ./config/medienhaus-spaces.config.js > ./config/medienhaus-spaces.config.tmp \
    && mv ./config/medienhaus-spaces.config.tmp ./config/medienhaus-spaces.config.js

# -- print happy little success message ----------------------------------------
#
printf "\n-- %s --\n\n" "$0: finished successfully"
