#!/bin/sh
set -e

# The container runs as a non-root user, so keep the binary and the
# config file inside the app directory instead of system paths
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
XRAY_BIN="$APP_DIR/xray"
XRAY_CONFIG="$APP_DIR/config.json"

XRAY_VERSION="${XRAY_VERSION:-v26.10.31}"
if [ ! -x "$XRAY_BIN" ]; then
  echo "Downloading Xray-core ${XRAY_VERSION}..."
  curl -fsSL -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip"
  unzip -o /tmp/xray.zip -d /tmp/xray
  install -m 755 /tmp/xray/xray "$XRAY_BIN"
  rm -f /tmp/xray.zip
fi
PORT="${PORT:-10000}"
UUID="${UUID:?UUID env var is required}"
WS_PATH="${WS_PATH:-/ws}"
cat > "$XRAY_CONFIG" <<EOF
{
  "log": {"loglevel": "warning"},
  "inbounds": [
    {
      "port": ${PORT},
      "protocol": "vless",
      "settings": {"clients": [{"id": "${UUID}", "flow": ""}], "decryption": "none"},
      "streamSettings": {"network": "ws", "wsSettings": {"path": "${WS_PATH}"}}
    }
  ],
  "outbounds": [{"protocol": "freedom", "tag": "direct"}]
}
EOF
echo "Starting xray on port ${PORT} ws path ${WS_PATH}"
exec "$XRAY_BIN" run -c "$XRAY_CONFIG"
