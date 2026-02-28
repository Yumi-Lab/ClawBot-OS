# ClawbotOS

A pre-built Armbian-based operating system for **Yumi Lab Smart Pi One** and **SmartPad** boards, providing a ready-to-use AI assistant with a web dashboard.

Built with the same architecture as [YumiOS](https://github.com/Yumi-Lab/YumiOS), but replacing the 3D printer stack (Klipper/Moonraker/Mainsail) with an AI assistant stack.

## What's Included

| Component | Description | RAM Usage |
|-----------|-------------|-----------|
| **[PicoClaw](https://github.com/sipeed/picoclaw)** | Ultra-lightweight AI agent (Go, by Sipeed) | ~10MB |
| **[OpenClaw](https://github.com/openclaw/openclaw)** | Full-featured AI agent (Node.js) | ~500MB |
| **ClawbotOS Dashboard** | Static web dashboard with chat, monitoring, config | ~0MB (nginx) |
| **nginx** | Reverse proxy + static file server on port 80 | ~5MB |

PicoClaw is active by default. OpenClaw is installed but disabled. Both connect to external LLM APIs (OpenAI, Anthropic, OpenRouter, DeepSeek, Ollama, etc.).

## Supported Boards

- **Smart Pi One** - Allwinner H3, 1GB RAM (headless)
- **SmartPad** - Allwinner H3, 1GB RAM + touchscreen

## Quick Start

### 1. Flash the Image

Download the latest `.img.xz` from [Releases](../../releases), then flash it to your SD card:

```bash
# Using Balena Etcher (recommended) or:
xz -d ClawbotOS-*.img.xz
sudo dd if=ClawbotOS-*.img of=/dev/sdX bs=4M status=progress
```

### 2. First Boot

Insert the SD card and power on. The first-boot wizard will:
1. Create a 2GB swap file
2. Ask for your LLM provider and API key
3. Let you choose between PicoClaw (recommended) and OpenClaw
4. Reboot to apply settings

### 3. Access the Dashboard

Open your browser and go to:
- **http://clawbot.local** - ClawbotOS Dashboard (chat, monitoring, config)
- **http://clawbot.local:8080** - PicoClaw API (direct)

### 4. SSH Access

```bash
ssh pi@clawbot.local
# Password: yumi
```

## WiFi Configuration

Edit `/boot/network_config.txt.template`:

1. Rename to `/boot/network_config.txt`
2. Set `NC_net_wifi_enabled=1`
3. Enter your WiFi SSID and password
4. Reboot

## Agent Switching

```bash
# Switch to OpenClaw (full-featured, ~500MB RAM)
sudo clawbot-switch-agent openclaw

# Switch back to PicoClaw (lightweight, ~10MB RAM)
sudo clawbot-switch-agent picoclaw

# Check status
sudo clawbot-switch-agent status
```

## Architecture

```
User Browser (port 80)
       |
    [nginx]  -----> /             --> Static Dashboard (HTML/CSS/JS)
       |     -----> /api/picoclaw --> PicoClaw   (:8080)
       |     -----> /api/openclaw --> OpenClaw   (:8081)
       |
  PicoClaw / OpenClaw
       |
   External LLM API
  (OpenAI, Claude, etc.)
```

The dashboard is a static single-page application served directly by nginx. It communicates with the active AI agent via the `/api/` endpoints. No heavy Python/Node.js UI server needed.

## Memory Optimization (1GB RAM)

- 2GB swap file (created on first boot)
- Armbian zram disabled
- Aggressive sysctl tuning (`vm.swappiness=60`, `vm.vfs_cache_pressure=200`)
- systemd MemoryMax limits per service
- Only one AI agent active at a time (`Conflicts=` directive)
- Static dashboard (0 MB RAM overhead vs ~800MB for Open WebUI)

## Build System

Uses [CustomPiOS](https://github.com/Maxime3d77/CustomPiOS-Yumi) with modular shell scripts.

### Module Chain

```
base -> udev_fix -> armbian (
    armbian_net,
    clawbot,        # Branding, hostname, mDNS
    swap_setup,     # 2GB swap + sysctl tuning
    picoclaw,       # PicoClaw binary + systemd
    openclaw,       # OpenClaw + Node.js (disabled)
    nginx_proxy,    # Reverse proxy + static dashboard
    [smartpad],     # SmartPad only: touchscreen, Plymouth
    clawbot_wizard  # First-boot setup wizard
)
```

### Build Locally

```bash
# Requires ARM host or QEMU
git clone https://github.com/Yumi-Lab/clawbot.git
cd clawbot/src
sudo bash -x ./build_dist
```

### CI/CD

GitHub Actions builds images automatically on push to `develop`. See `.github/workflows/BuildImages.yml`.

## Credits

- [YumiOS](https://github.com/Yumi-Lab/YumiOS) - Original OS architecture
- [MainsailOS](https://github.com/mainsail-crew/MainsailOS) - Upstream project
- [CustomPiOS](https://github.com/guysoft/CustomPiOS) - Build framework
- [PicoClaw](https://github.com/sipeed/picoclaw) - Lightweight AI agent by Sipeed
- [OpenClaw](https://github.com/openclaw/openclaw) - Full-featured AI agent

## License

GPL-3.0 - See [LICENSE](LICENSE)
