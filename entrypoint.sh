#!/bin/sh
set -e
XRAY_VERSION="${XRAY_VERSION:-v26.10.31}"
if [ ! -x /usr/local/bin/xray ]; then
  echo "Downloading Xray-core ${XRAY_VERSION}..."
  curl -fsSL -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip"
  unzip -o /tmp/xray.zip -d /tmp/xray
  install -m 755 /tmp/xray/xray /usr/local/bin/xray
  rm -f /tmp/xray.zip
fi
PORT="${PORT:-10000}"
UUID="${UUID:?UUID env var is required}"
WS_PATH="${WS_PATH:-/ws}"
mkdir -p /etc/xray
cat > /etc/xray/config.json <<EOF
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
exec /usr/local/bin/xray run -c /etc/xray/config.json
