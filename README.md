# ClawbotOS

A pre-built Armbian-based operating system for **Yumi Lab Smart Pi One** and **SmartPad** boards, providing a ready-to-use AI assistant with web dashboard, multi-provider LLM routing, messaging bridges, and cloud connectivity.

## What's Included

| Component | Port | Description |
|-----------|------|-------------|
| **[ClawbotCore](https://github.com/Yumi-Lab/clawbot-core)** | 8090 | AI orchestrator — tool loop, vault, channels, cloud tunnel |
| **[ClawbotCore WebUI](https://github.com/Yumi-Lab/ClawbotCore-WebUI)** | 80 | Static web dashboard (chat, agents, monitoring, WhatsApp) |
| **[Clawbot Cloud](https://github.com/Yumi-Lab/clawbot-cloud)** | — | Cloud API — LLM proxy, device provisioning, subscriptions |
| **WhatsApp Bridge** | 3100 | Baileys 7 — WhatsApp messaging channel |
| **nginx** | 80 | Reverse proxy + static file server |
| **System Status API** | 8089 | Service health, metrics, config |

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
2. Register the device with [openjarvis.io](https://openjarvis.io) (optional)
3. Configure your default AI provider (Kimi by default)
4. Reboot to apply settings

### 3. Access the Dashboard

Open your browser and go to:
- **http://clawbot.local** — ClawbotOS Dashboard
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
       |—————> /                 Static Dashboard (HTML/CSS/JS)
       |—————> /api/core/    ——> ClawbotCore   :8090
       |—————> /api/system/  ——> Status API    :8089
       |
  ClawbotCore :8090
       |—— AI orchestrator (LLM tool loop, function calling)
       |—— Credential vault (AES-256 encrypted)
       |—— Tool registry (49 built-in + module tools)
       |—— Channels: Web, WhatsApp, Telegram, WeCom
       |—— Cloud tunnel → openjarvis.io (WebSocket)
       |
   LLM Providers
       |—— Kimi (Moonshot) ← default
       |—— Qwen (DashScope)
       |—— Claude (Anthropic)
       |—— DeepSeek, OpenAI, Ollama, OpenRouter
```

## Supported AI Providers

| Provider | Default Model | Role |
|----------|--------------|------|
| **Moonshot (Kimi)** | `kimi-for-coding` | Default — coding specialist |
| **Alibaba (Qwen)** | `qwen3.5-flash` | Budget — fast responses |
| **Anthropic (Claude)** | `claude-sonnet-4-6` | Premium — advanced reasoning |
| **DeepSeek** | `deepseek-chat` | Budget alternative |
| **OpenAI** | `gpt-4o` | Optional |
| **Ollama** | `llama3`, `mistral`... | Local / self-hosted |
| **OpenRouter** | any | Multi-model gateway |
| **Custom** | any | Any OpenAI-compatible endpoint |

### OpenJarvis Cloud

ClawbotOS devices optionally connect to **[openjarvis.io](https://openjarvis.io)** for:
- Managed API keys — no need to enter your own provider keys
- Multi-provider routing with intelligent fallback
- Token quota management by subscription plan
- Progressive throttle (speed degradation, never service cutoff)
- Remote device monitoring via WebSocket tunnel

### Module System

ClawbotCore supports installable modules that extend the AI with new tools:

```bash
# List modules
curl http://clawbot.local/api/core/core/modules

# Install a module
curl -X POST http://clawbot.local/api/core/core/modules/my-module/install \
  -d '{"repo": "https://github.com/Yumi-Lab/clawbot-module-example"}'
```

Modules expose **OpenAI function-calling tools** that ClawbotCore can invoke autonomously during conversations.

## LLM Configuration

### Option 1 — Clawbot Cloud Subscription (recommended)

Link your device on [openjarvis.io](https://openjarvis.io) — the subscription key is pushed automatically.
No manual configuration needed. The cloud handles multi-provider routing.

### Option 2 — Direct API Key

Go to **Setup** in the dashboard:

1. Select a provider (Kimi, Anthropic, Qwen, DeepSeek, OpenAI, Ollama...)
2. Enter your API key
3. Choose a model
4. Click **Apply**

### Test the AI (curl)

```bash
curl http://clawbot.local/api/core/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hello, what can you do?"}]}'
```

### How ClawbotCore uses the LLM

```
Chat request → ClawbotCore (:8090)
    → injects available tools (function calling)
    → calls LLM API (direct or via cloud proxy)
    → executes tool_calls returned by the LLM
    → checks for mid-stream injected follow-up messages
    → loops until final answer (max 15 rounds)
    → returns OpenAI-compatible SSE stream
```

### Mid-Stream Message Injection

ClawbotCore supports **real-time follow-up injection** during active AI conversations. While the AI is working (tool calls, streaming), you can send additional messages that get injected directly into the active tool loop — like correcting someone mid-sentence.

```bash
curl -X POST http://clawbot.local/api/core/v1/chat/inject \
  -H "Content-Type: application/json" \
  -d '{"session_id": "your-session-id", "content": "actually, do it in Chinese"}'
```

Works across all channels: **web dashboard**, **WhatsApp**, and **cloud tunnel**.

## Messaging Channels

| Channel | Status | Description |
|---------|--------|-------------|
| **Web** | Active | Dashboard chat — SSE streaming, tool traces |
| **WhatsApp** | Active | Baileys 7 bridge — personal or autonomous mode |
| **Telegram** | Available | Bot bridge — optional module |
| **WeCom** | Available | Enterprise WeChat bridge |

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
- stdlib-only Python core (no pip dependencies except websockets)

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
    clawbot_core,     # ClawbotCore + cloud tunnel + WhatsApp bridge
    telegram_bot,     # Telegram bridge (optional)
    clawbot_wizard    # First-boot setup wizard
  )
)
```

### CI/CD

GitHub Actions builds 4 image variants automatically on push to `develop`:
- Smart Pi One Bookworm / Trixie
- SmartPad Bookworm / Trixie

```
develop push → resolve base image → build chroot → compress → upload .img.xz
```

## Related Repositories

| Repo | Description |
|------|-------------|
| [Yumi-Lab/clawbot-core](https://github.com/Yumi-Lab/clawbot-core) | AI orchestrator — tool loop, vault, channels |
| [Yumi-Lab/ClawbotCore-WebUI](https://github.com/Yumi-Lab/ClawbotCore-WebUI) | Web dashboard — single-file SPA |
| [Yumi-Lab/clawbot-cloud](https://github.com/Yumi-Lab/clawbot-cloud) | Cloud API — LLM proxy, device management |
| [CustomPiOS (Yumi fork)](https://github.com/Maxime3d77/CustomPiOS-Yumi) | Build framework |

## License

BUSL-1.1 — See [LICENSE](LICENSE)
Change date 2036-03-02 → Apache 2.0
