<img src="./public/favicon.svg" width="70" />

### medienhaus/

Customizable, modular, free and open-source environment for decentralized, distributed communication and collaboration without third-party dependencies.

[Website](https://medienhaus.dev/) — [Mastodon](https://chaos.social/@medienhaus)

<br>

# medienhaus-docker-dev

This repository contains our Docker composition for a containerized runtime environment of [medienhaus-spaces](https://github.com/medienhaus/medienhaus-spaces/) including [matrix-synapse](https://github.com/matrix-org/synapse/), [element-web](https://github.com/vector-im/element-web/), [etherpad-lite](https://github.com/ether/etherpad-lite/), [spacedeck-open](https://github.com/medienhaus/spacedeck-open/), and [lldap](https://github.com/lldap/lldap).

<br>

## Instructions

0. `git clone` the `medienhaus-docker-dev` repository and change directory
   <br>
   ```
   git clone https://github.com/medienhaus/medienhaus-docker-dev.git && \
   cd medienhaus-docker-dev/
   ```

1. fetch contents of submodules
   <br>
   ```
   git submodule update --init
   ```

2. start docker composition and initialise `medienhaus-spaces`
   <br>
   ```
   docker compose up -d --wait && \
   ./scripts/init.sh
   ```

3. set up `lldap` user account(s) via: https://ldap.spaces.local/
   - username: `admin`
   - password: `change_me`

4. open the `medienhaus-spaces` application and log in via: https://ldap.spaces.local/login
   - username: *(configured via `lldap`)*
   - password: *(configured via `lldap`)*

<br>

## Development

Hot-reloading for `medienhaus-spaces` can be started via the following command.

```
docker compose watch
```

Cancelling the watcher via `CTRL-c` will **not** stop or shut down the composition.

<br>

## Destructions — reset everything and start from scratch

```
docker compose down && \
rm -rf data/etherpad && \
rm -rf data/matrix-synapse && \
rm -rf data/spacedeck && \
docker compose up -d --build --force-recreate --wait && \
./scripts/init.sh && \
docker compose up -d --build --force-recreate --wait medienhaus-spaces
```

💥 If you want to *TAKE ALL THE SHORTCUTS YOU CAN TAKE*, run `scripts/reset.sh`.

```
./scripts/reset.sh
```

🧩 For convenience reasons, manually created `lldap` accounts are not deleted.

<br>

## URLs / Links for default setup via [OrbStack](https://github.com/orbstack/orbstack)

| Application / Service | URL / Link |
| --- | --- |
| `medienhaus-spaces` | https://spaces.local/ |
| `matrix-synapse` | https://matrix.spaces.local/ |
| `element-web` | https://element.spaces.local/ |
| `etherpad-lite` | https://etherpad.spaces.local/ |
| `spacedeck-open` | https://spacedeck.spaces.local/ |
| `lldap` | https://ldap.spaces.local/ |
| `traefik` | https://traefik.local/ |
