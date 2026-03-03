# ClawbotOS

A pre-built Armbian-based operating system for **Yumi Lab Smart Pi One** and **SmartPad** boards, providing a ready-to-use AI assistant with web dashboard, module system, and cloud connectivity.

## What's Included

| Component | Port | Description |
|-----------|------|-------------|
| **[PicoClaw](https://github.com/sipeed/picoclaw)** | 8080 | Lightweight AI agent (Go, by Sipeed) — OpenAI-compatible API |
| **[ClawbotCore](https://github.com/Yumi-Lab/clawbot-core)** | 8090 | Module registry, tool loop orchestrator, cloud heartbeat |
| **[ClawbotCore WebUI](https://github.com/Yumi-Lab/ClawbotCore-WebUI)** | 80 | Static web dashboard (chat, monitoring, module management) |
| **nginx** | 80 | Reverse proxy + static file server |
| **System Status API** | 8089 | Service health, metrics |

## Supported Boards

| Board | SoC | RAM | Display | Base OS |
|-------|-----|-----|---------|---------|
| **Smart Pi One** | Allwinner H3 | 1 GB | Headless | Debian 12 Bookworm |
| **SmartPad** | Allwinner H3 | 1 GB | Touchscreen | Debian 13 Trixie |

## Quick Start

### 1. Flash the Image

Download the latest `.img.xz` from [Actions Artifacts](../../actions) or [Releases](../../releases), then flash it to your SD card:

```bash
# Using Balena Etcher (recommended) or:
xz -d ClawbotOS-*.img.xz
sudo dd if=ClawbotOS-*.img of=/dev/sdX bs=4M status=progress
```

### 2. First Boot

Insert the SD card and power on. The first-boot wizard will:
1. Create a 2 GB swap file
2. Register the device with the OpenJarvis cloud (optional)
3. Ask for your LLM API key or subscription key
4. Reboot to apply settings

### 3. Access the Dashboard

Open your browser and go to:
- **http://clawbot.local** — ClawbotOS Dashboard (chat, monitoring, modules)
- **http://clawbot.local/api/picoclaw/** — PicoClaw API (direct)
- **http://clawbot.local/api/core/** — ClawbotCore API

### 4. SSH Access

```bash
ssh pi@clawbot.local
# Password: yumi
```

## Architecture

```
User Browser (port 80)
       |
    [nginx]
       |—————————> /                    Static Dashboard (HTML/CSS/JS)
       |—————————> /api/picoclaw/   ——> PicoClaw      :8080
       |—————————> /api/core/       ——> ClawbotCore   :8090
       |—————————> /api/system/     ——> Status API    :8089
       |
  ClawbotCore :8090
       |—— Module registry (install / enable / disable)
       |—— Tool loop orchestrator (function calling proxy)
       |—— Cloud heartbeat → openjarvis.io
       |
   PicoClaw :8080
       |
   LLM API (Anthropic Claude via OpenJarvis cloud, or direct key)
```

### OpenJarvis Cloud

ClawbotOS devices optionally connect to **[openjarvis.io](https://openjarvis.io)** for:
- Managed API key (no need to enter your own Anthropic key)
- Token quota management by subscription plan
- Remote device monitoring

| Plan | Price | Tokens/day |
|------|-------|-----------|
| Particulier | €7.99/mo | 200 000 |
| Pro | €24.99/mo | 2 000 000 |

### Module System

ClawbotCore supports installable modules that extend the AI with new tools:

```bash
# Example: list modules
curl http://clawbot.local/api/core/core/modules

# Install a module
curl -X POST http://clawbot.local/api/core/core/modules/my-module/install \
  -d '{"repo": "https://github.com/Yumi-Lab/clawbot-module-example"}'
```

Modules expose **OpenAI function-calling tools** that PicoClaw can invoke autonomously during conversations.

## WiFi Configuration

Edit `/boot/network_config.txt.template`:

1. Rename to `/boot/network_config.txt`
2. Set `NC_net_wifi_enabled=1`
3. Enter your WiFi SSID and password
4. Reboot

## Memory Optimization (1 GB RAM)

- 2 GB swap file (created on first boot)
- Armbian zram disabled
- Aggressive sysctl tuning (`vm.swappiness=60`, `vm.vfs_cache_pressure=200`)
- Static dashboard (0 MB RAM overhead)

## Build System

Uses [CustomPiOS (Yumi fork)](https://github.com/Maxime3d77/CustomPiOS-Yumi) with modular shell scripts.

### Module Chain

```
base(
  udev_fix,
  armbian(
    armbian_net,      # Network configuration
    clawbot,          # Branding, hostname, mDNS (clawbot.local)
    swap_setup,       # 2 GB swap + sysctl tuning
    picoclaw,         # PicoClaw v0.2.0 binary + systemd service
    nginx_proxy,      # Reverse proxy + static dashboard
    [smartpad],       # SmartPad only: touchscreen support, Plymouth theme
    clawbot_core,     # ClawbotCore middleware + cloud heartbeat
    telegram_bot,     # Telegram bridge (optional)
    clawbot_wizard    # First-boot setup wizard
  )
)
```

### CI/CD

GitHub Actions builds images automatically on push to `develop`.
The workflow resolves the latest SmartPi-armbian base image, builds, compresses and uploads the `.img.xz` artifact.

```
develop branch push → resolve base image → build chroot → compress → upload artifact
```

## Credits

- [YumiOS](https://github.com/Yumi-Lab/YumiOS) — Original OS architecture
- [CustomPiOS](https://github.com/Maxime3d77/CustomPiOS-Yumi) — Build framework
- [PicoClaw](https://github.com/sipeed/picoclaw) — Lightweight AI agent by Sipeed
- [ClawbotCore](https://github.com/Yumi-Lab/clawbot-core) — Module registry & orchestrator
- [ClawbotCore WebUI](https://github.com/Yumi-Lab/ClawbotCore-WebUI) — Web dashboard

## License

BUSL-1.1 — See [LICENSE](LICENSE)
Change date 2036-03-02 → Apache 2.0
