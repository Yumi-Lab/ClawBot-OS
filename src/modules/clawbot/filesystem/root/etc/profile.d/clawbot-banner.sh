#!/bin/bash
# ClawbotOS login banner — shows MAC, IP, and dashboard URL
_mac="$(cat /sys/class/net/eth0/address 2>/dev/null || cat /sys/class/net/wlan0/address 2>/dev/null || echo 'unknown')"
_ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
_fw="$(grep 'VERSION=' /etc/clawbot-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo '?')"
echo ""
echo "  ClawbotOS v${_fw}"
echo "  MAC: ${_mac}  IP: ${_ip:-no network}"
echo "  Web: http://${_ip:-clawbot.local}"
echo ""
unset _mac _ip _fw
