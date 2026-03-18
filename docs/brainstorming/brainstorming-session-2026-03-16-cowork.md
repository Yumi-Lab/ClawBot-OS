---
stepsCompleted: [1, 2, 3, 4]
inputDocuments: []
session_topic: 'Module Cowork OpenJarvis — App desktop cross-platform connectée au boîtier ClawBot'
session_goals: 'Valider la vision produit, le format (widget vs app), le positionnement vs dashboard web, le protocole, et la roadmap fonctionnelle'
selected_approach: 'AI-Recommended'
techniques_used: ['What If Scenarios', 'Analogical Thinking (Claude Cowork)', 'Role Playing (Use Cases)', 'Morphological Analysis']
ideas_generated: []
context_file: ''
---

# Brainstorming Session — Module Cowork OpenJarvis

**Facilitateur:** Nicolas
**Date:** 2026-03-16

---

## 1. Session Overview

**Sujet:** Concevoir le module Cowork d'OpenJarvis — une app desktop cross-platform qui connecte l'utilisateur à son boîtier ClawBot via WebSocket pour coworker avec ses agents IA.

**Objectifs:**
- Valider la vision produit globale et le format du produit
- Définir le positionnement vs le dashboard web existant
- Explorer la forme finale (widget léger vs app complète style Discord)
- Identifier les use cases MVP prioritaires
- Clarifier le modèle d'interaction utilisateur ↔ agents ↔ PC

---

## 2. Vision produit validée

### Les deux piliers fondamentaux

**Pilier 1 — Disque distant (sync Dropbox-like)**
Accéder aux fichiers du boîtier comme un disque dur local. Tout ce que les agents créent est visible en temps réel. Synchronisation sélective bidirectionnelle avec cache local.

- Sync sélectif — l'utilisateur choisit quels dossiers synchroniser
- Cache local — fichiers accessibles offline si le boîtier est déconnecté
- Copie cloud — fallback si le boîtier est hors-ligne
- Temps réel — notifications de changements via WebSocket
- Gestion de conflits — si modif des deux côtés pendant une déco

**Pilier 2 — IA sur ton PC (Computer Use)**
Le boîtier prend la main sur l'ordinateur. Il exécute des commandes, débugue, installe des logiciels, prend des screenshots. Comme si l'IA était installée en local.

### L'insight clé

Le cerveau IA vit dans le boîtier (avec tous les agents pimpés pour le business de l'utilisateur), mais il agit sur le PC comme s'il était local. Connexion WebSocket via cloud tunnel = accessible de n'importe où dans le monde.

### Modèle de référence

Claude Desktop App (Chat + Cowork + Code) mais connecté au boîtier OpenJarvis au lieu des serveurs Anthropic.

---

## 3. Décisions produit actées

### Format : Hybride (tray widget → expand en app) ✅

- **Tray icon** par défaut — toujours actif en arrière-plan
- **Clic** = mini-panel (chat rapide + notifications agents + statut sync)
- **Double-clic / expand** = app complète (file browser, computer use, panel agents, etc.)
- Monte en puissance progressivement selon les besoins de l'utilisateur

### Positionnement vs dashboard web ✅

| Dashboard web (index.html) | App Cowork (Tauri) |
|---|---|
| Monitoring, config, chat simple | Assistant IA complet sur le bureau |
| Accessible partout sans installer | Installée sur le PC |
| Smartphone, tablette, PC d'un ami | PC principal de l'utilisateur |
| Pas de contrôle du PC | Computer Use, sync fichiers, MCP, commandes |

**Les deux coexistent.** Le web ne peut pas prendre la main sur l'ordi (sandbox navigateur). L'app native est indispensable pour le cowork.

### Protocole : WebSocket via cloud tunnel ✅

Le boîtier peut être chez toi et toi à l'autre bout du monde. Connexion WebSocket bidirectionnelle via le cloud tunnel existant (`clawbot-cloud`).

---

## 4. Use Cases identifiés

### UC1 — Support technique : "Mon PC déconne, aide-moi"

L'utilisateur a un problème (bug, virus, imprimante, réseau, installation) et demande à OpenJarvis de le résoudre.

- L'IA prend la main : diagnostique, exécute des commandes, configure
- Interaction dialogue : "t'as vérifié le câble ?" → "ok je la détecte, je configure"
- Remplace l'appel à un technicien ou la recherche Google
- **Mode assisté** — l'IA propose, l'humain valide chaque action

### UC2 — Délégation : "Fais ce travail pour moi"

L'utilisateur délègue des tâches opérationnelles à l'IA : développer du code, naviguer sur Chrome, remplir des formulaires, récupérer des infos.

- L'agent a besoin d'accéder au PC car pas de serveur MCP pour tout
- Il prend la main sur Chrome, exécute des actions, cherche des infos
- Sous surveillance humaine — l'utilisateur regarde que tout se passe bien
- **Mode autonome** — l'IA exécute, l'humain surveille et peut stopper

### Matrice des use cases

| | UC1 — Support | UC2 — Délégation |
|---|---|---|
| **Qui initie** | L'utilisateur ("j'ai un problème") | L'utilisateur ("fais cette tâche") |
| **Qui pilote** | L'IA diagnostique et propose | L'IA exécute de manière autonome |
| **Supervision** | Interactive (dialogue) | Surveillance passive |
| **Durée** | Ponctuel (résoudre un bug) | Peut durer longtemps |
| **Risque** | Moyen (touche au système) | Élevé (actions autonomes web/apps) |

### Concept émergent : niveaux d'autonomie

- **Mode assisté** — l'IA propose chaque action, l'humain valide (comme les niveaux de conduite autonome)
- **Mode autonome** — l'IA exécute, l'humain surveille et peut stopper à tout moment
- Système de permissions Allow / Ask / Block par type d'action (inspiré de Claude Cowork)

---

## 5. Analyse concurrentielle — Claude Cowork vs OpenJarvis Cowork

### Architecture Claude Cowork (référence)

```
Claude Desktop (Electron)
    → IPC → Main Process (Node.js)
        → @ant/claude-swift (addon natif)
            → Apple VZVirtualMachine
                → VM Linux (Ubuntu 22.04, ARM64, 8GB RAM)
                    → Claude Code CLI (reçoit tâches via JSON-RPC stdin)
                    → Dossiers montés via VirtioFS
                    → Proxy réseau SOCKS5 (whitelist domaines)
                    → bubblewrap + seccomp (sandbox)
```

### Fonctionnalités Claude Cowork

- 3 onglets : Chat, Cowork, Code
- Fichiers : lecture/création/édition/suppression dans dossiers autorisés
- Génération Excel, PowerPoint, analyses de données
- Navigation Chrome via extension (screenshots streamés)
- Commandes shell dans la VM
- Sous-agents en parallèle
- Tâches planifiées (briefings quotidiens, rapports hebdo)
- Connecteurs MCP (Gmail, Slack, Google Drive...)

### Sécurité Claude Cowork (5 couches)

1. Hyperviseur (VM isolée via Apple VZVirtualMachine)
2. Sandbox processus (bubblewrap + seccomp/eBPF)
3. Validation de chemins (blocage traversal + extensions .exe/.dmg bloquées)
4. Proxy réseau (SOCKS5 + MITM + whitelist domaines)
5. Human-in-the-loop (approbation actions critiques)

### Permissions Claude Cowork

- Dossiers : seuls ceux partagés explicitement sont accessibles
- Suppression fichiers : approbation obligatoire
- Connecteurs MCP : par outil → Allow / Ask / Block
- Actions critiques : popup de confirmation

### Différences structurelles

| | Claude Cowork | OpenJarvis Cowork |
|---|---|---|
| **Cerveau IA** | API Anthropic (cloud) | Boîtier ClawBot (chez l'utilisateur) |
| **Exécution locale** | VM Linux dans l'app | App Tauri native (pas de VM) |
| **Connexion** | API REST HTTPS | WebSocket via cloud tunnel |
| **Fichiers** | Montés via VirtioFS (VM) | Sync Dropbox-like via WebSocket |
| **MCP** | Connecteurs dans la VM | Serveurs MCP locaux sur le PC |
| **Agents** | Sous-agents Anthropic génériques | Agents personnalisés sur le boîtier |
| **Offline** | Non (besoin API cloud) | Cache local + reconnexion auto |
| **Multi-device** | Un seul poste | Plusieurs PC sur même boîtier |

### Notre avantage unique

**Les agents personnalisés.** Chez Anthropic c'est générique. Chez nous, l'utilisateur a ses agents pimpés pour son business, son contexte, ses données. Le boîtier est le "cerveau privé" de l'utilisateur.

---

## 6. Recherche technique — Projets open-source exploitables

### Computer Use (contrôle desktop par IA)

| Projet | Stars | Licence | Stack | Intérêt |
|--------|-------|---------|-------|---------|
| **CUA (trycua)** | 13.1k | **MIT** | Python + Swift + TS | **Meilleur candidat** — modulaire, multi-OS |
| **UI-TARS** (ByteDance) | 28.9k | Apache 2.0 | Electron + TS | App complète, mais lourde |
| **Anthropic computer-use-demo** | 15.3k | **MIT** | Python + Docker + VNC | Référence pour la boucle agent |
| **Bytebot** | 10.6k | Apache 2.0 | NestJS + Next.js | Multi-LLM via LiteLLM |

### Assistants IA desktop

| Projet | Stars | Licence | Stack | MCP | Intérêt |
|--------|-------|---------|-------|-----|---------|
| **Jan.ai** | 41.1k | **Apache 2.0** | **Tauri** + Rust + TS | Oui | **Architecture Tauri idéale** |
| **AnythingLLM** | 56.3k | MIT | Electron + React | Oui | Chat + agents |
| **Open Interpreter** | 62.7k | AGPL | Python + FastAPI | Non | CLI, exec commandes |

### MCP — 100% open-source

| Repo | Description |
|------|-------------|
| `modelcontextprotocol/specification` | Spécification complète |
| `modelcontextprotocol/python-sdk` | SDK Python (22.2k stars) |
| `modelcontextprotocol/typescript-sdk` | SDK TypeScript (11.9k stars) |
| `modelcontextprotocol/servers` | Serveurs de référence (81.2k stars) |

### Sync fichiers

| Projet | Intérêt |
|--------|---------|
| **Syncthing** (68k+ stars, MPL-2.0, Go) | P2P sync, modèle Dropbox open-source |

### Recommandation stack

- **Shell app** : Tauri 2 (Rust + TypeScript) — inspiré de Jan.ai
- **Computer Use** : Protocole Anthropic (MIT) + code CUA
- **MCP** : SDKs officiels open-source
- **Sync fichiers** : Inspiré Syncthing, adapté WebSocket
- **Connexion boîtier** : WebSocket via cloud tunnel existant

---

## 7. Architecture cible validée

```
┌─────────────────────────────────────────────────────────┐
│                  App Cowork (Tauri 2)                    │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │   Chat    │  │  Agents  │  │  Files   │  │Computer│ │
│  │  Panel    │  │  Panel   │  │  Browser │  │  Use   │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───┬────┘ │
│       │              │              │             │      │
│  ┌────┴──────────────┴──────────────┴─────────────┴───┐ │
│  │              WebSocket Client Layer                 │ │
│  └────────────────────┬────────────────────────────────┘ │
│                       │                                  │
│  ┌────────────────────┴────────────────────────────────┐ │
│  │         MCP Server (local)          Sync Engine     │ │
│  │  - screenshot, click, type          - File watcher  │ │
│  │  - bash, filesystem                 - Diff sync     │ │
│  │  - Chrome DevTools                  - Conflict res  │ │
│  └─────────────────────────────────────────────────────┘ │
│                       │                                  │
│              Tray Icon (toujours actif)                  │
└───────────────────────┼──────────────────────────────────┘
                        │ WebSocket (wss://)
                        │
              ┌─────────┴─────────┐
              │   Cloud Tunnel    │
              │  clawbot-cloud    │
              └─────────┬─────────┘
                        │ WebSocket
                        │
              ┌─────────┴─────────┐
              │   Boîtier ClawBot │
              │                   │
              │  - ClawbotCore    │
              │  - Agents perso   │
              │  - Fichiers       │
              │  - LLM routing    │
              └───────────────────┘
```

---

## 8. Synthèse — Décisions clés pour le PRD

| Question | Décision |
|----------|----------|
| Format produit | Hybride tray widget → app complète |
| Stack technique | Tauri 2 (Rust + TypeScript) |
| Protocole connexion | WebSocket via cloud tunnel existant |
| Sync fichiers | Dropbox-like, sélectif, cache local, offline |
| Computer Use | Boucle screenshot→action Anthropic, exécution locale |
| MCP | Serveurs MCP locaux sur le PC, pilotés par le boîtier |
| Sécurité | Permissions Allow/Ask/Block par action (inspiré Claude) |
| Autonomie IA | 2 modes : assisté (valide chaque action) / autonome (surveille) |
| Positionnement vs web | Coexistence — web pour monitoring, app pour cowork |
| Avantage compétitif | Agents personnalisés + boîtier privé (vs cloud générique) |

### Ce qui reste à définir (pour le PRD)

- Scope exact du MVP Phase 1 (quels piliers en premier ?)
- Protocole détaillé de sync fichiers (delta sync, compression, etc.)
- Modèle de sécurité complet (sandboxing sans VM ?)
- Gestion multi-utilisateurs sur un même boîtier
- Intégration avec le système d'abonnement existant (plans Free/Perso/Pro)
- Tâches planifiées (comme Claude Cowork — briefings quotidiens etc.)

---

## Session terminée

**Prochaine étape recommandée :** Créer le PRD du module Cowork avec `/bmad-bmm-create-prd`
