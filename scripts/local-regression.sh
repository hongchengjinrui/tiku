#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_PID_FILE="${BACKEND_PID_FILE:-/tmp/tiku-backend.pid}"
ADMIN_PID_FILE="${ADMIN_PID_FILE:-/tmp/tiku-admin.pid}"
BACKEND_LOG="${BACKEND_LOG:-/tmp/tiku-backend.log}"
ADMIN_LOG="${ADMIN_LOG:-/tmp/tiku-admin.log}"

API_BASE_URL="${API_BASE_URL:-http://localhost:3000/api}"
ANDROID_API_BASE_URL="${ANDROID_API_BASE_URL:-http://127.0.0.1:3000/api}"
APP_KEY="${APP_KEY:-south-grid-android}"
DEV_USER_ID="${DEV_USER_ID:-dev-user-001}"
ANDROID_PACKAGE="${ANDROID_PACKAGE:-com.example.tiku_muban}"
ADMIN_PORT="${ADMIN_PORT:-5174}"

RUN_CHECKS="${RUN_CHECKS:-1}"
RUN_SMOKE="${RUN_SMOKE:-1}"
RUN_ANDROID="${RUN_ANDROID:-1}"
RUN_ADMIN="${RUN_ADMIN:-1}"
FLUTTER_BUILD_MODE="${FLUTTER_BUILD_MODE:-debug}"
BACKEND_BUILT=0

log() {
  printf '\n\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
  printf '\n\033[1;33mWARN:\033[0m %s\n' "$*" >&2
}

die() {
  printf '\n\033[1;31mERROR:\033[0m %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

kill_pid_file() {
  local pid_file="$1"
  if [[ ! -f "$pid_file" ]]; then
    return
  fi
  local pid
  pid="$(cat "$pid_file" 2>/dev/null || true)"
  if [[ -n "$pid" ]] && kill -0 "$pid" >/dev/null 2>&1; then
    kill "$pid" >/dev/null 2>&1 || true
  fi
  rm -f "$pid_file"
}

wait_for_http() {
  local url="$1"
  local name="$2"
  local retries="${3:-30}"
  for _ in $(seq 1 "$retries"); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return
    fi
    sleep 1
  done
  die "$name did not become healthy: $url"
}

free_port() {
  START_PORT="$1" python3 - <<'PY'
import os
import socket

start = int(os.environ["START_PORT"])
for port in range(start, start + 80):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        try:
            sock.bind(("127.0.0.1", port))
        except OSError:
            continue
        print(port)
        raise SystemExit(0)
raise SystemExit(1)
PY
}

first_android_device() {
  adb devices | awk 'NR > 1 && $2 == "device" { print $1; exit }'
}

run_checks() {
  if [[ "$RUN_CHECKS" != "1" ]]; then
    warn "Skipping build/analyze checks because RUN_CHECKS=$RUN_CHECKS"
    return
  fi
  log "Building backend"
  pnpm --dir "$ROOT_DIR/backend" build
  BACKEND_BUILT=1

  log "Building admin"
  pnpm --dir "$ROOT_DIR/admin" build

  log "Analyzing Flutter client"
  (cd "$ROOT_DIR/client" && flutter analyze)

  log "Running Flutter store tests"
  (cd "$ROOT_DIR/client" && flutter test test/mock_app_store_test.dart)
}

start_backend() {
  log "Starting backend API"
  if [[ "$BACKEND_BUILT" != "1" ]]; then
    pnpm --dir "$ROOT_DIR/backend" build
    BACKEND_BUILT=1
  fi
  kill_pid_file "$BACKEND_PID_FILE"
  BACKEND_CWD="$ROOT_DIR/backend" \
  BACKEND_LOG="$BACKEND_LOG" \
  BACKEND_PID_FILE="$BACKEND_PID_FILE" \
  python3 <<'PY'
import os
import subprocess

cwd = os.environ["BACKEND_CWD"]
log_path = os.environ["BACKEND_LOG"]
pid_file = os.environ["BACKEND_PID_FILE"]
log = open(log_path, "ab", buffering=0)
process = subprocess.Popen(
    ["node", "dist/main.js"],
    cwd=cwd,
    stdout=log,
    stderr=log,
    stdin=subprocess.DEVNULL,
    start_new_session=True,
)
with open(pid_file, "w", encoding="utf-8") as handle:
    handle.write(str(process.pid))
PY
  wait_for_http "$API_BASE_URL/health" "Backend"
  log "Backend ready: $API_BASE_URL"
}

run_smoke() {
  if [[ "$RUN_SMOKE" != "1" ]]; then
    warn "Skipping E2E smoke because RUN_SMOKE=$RUN_SMOKE"
    return
  fi
  log "Running backend/client/admin E2E smoke"
  API_BASE_URL="$API_BASE_URL" APP_KEY="$APP_KEY" pnpm --dir "$ROOT_DIR/backend" smoke:e2e
}

build_and_install_android() {
  if [[ "$RUN_ANDROID" != "1" ]]; then
    warn "Skipping Android install because RUN_ANDROID=$RUN_ANDROID"
    return
  fi
  require_cmd adb
  require_cmd flutter

  local device_id="${ANDROID_DEVICE_ID:-}"
  if [[ -z "$device_id" ]]; then
    device_id="$(first_android_device)"
  fi
  if [[ -z "$device_id" ]]; then
    die "No unlocked Android device is connected. Set RUN_ANDROID=0 to skip."
  fi

  log "Building Android $FLUTTER_BUILD_MODE APK for $APP_KEY"
  (
    cd "$ROOT_DIR/client"
    flutter build apk \
      --"$FLUTTER_BUILD_MODE" \
      --no-pub \
      --dart-define=API_BASE_URL="$ANDROID_API_BASE_URL" \
      --dart-define=APP_KEY="$APP_KEY" \
      --dart-define=DEV_USER_ID="$DEV_USER_ID"
  )

  local apk_path="$ROOT_DIR/client/build/app/outputs/flutter-apk/app-${FLUTTER_BUILD_MODE}.apk"
  [[ -f "$apk_path" ]] || die "APK not found: $apk_path"

  log "Preparing adb reverse on $device_id"
  adb -s "$device_id" reverse tcp:3000 tcp:3000

  log "Installing APK on $device_id"
  warn "Android install can take a minute on some devices; keep the phone unlocked."
  local remote_apk_path="/data/local/tmp/${ANDROID_PACKAGE}-${FLUTTER_BUILD_MODE}.apk"
  adb -s "$device_id" shell am force-stop "$ANDROID_PACKAGE" >/dev/null 2>&1 || true
  adb -s "$device_id" push "$apk_path" "$remote_apk_path"
  adb -s "$device_id" shell pm install -r -d -t "$remote_apk_path"
  adb -s "$device_id" shell rm -f "$remote_apk_path" >/dev/null 2>&1 || true

  log "Launching Android app"
  adb -s "$device_id" shell monkey -p "$ANDROID_PACKAGE" 1 >/dev/null
  log "Android app launched on $device_id"
}

start_admin() {
  if [[ "$RUN_ADMIN" != "1" ]]; then
    warn "Skipping admin dev server because RUN_ADMIN=$RUN_ADMIN"
    return
  fi
  require_cmd python3

  local port
  port="$(free_port "$ADMIN_PORT")"
  kill_pid_file "$ADMIN_PID_FILE"

  log "Starting admin dev server on http://localhost:$port"
  ADMIN_CWD="$ROOT_DIR/admin" \
  ADMIN_LOG="$ADMIN_LOG" \
  ADMIN_PID_FILE="$ADMIN_PID_FILE" \
  ADMIN_PORT_VALUE="$port" \
  python3 <<'PY'
import os
import subprocess

cwd = os.environ["ADMIN_CWD"]
log_path = os.environ["ADMIN_LOG"]
pid_file = os.environ["ADMIN_PID_FILE"]
port = os.environ["ADMIN_PORT_VALUE"]
log = open(log_path, "ab", buffering=0)
process = subprocess.Popen(
    ["pnpm", "exec", "vite", "--host", "0.0.0.0", "--port", port, "--strictPort"],
    cwd=cwd,
    stdout=log,
    stderr=log,
    stdin=subprocess.DEVNULL,
    start_new_session=True,
)
with open(pid_file, "w", encoding="utf-8") as handle:
    handle.write(str(process.pid))
PY
  wait_for_http "http://localhost:$port" "Admin"
  log "Admin ready: http://localhost:$port"
}

main() {
  require_cmd pnpm
  require_cmd curl
  require_cmd python3

  log "Local regression config"
  printf 'APP_KEY=%s\nDEV_USER_ID=%s\nAPI_BASE_URL=%s\nANDROID_API_BASE_URL=%s\n' \
    "$APP_KEY" "$DEV_USER_ID" "$API_BASE_URL" "$ANDROID_API_BASE_URL"

  run_checks
  start_backend
  run_smoke
  build_and_install_android
  start_admin

  log "Regression prep complete"
  printf 'Backend: %s\nAdmin log: %s\nBackend log: %s\n' \
    "$API_BASE_URL" "$ADMIN_LOG" "$BACKEND_LOG"
}

main "$@"
