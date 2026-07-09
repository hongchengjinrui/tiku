#!/usr/bin/env bash
set -euo pipefail

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  exec docker compose "$@"
fi

if command -v docker-compose >/dev/null 2>&1; then
  exec docker-compose "$@"
fi

DOCKER_APP_RESOURCES="/Applications/Docker.app/Contents/Resources"
DOCKER_APP_COMPOSE="$DOCKER_APP_RESOURCES/cli-plugins/docker-compose"
DOCKER_APP_BIN="$DOCKER_APP_RESOURCES/bin"

if [[ -x "$DOCKER_APP_COMPOSE" ]]; then
  export PATH="$DOCKER_APP_BIN:$PATH"
  exec "$DOCKER_APP_COMPOSE" "$@"
fi

cat >&2 <<'EOF'
Docker Compose is not available.

Install Docker Desktop, start it, then retry. On macOS the project can also use:
/Applications/Docker.app/Contents/Resources/cli-plugins/docker-compose
EOF
exit 127
