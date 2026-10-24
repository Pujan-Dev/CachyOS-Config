#!/usr/bin/env bash
#
# setup-iwd — make iwd the Wi-Fi backend for NetworkManager so that
# impala (the iwd TUI) can manage Wi-Fi alongside NetworkManager.
#
# Run once with root:
#     sudo ~/.config/waybar/scripts/setup-iwd.sh
#
set -euo pipefail

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "This needs root. Run:  sudo $0" >&2
    exit 1
fi

echo "==> Pointing NetworkManager at iwd (wifi.backend=iwd)"
install -d /etc/NetworkManager/conf.d
cat >/etc/NetworkManager/conf.d/wifi_backend.conf <<'EOF'
[device]
wifi.backend=iwd
EOF

echo "==> Enabling and starting iwd"
systemctl enable --now iwd

echo "==> Restarting NetworkManager so it picks up the backend"
systemctl restart NetworkManager

echo "==> Waiting for Wi-Fi to come back…"
sleep 4
nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null | grep -E 'wifi' || true

echo
echo "Done. Wi-Fi is now driven by iwd; impala can manage it."
echo "If Wi-Fi did not reconnect, click the network icon and reconnect once."
