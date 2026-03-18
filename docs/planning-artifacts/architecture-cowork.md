---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: 'complete'
completedAt: '2026-03-16'
inputDocuments:
  - 'docs/planning-artifacts/prd-cowork.md'
  - 'docs/planning-artifacts/prd.md'
  - 'docs/planning-artifacts/architecture.md'
  - 'docs/agents-personnalises/prd-agents-personnalises.md'
  - 'docs/brainstorming/brainstorming-session-2026-03-16-cowork.md'
workflowType: 'architecture'
project_name: 'OpenJarvis Cowork'
user_name: 'Nicolas'
date: '2026-03-16'
---

# Architecture Decision Document — OpenJarvis Cowork

_Ce document complete l'architecture globale ClawBot (docs/planning-artifacts/architecture.md) avec les decisions specifiques au module desktop Cowork._

## Analyse de Contexte Projet

### Vue d'ensemble des Requirements

**44 Functional Requirements en 7 domaines :**

| Domaine | FRs | Phase |
|---------|-----|-------|
| Connexion & Communication | CW-FR1→5 | MVP |
| Chat & Agents | CW-FR6→11 | MVP |
| Computer Use | CW-FR12→17 | MVP |
| Permissions & Securite | CW-FR18→25 | MVP/Growth |
| File Browser | CW-FR26→33 | MVP/Phase 2 |
| MCP Hub | CW-FR34→38 | MVP/Growth |
| Interface | CW-FR39→44 | MVP/Growth |

**Repartition :** 30 MVP, 10 Growth, 4 Phase 2

**NFRs critiques :**

- Performance : <2s CU LAN, <5s CU tunnel, <3s chat streaming, <3s demarrage
- Ressources : <100MB RAM repos, <300MB actif, <50MB installeur
- Securite : WSS, AES-256-GCM E2E (Growth), profil Safe herite
- Compatibilite : macOS 12+, Windows 10+, Linux Ubuntu 22.04+

### Contraintes Techniques & Dependances

1. **Boitier H3 (1GB RAM)** — cerveau IA mais ne traite PAS les screenshots. Envoie au LLM via cloud
2. **Tunnel cloud existant** — doit etre etendu pour les events Cowork (computer_use, mcp, files)
3. **Protocole WebSocket existant** — JSON `type` + `payload` + `session_id`, extensible
4. **APIs OS natives** — CoreGraphics (Mac), Win32 (Windows), X11/Wayland (Linux) pour Computer Use
5. **Architecture globale ClawBot** — 4 repos autonomes, communication WS/REST uniquement
6. **Pas de stdlib-only** — repo Cowork est Rust + TypeScript, pas Python

### Preoccupations Transversales Identifiees

1. **WebSocket lifecycle** — dual LAN/tunnel, bascule, reconnexion backoff, heartbeat
2. **Securite multi-couche** — chiffrement E2E, permissions Allow/Ask/Block, profil Safe, audit log
3. **Performance screenshots** — compression JPEG, <200KB, pipeline encode→chiffre→transmit
4. **MCP protocol** — handshake versioning, hot-reload serveurs, compatibilite N/N-1
5. **Abstraction multi-OS** — couche d'abstraction pour screenshot/input/shell par plateforme
6. **Coherence avec l'ecosysteme** — memes conventions WS, meme theme UI (dark cyan), meme auth JWT

### Echelle & Complexite

- **Domaine principal :** Desktop App cross-platform + Bridge Agent distant
- **Complexite :** High (7 composants archi majeurs, 3 OS, protocoles temps reel)
- **Composants architecturaux :** ~7 (WebSocket client, Computer Use engine, MCP hub, File browser, Security layer, Tray/UI shell, Sync engine)

## Evaluation Stack Technique

### Domaine Technologique

Desktop App cross-platform avec backend natif (acces OS) et frontend web (UI).

### Decision Cle : Tauri 2, pas Electron

| Critere | Tauri 2 | Electron |
|---------|---------|----------|
| RAM au repos | ~30-50MB | ~150-300MB |
| Taille installeur | ~10-20MB | ~80-150MB |
| Backend | Rust (natif, performant) | Node.js (lourd) |
| Acces OS natif | Via Rust crates (screenshots, input) | Via Node native addons |
| Securite | Sandbox Rust, pas de Node runtime | Node runtime = surface d'attaque |
| Cross-platform | Mac/Win/Linux | Mac/Win/Linux |
| Auto-update | Tauri updater integre | electron-updater |
| Maturite | Tauri 2 stable (2025) | Mature (2014) |

**Decision :** Tauri 2. RAM <100MB au repos, installeur <50MB, backend Rust performant pour Computer Use. Reference : Jan.ai (41k stars, Apache 2.0, meme stack Tauri + Rust + TS).

### Stack Frontend

| Decision | Choix | Rationale |
|----------|-------|-----------|
| Framework UI | **SolidJS** ou **Vanilla TS** | Leger, pas de virtual DOM overhead. Alternative : React si plus de contributeurs. Decision finale au sprint 1 |
| CSS | **TailwindCSS** | Rapide, themable, coherent avec dark cyan |
| Markdown | marked.js | Coherent avec le dashboard WebUI |
| Code highlighting | highlight.js | Coherent avec le dashboard WebUI |

### Stack Backend (Rust / src-tauri)

| Decision | Choix | Rationale |
|----------|-------|-----------|
| WebSocket client | `tokio-tungstenite` | Async, performant, standard Rust |
| Screenshots | `xcap` (crate Rust) | Cross-platform Mac/Win/Linux, MIT |
| Input simulation | `enigo` (crate Rust) | Cross-platform souris/clavier |
| Shell execution | `std::process::Command` | Stdlib Rust, pas de dependance |
| Compression images | `image` + `turbojpeg` | JPEG rapide, <200KB par capture |
| Chiffrement | `aes-gcm` (crate) | AES-256-GCM, standard, audite |
| Serialisation | `serde` + `serde_json` | Standard Rust |
| mDNS discovery | `mdns-sd` | Detection boitier en LAN |
| File watcher (Phase 2) | `notify` (crate Rust) | Cross-platform, inotify/FSEvents/ReadDirectoryChanges |

### Pas de VM

Contrairement a Claude Cowork qui utilise une VM Linux isolee (Apple VZVirtualMachine), OpenJarvis Cowork n'a PAS de VM. L'execution se fait directement sur l'OS hote. Raisons :

1. Le cerveau IA est sur le boitier distant, pas dans l'app
2. La VM Claude isole le runtime Claude Code — chez nous c'est le boitier qui isole
3. Une VM ajouterait ~2GB de taille et ~500MB de RAM
4. La securite est assuree par les permissions Allow/Ask/Block + profil Safe

## Decisions Architecturales

### Priorite des Decisions

**Critiques (bloquent l'implementation) :**
- Protocole WebSocket Cowork (events, handshake)
- Abstraction multi-OS pour Computer Use
- Architecture MCP Hub

**Importantes (faconnent l'architecture) :**
- Dual connexion LAN/tunnel
- Pipeline screenshots (compression, chiffrement)
- Systeme de permissions

**Differees (post-MVP) :**
- Sync engine Dropbox-like
- Chiffrement E2E complet
- Registre plugins MCP tiers

### Architecture Interne — Couches

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND (TypeScript)                      │
│                                                               │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌────────┐  ┌───────────┐  │
│  │ Tray │  │ Chat │  │Files │  │Computer│  │Permissions│  │
│  │Panel │  │Panel │  │Panel │  │Use View│  │  Dialogs  │  │
│  └──┬───┘  └──┬───┘  └──┬───┘  └───┬────┘  └─────┬─────┘  │
│     └──────────┴─────────┴──────────┴─────────────┘         │
│                         │ Tauri IPC                          │
├─────────────────────────┼───────────────────────────────────┤
│                    BACKEND (Rust)                             │
│                         │                                    │
│  ┌──────────────────────┴──────────────────────────────┐    │
│  │              Command Router (Tauri commands)          │    │
│  └──────────────────────┬──────────────────────────────┘    │
│                         │                                    │
│  ┌──────────┐  ┌───────┴───────┐  ┌──────────┐            │
│  │WebSocket │  │  Computer Use │  │ MCP Hub  │            │
│  │ Client   │  │   Engine      │  │          │            │
│  │          │  │               │  │ ┌──────┐ │            │
│  │ ┌──────┐│  │ ┌───────────┐ │  │ │chrome│ │            │
│  │ │ LAN  ││  │ │ Platform  │ │  │ ├──────┤ │            │
│  │ │direct││  │ │ Abstraction│ │  │ │  fs  │ │            │
│  │ ├──────┤│  │ │           │ │  │ ├──────┤ │            │
│  │ │tunnel││  │ │mac│win│lin│ │  │ │shell │ │            │
│  │ └──────┘│  │ └───────────┘ │  │ ├──────┤ │            │
│  └──────────┘  └───────────────┘  │ │plugin│ │            │
│                                    │ └──────┘ │            │
│  ┌──────────┐  ┌───────────────┐  └──────────┘            │
│  │ Security │  │  File Browser │                           │
│  │          │  │               │                           │
│  │ ┌──────┐│  │ ┌───────────┐ │                           │
│  │ │perms ││  │ │  remote   │ │                           │
│  │ ├──────┤│  │ │  browse   │ │                           │
│  │ │crypto││  │ ├───────────┤ │                           │
│  │ ├──────┤│  │ │  download │ │                           │
│  │ │audit ││  │ ├───────────┤ │                           │
│  │ ├──────┤│  │ │  sync     │ │  ← Phase 2               │
│  │ │profile│  │ └───────────┘ │                           │
│  │ └──────┘│  └───────────────┘                           │
│  └──────────┘                                              │
└────────────────────────────────────────────────────────────┘
```

### WebSocket Client — Dual Connexion

```rust
// Architecture de connexion
enum ConnectionMode {
    Lan { ip: IpAddr, port: u16 },
    Tunnel { cloud_url: String, device_id: String, jwt: String },
}

// Sequence de connexion
// 1. Tenter LAN direct (mDNS discovery ou IP sauvegardee)
// 2. Si echec apres 3s → bascule tunnel cloud
// 3. Si tunnel reussit → sauvegarder en preference
// 4. Heartbeat toutes les 30s
// 5. Si heartbeat echoue → reconnexion backoff (1s, 2s, 4s, 8s, max 30s)
// 6. Si mode tunnel et LAN redevient disponible → rester sur tunnel (pas de bascule auto)
```

**Decision :** Pas de bascule automatique tunnel → LAN. L'utilisateur bascule manuellement s'il veut. Raison : eviter les deconnexions mid-session. Le LAN est tente uniquement au demarrage ou a la reconnexion.

| Decision | Choix | Rationale |
|----------|-------|-----------|
| Protocole | WebSocket JSON (coherent ecosysteme) | Meme format que device↔cloud |
| LAN discovery | mDNS (`_clawbot._tcp`) | Zero config, standard |
| LAN fallback | IP sauvegardee dans config locale | Si mDNS echoue |
| Tunnel auth | JWT existant (HS256, 72h) | Reutilise le systeme d'auth cloud |
| Heartbeat | 30s, timeout 10s | Detecte les coupures |
| Reconnexion | Backoff exponentiel 1→30s | Standard, pas agressif |
| Compression WS | Per-message deflate (RFC 7692) | Reduit bande passante tunnel |

### Computer Use Engine — Abstraction Multi-OS

```rust
// Trait d'abstraction plateforme
trait PlatformProvider: Send + Sync {
    fn capture_screen(&self, region: Option<Rect>) -> Result<Screenshot>;
    fn move_mouse(&self, x: i32, y: i32) -> Result<()>;
    fn click(&self, button: MouseButton, x: i32, y: i32) -> Result<()>;
    fn type_text(&self, text: &str) -> Result<()>;
    fn press_key(&self, key: Key, modifiers: Vec<Modifier>) -> Result<()>;
    fn scroll(&self, direction: ScrollDirection, amount: i32) -> Result<()>;
    fn execute_shell(&self, command: &str) -> Result<ShellOutput>;
    fn open_application(&self, app_name: &str) -> Result<()>;
}

// Implementations par OS
struct MacOSProvider;      // CoreGraphics + CGEvent + NSWorkspace
struct WindowsProvider;    // Win32 API + SendInput + ShellExecute
struct LinuxProvider;      // X11/XCB (fallback Wayland via wlr-protocols)
```

**Pipeline de screenshot :**

```
Capture (OS natif, ~10ms)
  → Resize si >1920px (max dimension longue = 1280px)
  → Encode JPEG quality 75 (~100-150KB)
  → [Growth: Chiffre AES-256-GCM]
  → Encode base64 (~200KB)
  → Envoie via WebSocket
  → Boitier recoit, decode, forward au LLM
```

**Decision :** Resize a 1280px max. Raison : les LLM traitent mieux les images <1280px, et ca reduit la taille de 60%. La resolution est suffisante pour identifier les elements UI.

### MCP Hub — Architecture

```rust
// Chaque MCP server est un processus enfant
struct McpServer {
    name: String,
    version: u32,
    process: Child,          // Processus stdio (JSON-RPC)
    tools: Vec<ToolDef>,     // Tools exposes
    status: ServerStatus,    // Running / Stopped / Error
}

struct McpHub {
    servers: HashMap<String, McpServer>,
    // Au demarrage : spawn les serveurs builtin
    // Au handshake : annonce les tools au boitier
    // A l'appel : route tool_call vers le bon serveur
}
```

**MCP servers builtin (MVP) :**

| Server | Transport | Tools |
|--------|-----------|-------|
| `filesystem` | stdio | read, write, list, mkdir, delete |
| `chrome-devtools` | stdio + CDP | navigate, click, fill, screenshot, evaluate |
| `shell` | stdio | execute (bash/PowerShell) |

**Pas de screenshot MCP server separe** — les screenshots Computer Use passent par le pipeline natif Rust (plus rapide que MCP stdio).

**Protocole MCP :**
- Transport : stdio (JSON-RPC 2.0) entre l'app et chaque MCP server
- Le boitier n'appelle PAS directement les MCP servers — il envoie un `mcp_tool_call` via WebSocket, l'app route vers le bon serveur et renvoie le `mcp_tool_result`

```
Boitier                     App Cowork                 MCP Server
  │                            │                           │
  │ mcp_tool_call              │                           │
  │ {server:"chrome",          │                           │
  │  tool:"navigate",          │                           │
  │  args:{url:"..."}}         │                           │
  │─────────────────────────►  │                           │
  │                            │  JSON-RPC request         │
  │                            │ ─────────────────────────►│
  │                            │                           │
  │                            │  JSON-RPC response        │
  │                            │ ◄─────────────────────────│
  │ mcp_tool_result            │                           │
  │ {result: "..."}            │                           │
  │◄─────────────────────────  │                           │
```

### Systeme de Permissions

```rust
#[derive(Clone, Serialize, Deserialize)]
enum PermissionLevel {
    Allow,     // Execute sans demander
    Ask,       // Popup de confirmation
    Block,     // Refuse silencieusement
}

struct PermissionConfig {
    screenshot: PermissionLevel,
    mouse_click: PermissionLevel,
    keyboard: PermissionLevel,
    shell_execute: PermissionLevel,
    file_read: PermissionLevel,
    file_write: PermissionLevel,
    file_delete: PermissionLevel,      // Toujours Ask, non configurable
    install_software: PermissionLevel,  // Toujours Ask, non configurable
    chrome_navigate: PermissionLevel,
}
```

**Flux de permission (mode assiste) :**

```
Boitier envoie computer_use_request
  → App verifie PermissionConfig pour ce type d'action
  → Si Allow : execute immediatement
  → Si Ask : affiche popup frontend, attend reponse user
       → User clique Allow : execute + option "Allow toujours pour cette action"
       → User clique Deny : renvoie erreur au boitier
  → Si Block : renvoie erreur au boitier
```

**Profil Safe :** A la connexion, le boitier envoie le profil utilisateur dans le `cowork_hello_ack`. Si `profile: "safe"`, l'app force :
- `screenshot: Block`
- `mouse_click: Block`
- `keyboard: Block`
- `shell_execute: Block`
- `file_write: Block`
- `file_delete: Block`
- Seuls le chat et le file browser (read-only) restent actifs

### File Browser — Architecture

```rust
// MVP : navigation distante via WebSocket
// Pas de cache local, pas de sync

struct RemoteFileBrowser {
    // list_dir(path) → envoie file_request, attend file_response
    // read_file(path) → envoie file_request, attend file_response
    // download_file(path) → envoie file_request, sauve en local
}
```

**Phase 2 — Sync Engine :**

```rust
// Inspire de Syncthing (delta sync)
struct SyncEngine {
    watched_folders: Vec<SyncFolder>,  // Dossiers selectionnes par l'utilisateur
    local_state: HashMap<PathBuf, FileMetadata>,  // Hash + mtime
    remote_state: HashMap<PathBuf, FileMetadata>,

    // Cycle de sync :
    // 1. File watcher detecte changement local → calcule delta
    // 2. WebSocket notifie le boitier du changement
    // 3. Boitier notifie l'app des changements distants
    // 4. Conflit si meme fichier modifie des deux cotes → garder les deux (.conflict)
}
```

**Decision :** En cas de conflit, garder les deux fichiers (`fichier.txt` + `fichier.conflict.txt`). L'utilisateur decide. Pas de merge automatique — trop risque pour des fichiers non-texte.

## Protocole WebSocket Cowork — Specification Complete

### Handshake Initial

```json
// App → Boitier
{
  "type": "cowork_hello",
  "app_version": "1.0.0",
  "protocol_version": 1,
  "os": "macos",
  "mcp_servers": [
    {"name": "filesystem", "version": 1, "tools": ["read", "write", "list", "mkdir", "delete"]},
    {"name": "chrome-devtools", "version": 1, "tools": ["navigate", "click", "fill", "screenshot"]},
    {"name": "shell", "version": 1, "tools": ["execute"]}
  ]
}

// Boitier → App
{
  "type": "cowork_hello_ack",
  "core_version": "1.5.0",
  "protocol_version": 1,
  "profile": "pro",
  "agents": [
    {"id": "sophie-comptable", "name": "Sophie", "avatar": "💼", "enabled": true},
    {"id": "max-coordinateur", "name": "Max", "avatar": "📋", "enabled": true}
  ],
  "mcp_accepted": ["filesystem", "chrome-devtools", "shell"],
  "mcp_rejected": [],
  "permissions_override": null
}
```

### Events — Catalogue Complet

**Chat (bidirectionnel) :**

| Direction | Type | Payload |
|-----------|------|---------|
| App→Boitier | `chat_message` | `{agent_id, text, session_id}` |
| Boitier→App | `chat_delta` | `{agent_id, delta, role: "text\|thinking\|tool_call\|tool_result"}` |
| Boitier→App | `chat_done` | `{agent_id, session_id}` |

**Computer Use :**

| Direction | Type | Payload |
|-----------|------|---------|
| Boitier→App | `cu_request` | `{action, params, request_id}` |
| App→Boitier | `cu_result` | `{request_id, success, screenshot_b64?, error?}` |
| App→Boitier | `cu_denied` | `{request_id, reason: "user_denied\|blocked\|safe_mode"}` |
| App→Boitier | `cu_stream` | `{screenshot_b64}` (mode autonome, stream periodique) |

**MCP :**

| Direction | Type | Payload |
|-----------|------|---------|
| Boitier→App | `mcp_tool_call` | `{server, tool, arguments, call_id}` |
| App→Boitier | `mcp_tool_result` | `{call_id, result?, error?}` |
| App→Boitier | `mcp_server_status` | `{server, status: "started\|stopped\|error"}` |

**Files :**

| Direction | Type | Payload |
|-----------|------|---------|
| App→Boitier | `file_list` | `{path}` |
| Boitier→App | `file_list_result` | `{path, entries: [{name, type, size, mtime}]}` |
| App→Boitier | `file_read` | `{path}` |
| Boitier→App | `file_read_result` | `{path, content_b64, mime}` |
| App→Boitier | `file_download` | `{path}` |
| Boitier→App | `file_download_chunk` | `{path, chunk_b64, offset, total}` |

**Systeme :**

| Direction | Type | Payload |
|-----------|------|---------|
| Bidirectionnel | `heartbeat` | `{timestamp}` |
| Boitier→App | `agent_notification` | `{agent_id, message, level: "info\|warning\|error"}` |
| App→Boitier | `cu_stop` | `{}` (arret d'urgence Computer Use) |

### Versioning Protocole

- Meme strategie que l'architecture globale : `protocol_version` dans le handshake
- Boitier supporte N et N-1
- App trop vieille → `{"type": "error", "code": "UPGRADE_REQUIRED"}`
- Auto-update Tauri resout le probleme automatiquement

## Structure Projet & Frontieres

### Repo 5 : openjarvis-cowork

```
openjarvis-cowork/
├── src-tauri/                         ← Backend Rust (Tauri 2)
│   ├── src/
│   │   ├── main.rs                    ← Point d'entree Tauri, setup
│   │   ├── commands/                  ← Tauri IPC commands
│   │   │   ├── chat.rs               ← send_message, get_history
│   │   │   ├── computer_use.rs       ← approve_action, deny_action, stop
│   │   │   ├── files.rs              ← list_dir, read_file, download
│   │   │   ├── mcp.rs                ← list_servers, server_status
│   │   │   ├── permissions.rs        ← get_config, set_permission
│   │   │   └── connection.rs         ← connect, disconnect, status
│   │   ├── websocket/
│   │   │   ├── client.rs             ← WebSocket client async (tokio)
│   │   │   ├── discovery.rs          ← mDNS boitier detection
│   │   │   ├── protocol.rs           ← Serialize/deserialize events
│   │   │   └── reconnect.rs          ← Backoff exponentiel
│   │   ├── computer_use/
│   │   │   ├── mod.rs                ← Dispatch vers platform provider
│   │   │   ├── platform.rs           ← Trait PlatformProvider
│   │   │   ├── macos.rs              ← CoreGraphics + CGEvent
│   │   │   ├── windows.rs            ← Win32 + SendInput
│   │   │   ├── linux.rs              ← X11/XCB + XTest
│   │   │   └── pipeline.rs           ← Capture → resize → compress → encode
│   │   ├── mcp/
│   │   │   ├── hub.rs                ← Gestionnaire MCP servers
│   │   │   ├── transport.rs          ← stdio JSON-RPC vers processes
│   │   │   └── registry.rs           ← Registre plugins (Growth)
│   │   ├── files/
│   │   │   ├── browser.rs            ← Navigation distante
│   │   │   ├── download.rs           ← Telechargement chunked
│   │   │   └── sync.rs               ← Sync engine (Phase 2)
│   │   ├── security/
│   │   │   ├── permissions.rs        ← Allow/Ask/Block config
│   │   │   ├── profile.rs            ← Safe mode enforcement
│   │   │   ├── crypto.rs             ← AES-256-GCM (Growth)
│   │   │   └── audit.rs              ← Audit log (Growth)
│   │   └── config/
│   │       └── store.rs              ← Config persistante (JSON local)
│   ├── Cargo.toml
│   ├── tauri.conf.json
│   └── build.rs
├── src/                               ← Frontend TypeScript
│   ├── App.tsx
│   ├── main.tsx
│   ├── components/
│   │   ├── tray/
│   │   │   └── TrayPanel.tsx          ← Mini-panel (chat + statut)
│   │   ├── chat/
│   │   │   ├── ChatPanel.tsx          ← Zone de chat principale
│   │   │   ├── MessageBubble.tsx      ← Rendu message (markdown)
│   │   │   ├── ThinkingIndicator.tsx  ← Animation thinking
│   │   │   └── ToolTrace.tsx          ← Affichage tool calls
│   │   ├── agents/
│   │   │   └── AgentList.tsx          ← Liste + selection agents
│   │   ├── files/
│   │   │   ├── FileBrowser.tsx        ← Navigateur distant
│   │   │   └── FilePreview.tsx        ← Preview fichier
│   │   ├── computer-use/
│   │   │   ├── ScreenStream.tsx       ← Stream screenshots
│   │   │   └── ControlBar.tsx         ← Stop, mode assiste/autonome
│   │   ├── permissions/
│   │   │   └── PermissionDialog.tsx   ← Popup Allow/Deny
│   │   └── common/
│   │       ├── StatusBar.tsx          ← Indicateur connexion
│   │       └── Layout.tsx             ← Shell tray/expand
│   ├── lib/
│   │   ├── tauri-api.ts               ← Wrapper Tauri IPC invoke
│   │   ├── store.ts                   ← State management
│   │   └── theme.ts                   ← Dark cyan, Outfit, JetBrains Mono
│   └── styles/
│       └── globals.css
├── mcp-servers/                        ← MCP servers bundles
│   ├── filesystem/
│   │   ├── package.json
│   │   └── index.ts
│   ├── chrome-devtools/
│   │   ├── package.json
│   │   └── index.ts
│   └── shell/
│       ├── package.json
│       └── index.ts
├── scripts/
│   ├── build-mac.sh
│   ├── build-win.sh
│   └── build-linux.sh
├── .github/
│   └── workflows/
│       └── build.yml                  ← CI multi-OS
└── package.json
```

### Frontieres Architecturales

```
                                    openjarvis-cowork (Repo 5)
                                    ┌────────────────────────────┐
                                    │  Frontend (TS)             │
                                    │  ↕ Tauri IPC               │
                                    │  Backend (Rust)            │
                                    │  ↕ stdio JSON-RPC          │
                                    │  MCP Servers (TS/Node)     │
                                    └────────────┬───────────────┘
                                                 │
                                    WebSocket    │    WebSocket
                                    (LAN ws://)  │    (tunnel wss://)
                                                 │
                           ┌─────────────────────┼─────────────────────┐
                           │                     │                      │
                    ┌──────┴───────┐    ┌───────┴────────┐    ┌───────┴──────┐
                    │  ClawbotCore  │    │  clawbot-cloud  │    │  Anthropic    │
                    │  (boitier)    │    │  (tunnel VPS)   │    │  API          │
                    │  Repo 3       │    │  Repo 2         │    │  (externe)    │
                    └───────────────┘    └────────────────┘    └──────────────┘
```

**Regle absolue :** Le repo `openjarvis-cowork` est 100% autonome. Communication avec le boitier uniquement via WebSocket. Aucune dependance vers les 4 autres repos. Aucun import de code partage.

### Mapping FRs → Modules Rust

| Domaine FR | Module Rust | Module Frontend |
|-----------|-------------|-----------------|
| Connexion (CW-FR1→5) | `websocket/` | `StatusBar.tsx` |
| Chat (CW-FR6→11) | `commands/chat.rs` | `chat/` |
| Computer Use (CW-FR12→17) | `computer_use/` | `computer-use/` |
| Permissions (CW-FR18→25) | `security/` | `permissions/` |
| Files (CW-FR26→33) | `files/` | `files/` |
| MCP (CW-FR34→38) | `mcp/` | — (invisible frontend) |
| Interface (CW-FR39→44) | `tray/` | `tray/`, `Layout.tsx` |

### Flux de Donnees

1. **Chat** : User → Frontend IPC → Rust → WebSocket → Boitier → ClawbotCore → LLM → retour inverse (streaming)
2. **Computer Use** : Boitier `cu_request` → Rust verifie permissions → execute via PlatformProvider → `cu_result` → Boitier
3. **MCP** : Boitier `mcp_tool_call` → Rust → stdio JSON-RPC → MCP Server → resultat → Rust → `mcp_tool_result` → Boitier
4. **Files** : Frontend IPC → Rust → WebSocket `file_list` → Boitier liste → `file_list_result` → Rust → Frontend

## Conventions & Patterns

### Nommage

**Rust (backend) :**
- Modules/fichiers : `snake_case.rs`
- Structs/Enums : `PascalCase`
- Fonctions/variables : `snake_case`
- Constantes : `UPPER_SNAKE_CASE`
- Tauri commands : `snake_case` (ex: `send_message`, `approve_action`)

**TypeScript (frontend) :**
- Fichiers composants : `PascalCase.tsx`
- Fichiers lib : `camelCase.ts`
- Fonctions/variables : `camelCase`
- Types/Interfaces : `PascalCase`
- CSS classes : `kebab-case`

**WebSocket events :**
- Types : `snake_case` (ex: `cu_request`, `mcp_tool_call`, `file_list_result`)
- Coherent avec l'ecosysteme ClawBot

### Gestion d'Erreurs

```rust
// Erreurs typees, pas de unwrap en production
#[derive(thiserror::Error, Debug)]
enum CoworkError {
    #[error("WebSocket: {0}")]
    WebSocket(#[from] tungstenite::Error),
    #[error("Screenshot capture failed: {0}")]
    Screenshot(String),
    #[error("Permission denied for action: {0}")]
    PermissionDenied(String),
    #[error("MCP server error: {server} - {message}")]
    Mcp { server: String, message: String },
}
```

**Regle :** Pas de `unwrap()` ou `expect()` dans le code de production. Tous les `Result` sont propages ou geres. Les erreurs sont loguees avant propagation.

### Config Persistante

```json
// ~/.openjarvis/config.json
{
  "last_device": {
    "ip": "192.168.1.42",
    "port": 8765,
    "device_id": "0281662AA2C9"
  },
  "cloud": {
    "url": "wss://clawbot-api.yumi-lab.com",
    "jwt": "..."
  },
  "permissions": {
    "screenshot": "ask",
    "mouse_click": "ask",
    "keyboard": "ask",
    "shell_execute": "ask",
    "file_read": "allow",
    "file_write": "ask",
    "file_delete": "ask",
    "chrome_navigate": "allow"
  },
  "sync_folders": [],
  "theme": "dark"
}
```

### Theme UI

- Dark background : `#0a0a0a` (coherent dark mode)
- Accent cyan : `#00ffe0` (coherent dashboard WebUI)
- Fonts : Outfit (texte), JetBrains Mono (code)
- Responsive : pas necessaire (desktop only, min 800x600)

## Architecture Decision Records (ADR)

### ADR-CW-001 : Tauri 2 au lieu d'Electron

- **Statut :** Accepte
- **Contexte :** App desktop cross-platform avec acces OS natif (screenshots, input)
- **Options :** A) Tauri 2 (Rust, leger, <50MB) | B) Electron (Node, lourd, >100MB) | C) Flutter Desktop (Dart, immature) | D) .NET MAUI (C#, Windows-first)
- **Decision :** Tauri 2
- **Consequences :** Backend Rust (courbe d'apprentissage), frontend web standard. RAM <100MB. Reference Jan.ai.
- **Risque accepte :** Communaute plus petite qu'Electron. Mitige par maturite Tauri 2 (stable 2025).

### ADR-CW-002 : Pas de VM locale

- **Statut :** Accepte
- **Contexte :** Claude Cowork utilise une VM Linux. Faut-il faire pareil ?
- **Options :** A) Pas de VM (execution directe OS hote) | B) VM legere (microVM) | C) Container Docker
- **Decision :** Pas de VM
- **Consequences :** Securite assuree par permissions Allow/Ask/Block + profil Safe. Pas d'overhead 2GB.
- **Risque accepte :** Moins d'isolation qu'une VM. Mitige par le fait que le cerveau IA est distant (boitier), l'app ne fait qu'executer des actions ponctuelles.

### ADR-CW-003 : MCP servers en processus separés (stdio)

- **Statut :** Accepte
- **Contexte :** Comment l'app expose les capacites locales (Chrome, FS, shell) au boitier ?
- **Options :** A) MCP servers stdio (standard MCP) | B) Integration directe en Rust | C) HTTP local
- **Decision :** MCP servers stdio
- **Consequences :** Standard MCP officiel, compatible plugins tiers. Isolation par processus. Overhead ~10ms par appel (acceptable).
- **Risque accepte :** N+1 processus (un par MCP server). Mitige par lazy-start (demarrer uniquement au premier appel).

### ADR-CW-004 : Dual LAN/Tunnel sans bascule automatique

- **Statut :** Accepte
- **Contexte :** L'app peut se connecter en LAN direct ou via tunnel cloud.
- **Options :** A) Bascule automatique LAN↔tunnel | B) LAN au demarrage, tunnel en fallback, pas de bascule mid-session
- **Decision :** Pas de bascule mid-session
- **Consequences :** Stabilite des sessions (pas de deconnexion surprise). L'utilisateur bascule manuellement ou a la reconnexion.
- **Risque accepte :** Si le LAN tombe mid-session, il faut attendre la reconnexion (qui basculera sur le tunnel).

### ADR-CW-005 : Screenshots resizes a 1280px max

- **Statut :** Accepte
- **Contexte :** Screenshots haute resolution = gros fichiers + LLM ne beneficie pas au-dela de 1280px.
- **Options :** A) Resolution native | B) Resize 1280px | C) Resize 768px
- **Decision :** Resize 1280px max dimension longue
- **Consequences :** ~100-150KB par screenshot JPEG Q75. Latence reduite, cout tokens reduit cote LLM.
- **Risque accepte :** Perte de detail sur petit texte. Mitige par action `zoom` future (crop + full res sur une region).

### ADR-CW-006 : File browser distant en MVP, sync Phase 2

- **Statut :** Accepte
- **Contexte :** Sync fichiers Dropbox-like = complexite enorme (conflits, delta, offline). Scope trap identifie en brainstorm.
- **Options :** A) Sync MVP | B) File browser distant MVP, sync Phase 2
- **Decision :** File browser distant en MVP
- **Consequences :** MVP plus rapide a shipper. L'utilisateur peut naviguer, lire et telecharger mais pas synchroniser. Phase 2 ajoute la sync inspiree Syncthing.
- **Risque accepte :** Experience degradee vs Dropbox en MVP. Mitige par le fait que le file browser est deja utile.

### ADR-CW-007 : Conflit sync = garder les deux fichiers

- **Statut :** Planifie (Phase 2)
- **Contexte :** Deux modifications simultanées du meme fichier (PC + boitier pendant une deconnexion).
- **Options :** A) Last write wins | B) Garder les deux (.conflict) | C) Merge automatique
- **Decision :** Garder les deux fichiers
- **Consequences :** L'utilisateur voit `fichier.txt` et `fichier.conflict.txt`, decide manuellement. Safe pour les fichiers binaires.
- **Risque accepte :** UX pas ideale. Mitige par notification claire + outil de resolution dans l'UI.

## Impact sur les Autres Repos

### clawbot-cloud (Repo 2)

**Modifications requises :**
- Nouveau type d'event WebSocket dans le tunnel : `cowork_hello`, `cu_*`, `mcp_*`, `file_*`
- Le tunnel doit router ces events de maniere transparente (deja le cas si on utilise le format `type` + `payload` existant)
- Potentiellement : endpoint REST pour l'auth initiale de l'app Cowork (obtenir le JWT)

**Estimation :** Faible impact. Le tunnel est deja un proxy WebSocket transparent.

### ClawbotCore (Repo 3)

**Modifications requises :**
- Nouveau handler pour les events Cowork cote device (`cowork_hello`, `cu_request`, `mcp_tool_call`, `file_*`)
- Integration du Computer Use dans la boucle agent (envoyer `cu_request`, attendre `cu_result`, reinjecter le screenshot dans le contexte LLM)
- Integration MCP : recevoir les tools disponibles au handshake, les ajouter aux tool_definitions de l'agent actif
- API pour lister les agents (deja existante)
- API pour lister/lire les fichiers (deja existante via tools built-in)

**Estimation :** Impact moyen. Le plus gros morceau est l'integration Computer Use dans la boucle agent.

### ClawBot-OS (Repo 1)

**Modifications requises :** Aucune en MVP. L'app Cowork est un client externe.

### ClawbotCore-WebUI (Repo 4)

**Modifications requises :** Aucune. L'app Cowork et le dashboard web sont independants.

## Sequence d'Implementation

1. **Scaffold Tauri 2** — projet vide, tray icon, fenetre basique
2. **WebSocket client** — connexion LAN + tunnel, handshake, heartbeat
3. **Chat** — envoyer/recevoir messages, streaming, selection agent
4. **Computer Use basique** — screenshot + clic + type (Mac d'abord)
5. **Permissions** — popup Allow/Deny, config persistante
6. **File browser** — navigation, lecture, telechargement
7. **MCP Hub** — spawn servers, handshake, routing tool calls
8. **Multi-OS** — porter Computer Use sur Windows et Linux
9. **Installeur** — .dmg, .exe, .deb, auto-update
10. **Polish** — theme dark cyan, animations, notifications

**Dependances inter-etapes :**
- 2 (WebSocket) debloque tout le reste
- 3 (Chat) et 4 (CU) peuvent etre paralleles apres 2
- 5 (Permissions) doit preceder 4 (CU) en production
- 6 (Files) et 7 (MCP) independants apres 2

## Regles Obligatoires pour les Agents IA

1. Pas de `unwrap()` ou `expect()` dans le code Rust de production
2. Tous les events WebSocket utilisent le format `{"type": "...", "payload": {...}}`
3. Les types d'events sont en `snake_case`
4. Les Tauri commands sont en `snake_case`
5. Les composants frontend sont en `PascalCase.tsx`
6. Le theme respecte `#00ffe0` accent + `#0a0a0a` background
7. Les MCP servers communiquent via stdio JSON-RPC uniquement
8. Les permissions `file_delete` et `install_software` sont TOUJOURS `Ask`, jamais configurables
9. Les screenshots sont resizes a 1280px max avant envoi
10. La config persistante est dans `~/.openjarvis/config.json`
11. Aucune dependance vers les 4 autres repos — communication WebSocket uniquement
12. Le profil Safe du boitier est respecte sans exception
