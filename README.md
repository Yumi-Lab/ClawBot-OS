# ClawbotOS

A pre-built Armbian-based operating system for **Yumi Lab Smart Pi One** and **SmartPad** boards, providing a ready-to-use AI assistant with web dashboard, module system, and cloud connectivity.

## What's Included

| Component | Port | Description |
|-----------|------|-------------|
| **[ClawbotCore](https://github.com/Yumi-Lab/clawbot-core)** | 8090 | AI orchestrator, module registry, tool loop, cloud heartbeat |
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
       |—————————> /api/core/       ——> ClawbotCore   :8090
       |—————————> /api/system/     ——> Status API    :8089
       |
  ClawbotCore :8090
       |—— AI orchestrator (LLM tool loop, function calling)
       |—— Module registry (install / enable / disable)
       |—— Cloud heartbeat → openjarvis.io
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

Modules expose **OpenAI function-calling tools** that ClawbotCore can invoke autonomously during conversations.

## LLM Configuration

### Option 1 — Clawbot Cloud Subscription (recommended)

Link your device on [openjarvis.io](https://openjarvis.io) — the subscription key is pushed automatically.
No manual configuration needed.

### Option 2 — Anthropic API key (direct)

Go to **Settings** in the dashboard:

1. Select **Anthropic (Claude) — Recommended**
2. Enter your `sk-ant-api03-...` key
3. Choose a model (default: `claude-sonnet-4-6`)
4. Click **Save & Apply** — ClawbotCore restarts automatically

Or via SSH terminal:

```bash
ssh pi@clawbot.local   # password: yumi

# Write config directly
sudo python3 - <<'EOF'
import json, os
cfg = {
  "gateway": {"host": "0.0.0.0", "port": 8080},
  "agents": {"defaults": {"model": "default", "workspace": "~/.clawbot/workspace",
                           "max_tokens": 4096, "temperature": 0.7}},
  "model_list": [{
    "model_name": "default",
    "model": "claude-sonnet-4-6",
    "api_key": "sk-ant-api03-YOUR_KEY_HERE",
    "base_url": "https://api.anthropic.com/v1",
    "request_timeout": 120
  }],
  "channels": {"maixcam": {"enabled": True, "host": "127.0.0.1", "port": 18790,
                             "allow_from": [], "reasoning_channel_id": ""}},
  "tools": {"web": {"duckduckgo": {"enabled": True, "max_results": 5}}},
  "log_level": "info"
}
os.makedirs('/home/pi/.clawbot', exist_ok=True)
with open('/home/pi/.clawbot/config.json', 'w') as f:
    json.dump(cfg, f, indent=2)
print('Config written.')
EOF

sudo systemctl restart clawbot-core
```

### Option 3 — OpenAI, DeepSeek, OpenRouter, Ollama

Same procedure — select the provider in Settings, enter the key, save.

### Test the AI (curl)

```bash
# From your computer (replace with the Pi IP)
curl http://clawbot.local/api/core/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"default","messages":[{"role":"user","content":"Hello, what can you do?"}]}'

# From the Pi itself (SSH)
curl http://127.0.0.1:8090/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}'
```

### How ClawbotCore uses the LLM

```
Chat request → ClawbotCore (:8090)
    → injects available module tools (function calling)
    → calls LLM API directly (for OpenAI-compatible providers)
    → executes tool_calls returned by the LLM
    → checks for mid-stream injected follow-up messages
    → loops until final answer
    → returns OpenAI-compatible response
```

### Mid-Stream Message Injection

ClawbotCore supports **real-time follow-up injection** during active AI conversations — a feature unique to ClawBot, not found in open-source alternatives like Open WebUI.

While the AI is working (tool calls, streaming response), you can send additional messages that get **injected directly into the active tool loop**. The LLM sees your follow-up at the next round and adjusts its response accordingly — just like correcting someone mid-sentence.

```bash
# Inject a follow-up into an active streaming session
curl -X POST http://clawbot.local/api/core/v1/chat/inject \
  -H "Content-Type: application/json" \
  -d '{"session_id": "your-session-id", "content": "actually, do it in Chinese"}'
```

Works across all channels: **web dashboard**, **WhatsApp**, and **cloud tunnel**.

ClawbotCore reads the LLM config from `/home/pi/.clawbot/config.json`.
Changing it in Settings restarts the service automatically.

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
- [ClawbotCore](https://github.com/Yumi-Lab/clawbot-core) — AI orchestrator & module registry
- [ClawbotCore WebUI](https://github.com/Yumi-Lab/ClawbotCore-WebUI) — Web dashboard

## License

BUSL-1.1 — See [LICENSE](LICENSE)
Change date 2036-03-02 → Apache 2.0
