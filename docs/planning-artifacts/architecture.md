---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: 'complete'
completedAt: '2026-03-08'
inputDocuments: ['docs/planning-artifacts/prd.md', 'docs/planning-artifacts/product-brief-clawbot-2026-03-08.md', 'docs/planning-artifacts/prd-validation-report.md']
workflowType: 'architecture'
project_name: 'ClawBot'
user_name: 'Nicolas'
date: '2026-03-08'
---

# Architecture Decision Document — ClawBot

_Ce document se construit collaborativement etape par etape. Les sections sont ajoutees au fur et a mesure des decisions architecturales._

## Analyse de Contexte Projet

### Vue d'ensemble des Requirements

**Requirements Fonctionnels — 61 FRs en 14 domaines :**

| Domaine | FRs | Phase |
|---------|-----|-------|
| AI Interaction & Chat | FR1-FR6 | MVP |
| Agent Management | FR7-FR10 | MVP |
| Device Setup & Onboarding | FR11-FR15 | MVP |
| Subscription & Billing | FR16-FR21 | MVP |
| File & Data Management | FR22-FR27 | MVP |
| Cloud Connectivity & Resilience | FR28-FR34 | MVP |
| Notifications & Analytics | FR35-FR36 | MVP |
| System Administration & Updates | FR37-FR42 | MVP |
| Module System | FR43-FR47 | MVP/Growth |
| Credential Vault | FR48-FR50 | MVP |
| API & Integrations | FR51-FR52 | Growth |
| Multi-User & Modes | FR53-FR54 | Growth |
| Voice & Mobile | FR55-FR56 | Growth |
| SmartPad Display | FR57 | MVP Pro |
| Desktop & Inter-Box | FR58-FR61 | Vision |

**Repartition :** 43 MVP, 14 Growth, 4 Vision

**Requirements Non-Fonctionnels — 26 NFRs critiques :**

- **Performance** : <5s reponse LLM, <10min time-to-first-value, <3s dashboard LAN, <30s reconnexion tunnel
- **Ressources H3** : <500MB RSS, <4GB stockage OS, <100MB/jour ecriture SD, <10% CPU idle
- **Securite** : WSS obligatoire, AES-256 vault, JWT HS256 72h, zero contenu conversationnel en DB cloud
- **Scalabilite** : 100→1000+ devices, 4+ WebSocket paralleles, >500 users sans degradation

### Contraintes Techniques & Dependances

1. **Hardware H3 (1GB RAM, ARM 32-bit)** — contraint fortement l'architecture : compaction de contexte agressive, pas d'inference locale, tout passe par le cloud
2. **Architecture 4 repos** — ClawBot-OS (firmware), clawbot-cloud (FastAPI), ClawbotCore (orchestrateur Python), ClawbotCore-WebUI (dashboard SPA)
3. **Pattern Moonraker** — ClawbotCore = aggregateur pur, modules independants via manifest JSON
4. **WebSocket comme protocole universel** — device↔cloud, device↔dashboard, futur device↔desktop
5. **Dependance Anthropic** — 100% inference externalisee, mitigation multi-LLM en Growth
6. **OTA par repo Git** — pas d'image complete, mise a jour incrementale par composant
7. **Brownfield** — code existant fonctionnel, CI/CD operationnel, 4 variantes de build

### Preoccupations Transversales Identifiees

1. **Authentification & Identite** — MAC device + JWT user + QR provisioning, traverse les 4 repos
2. **Gestion Tokens/Quotas** — rate limiting par plan, monitoring cout/user, throttle (pas coupure)
3. **Cycle de vie WebSocket** — reconnexion, sessions paralleles, persistence, failover — affecte cloud + core + dashboard
4. **Systeme de Modules** — manifest JSON, chargement dynamique, panels dashboard, isolation — affecte core + WebUI + OS
5. **OTA & Versionnement** — update manager par composant, configs INI, retrocompatibilite V1/V2
6. **Observabilite** — logs rotatifs (<100MB/jour SD), monitoring CPU/RAM, alerting, etat de connexion

### Echelle & Complexite

- **Domaine principal :** IoT/Embedded + Cloud hybride
- **Niveau de complexite :** Medium-High (4 repos, hardware contraint, cloud, multi-plan, modules)
- **Composants architecturaux estimes :** ~12-15 (core, cloud API, tunnel, dashboard, module system, auth, billing, OTA, vault, monitoring, wizard, agent-manager, SmartPad display)

## Evaluation Stack Technique (Brownfield)

### Domaine Technologique

IoT/Embedded hybride — device ARM contraint + API cloud + dashboard web

### Stack Existante (Projet Brownfield — Pas de Starter Template)

Le projet existe et fonctionne. Aucun starter template n'est necessaire. Les decisions technologiques sont deja prises et validees par le code en production.

**Rationale :** Projet brownfield avec 4 repos fonctionnels, CI/CD operationnel, builds qui passent. La stack est coherente avec le profil du fondateur (from-scratch, pragmatisme, zero framework lourd) et les contraintes hardware (H3 1GB RAM).

### Decisions Technologiques Existantes

**Langages & Runtimes :**
- Python 3 (stdlib-only) — ClawbotCore, clawbot-cloud
- Bash — ClawBot-OS (build scripts Armbian)
- Vanilla JavaScript — ClawbotCore-WebUI (SPA monolithique)

**Frameworks :**
- FastAPI — clawbot-cloud (API REST + WebSocket)
- Aucun framework frontend — HTML/CSS/JS pur, marked.js + highlight.js

**Stockage :**
- PostgreSQL — cloud (users, devices, tokens, sessions). Decision architecturale : migration depuis SQLite pour anticiper le scaling Kickstarter (ecritures concurrentes de milliers de devices simultanement)
- SQLite + JSON — device (single-user, pas de concurrence, adapte au H3)
- Fichiers INI — device (update manager, configs Moonraker-style)

**Infrastructure & Deploiement :**
- VPS IONOS (prix fixe) — cloud, pas d'AWS/GCP (couts maitrisables, zero vendor lock-in)
- Systemd — gestion services (device + cloud)
- Git pull — deploiement cloud + OTA device
- Pas de Docker/conteneurs
- CI GitHub Actions — build 4 variantes d'images

**Strategie de scaling cloud :**
- Duplication VPS a prix fixe (IONOS) derriere un load balancer nginx
- PostgreSQL supporte nativement les ecritures concurrentes (vs SQLite single-writer)
- Scaling horizontal : N serveurs identiques, meme schema DB
- Zero vendor lock-in cloud

### Decision Cle : SQLite → PostgreSQL (Cloud)

**Contexte :** Scenario Kickstarter avec plusieurs milliers de boitiers vendus simultanement. SQLite a un verrou single-writer qui bloquerait les ecritures concurrentes de tokens/sessions de milliers de devices.

**Decision :** PostgreSQL des le lancement sur le VPS IONOS existant (`apt install postgresql`, zero cout supplementaire).

**Impact :** Modification du code clawbot-cloud (couche d'acces DB). Le schema reste identique, seul le driver change.

## Decisions Architecturales

### Priorite des Decisions

**Decisions Critiques (bloquent l'implementation) :**
- Migration SQLite → PostgreSQL (cloud)
- Protocole WebSocket uniforme
- Credential vault chiffre
- Token optimization (system prompt + reponses)

**Decisions Importantes (faconnent l'architecture) :**
- Multi-region (EU/US/Chine)
- Smart LLM router (aggregateur multi-provider)
- Pool de tokens groupe/famille
- Strategie de scaling multi-VPS

**Decisions Differees (post-MVP) :**
- LLM local sur device V2
- Certificat device (securite renforcee)
- Load balancing automatique inter-LLM

### Data Architecture

| Decision | Choix | Rationale |
|----------|-------|-----------|
| DB cloud | PostgreSQL | Ecritures concurrentes (scaling Kickstarter) |
| DB device | SQLite + JSON | Single-user, zero config, adapte H3 |
| Validation | Pydantic (via FastAPI) | Deja inclus, zero cout |
| Cache cloud | In-memory Python (dict) | Pas de Redis — routing simple, pas de calcul lourd |
| Backup | pg_dump cron quotidien | Simple, fiable, vers un 2eme VPS |
| Migration | Meme schema, driver asyncpg | Changement minimal |

### Authentification & Securite

| Decision | Choix | Rationale |
|----------|-------|-----------|
| Auth cloud | JWT HS256, 72h, rotation possible | En place, fonctionne |
| Identite device | MAC + token de provisioning | En place, suffisant beta |
| QR provisioning | QR → openjarvis.io/setup?token=X → compte → association | Un flow, un endpoint |
| Credential vault | JSON chiffre AES-256 local, cle derivee MAC + secret | Stdlib Python, donnees ne quittent jamais le device |
| Transport | WSS (TLS) obligatoire | En place |
| Commandes systeme | Sandboxing + blocage destructif | En place |
| Evolution post-MVP | Certificat device, chiffrement SD complet | Growth |

### API & Communication

| Decision | Choix | Rationale |
|----------|-------|-----------|
| Protocole WS | JSON : `type` + `payload` + `session_id` | En place, simple, extensible |
| Erreurs REST | Codes HTTP standard + `{"error": "...", "code": "..."}` | Coherent |
| Erreurs WS | Champ `error` dans le payload JSON | Uniforme avec REST |
| Rate limiting | Token bucket par plan/groupe, middleware FastAPI, persist PostgreSQL | Simple, par user ou par groupe |

### Frontend Architecture

| Decision | Choix | Rationale |
|----------|-------|-----------|
| Panels modules | Convention `panel.html` par module, charge en innerHTML | Isolation, zero build |
| Etat applicatif | Variables globales JS + evenements custom | En place, suffisant |
| Pas de framework | Confirme — vanilla JS | Coherent profil fondateur, zero toolchain |

### Infrastructure & Deploiement

| Decision | Choix | Rationale |
|----------|-------|-----------|
| Multi-region | EU + US + Chine (3 serveurs minimum) | Performance locale, marche chinois |
| Providers | Evaluer Hetzner/Hostinger (EU/US), Alibaba/Tencent (Chine) — optimiser prix | IONOS actuel comme reference |
| Geo-routing | DNS-based, region assignee au provisioning | Simple, pas de CDN complexe |
| Chine → Anthropic | Tunnel via serveur EU (meme pattern que device→cloud) | Contourne le firewall, deja valide en production |
| Scaling | Nginx reverse proxy + sticky sessions, N VPS identiques | WebSocket = sticky obligatoire |
| Monitoring | `/health` endpoint + alerting Telegram (module existant) | Zero cout, deja en place |
| Logging | journald + logrotate (device et cloud) | Coherent, simple |

### Optimisation Tokens (Transversal)

**Niveau 1 — MVP :**
- System prompt compresse (style telegraphique, pas de mots inutiles)
- Prompt caching Anthropic (system prompt cache cote API, paye une seule fois)
- Instruction reponse concise dans le system prompt
- `max_tokens` adaptatif par type de requete

**Niveau 2 — Growth :**
- Smart LLM router : routing automatique par complexite de requete, transparent pour l'utilisateur
- LLM chinois (DeepSeek, Qwen) pour reduire les couts tokens
- Multi-LLM : OpenAI, Mistral en complement
- Routing double : par plan (plafond modele) + par contenu (provider le moins cher capable)

**Niveau 3 — Vision :**
- LLM local sur device V2 64-bit pour taches simples (classification, extraction) a cout zero
- Load balancing intelligent entre local/cloud/multi-provider

### Position Strategique : Aggregateur LLM Pur

ClawBot ne s'engage avec aucun LLM provider. L'interface provider est abstraite dans ClawbotCore — ajouter un nouveau LLM = ajouter un adapter Python, pas un refactoring.

**Providers a integrer (par ordre de priorite) :**
1. Anthropic (actuel, en place)
2. DeepSeek / Qwen (Chine, bas cout, Growth)
3. OpenAI (marche US, compatibilite, Growth)
4. Modeles locaux (device V2, cout zero, Vision)

**Routing par profil d'usage :**

| Profil | Usage typique | Routing par defaut |
|--------|--------------|-------------------|
| Particulier | Chat simple, recettes, devoirs, organisation | Modele le moins cher disponible |
| Pro leger | Emails, devis, resumes | Mid-range (Sonnet ou equivalent) |
| Pro dev/agent | Code, multi-agent, runs longues | Meilleur disponible (Opus) |

### Pool de Tokens Groupe (Growth)

**Concept :** Les comptes interconnectes en groupe partagent un pool de tokens commun. Chaque abonnement ajoute des tokens au pool. Les membres s'auto-regulant naturellement (personne ne partage avec des inconnus).

**Schema :**
- Table `Group` avec `group_id`
- Champ `group_id` sur la table `User`
- Rate limiting calcule sur la somme des quotas du groupe
- Pas de limite de membres — regulation naturelle par la confiance
- CGV comme filet de securite si besoin

**Pricing :**
- Adulte : €8/mois → +200k tokens/jour au pool
- Enfant/membre supplementaire : €2-3/mois → +50k tokens/jour au pool
- Plus de membres = plus de tokens au global

### Sequence d'Implementation

1. Migration PostgreSQL (cloud) — prerequis scaling
2. Credential vault chiffre — prerequis onboarding Pro
3. Token optimization niveau 1 — impact immediat sur les couts
4. QR provisioning flow — prerequis lancement
5. Multi-region EU — base existante
6. Smart LLM router — Growth
7. Pool tokens groupe — Growth
8. Multi-region US + Chine — post-lancement

### Dependances Inter-Composants

- **PostgreSQL** → debloque rate limiting groupe + scaling multi-VPS
- **Smart router** → necessite interface provider abstraite (adapter pattern)
- **Multi-region** → necessite geo-routing DNS + PostgreSQL replicas
- **Pool tokens** → necessite PostgreSQL + `group_id` schema

## Patterns d'Implementation & Regles de Coherence

### Points de Conflit Identifies

12 zones ou des agents IA pourraient prendre des decisions differentes sans regles claires.

### Conventions de Nommage

**Base de donnees (PostgreSQL cloud) :**
- Tables : `snake_case`, pluriel (`users`, `devices`, `activation_tokens`)
- Colonnes : `snake_case` (`user_id`, `sub_key`, `tokens_used`)
- Cles etrangeres : `{table_singulier}_id` (`user_id`, `device_id`)
- Index : `idx_{table}_{colonne}` (`idx_users_email`)

**API REST :**
- Endpoints : `snake_case`, pluriel (`/v1/users`, `/v1/devices`)
- Parametres route : `{id}` (style FastAPI)
- Query params : `snake_case`
- Headers custom : `X-Admin-Secret` (existant)

**Python (ClawbotCore + clawbot-cloud) :**
- Fonctions/variables : `snake_case`
- Classes : `PascalCase`
- Constantes : `UPPER_SNAKE_CASE` (`MAX_TOOL_ROUNDS`, `LLM_TIMEOUT`)
- Fichiers : `snake_case.py`

**JavaScript (dashboard) :**
- Fonctions/variables : `camelCase` (`sessSave`, `checkPendingResponse`)
- Constantes DOM : `camelCase`
- Fichiers : `kebab-case` ou single word
- CSS classes : `kebab-case`

**Outils modules :**
- Nommage : `{module_id}__{tool_name}` (double underscore, existant)

### Formats de Donnees

**Reponses API REST :**
- Succes : `{"status": "ok", "data": {...}}`
- Erreur : `{"error": "description", "code": "ERROR_CODE"}`

**Messages WebSocket :**
- Format : `{"type": "message|thinking|tool_call|tool_result|error", "payload": {...}, "session_id": "..."}`

**Conventions JSON :**
- Champs : `snake_case` partout (Python natif)
- Dates : ISO 8601 (`2026-03-08T14:30:00Z`)
- Booleans : `true/false` (jamais `1/0`)
- Null : explicite quand le champ existe mais est vide, absent sinon
- MAC : uppercase sans colons (`0281662AA2C9`)

### Structure des Repos

- `ClawBot-OS/` → Bash, scripts de build, `src/modules/` un dossier par module
- `clawbot-cloud/` → Python FastAPI, `main.py` point d'entree unique
- `ClawbotCore/` → Python stdlib-only, `clawbot_core/` package, `tools/` outils built-in
- `ClawbotCore-WebUI/` → Vanilla JS, `index.html` SPA monolithique

**Regle cle :** chaque repo est autonome. Pas de dependance croisee. Communication uniquement via WebSocket ou REST API.

### Patterns de Communication

**WebSocket events (types standardises) :**
- `message` — texte utilisateur ou reponse LLM
- `thinking` — indicateur de reflexion IA
- `tool_call` — appel d'outil avec args
- `tool_result` — resultat d'outil
- `error` — erreur avec code
- `status` — etat connexion/service

**Modules → Core :**
- POST `http://127.0.0.1:{port}/v1/{tool_id}/execute`
- Body : `{"tool": "nom", "arguments": {...}}`
- Reponse : `{"result": "...", "error": null}`

### Patterns de Process

**Gestion d'erreurs :**
- Python : `try/except` avec logging avant propagation
- Jamais d'exception silencieuse (`except: pass` interdit)
- Erreurs utilisateur : message clair en francais, pas de stack trace
- Erreurs systeme : log complet + message generique a l'utilisateur

**Logging :**
- Device et cloud : `journald` via `systemd`, rotation automatique
- Format : `[SERVICE] LEVEL: message`
- Niveaux : `DEBUG`, `INFO`, `WARNING`, `ERROR`

**Retry/Reconnexion :**
- WebSocket : reconnexion automatique avec backoff exponentiel (1s, 2s, 4s, 8s, max 30s)
- API LLM : retry sur 429 avec backoff 60s (existant)
- Pas de retry sur 4xx (erreur client)

**Validation :**
- Entree utilisateur : validee cote API (Pydantic/FastAPI)
- Donnees inter-services : confiance (pas de double validation)
- Manifests modules : valides au chargement par ClawbotCore

### Performance Cloud : Python Asyncio Suffit

**Decision :** Pas de reecriture Go. Le cloud fait du proxy I/O (recoit JSON, forward a Anthropic, renvoie). Python asyncio gere des milliers de WebSocket simultanees car le travail est I/O-bound, pas CPU-bound.

**Optimisation DB :** Ecriture tokens en batch (fin de session ou toutes les 5 min), pas a chaque message. Divise les ecritures DB par ~100x.

**Profil de charge 1000 users simultanes :**
- 1000 WebSocket en memoire (~50MB RAM)
- ~200 ecritures DB/heure (fins de sessions)
- Bottleneck = Anthropic API (temps de reponse), pas le serveur

### Regles Obligatoires pour les Agents IA

1. `stdlib-only` sur ClawbotCore — aucun `pip install` sauf websockets
2. Pas de `localStorage`/`sessionStorage` dans le dashboard
3. `snake_case` partout en Python et JSON, `camelCase` en JS
4. Aucune mention de Claude/Anthropic dans les commits ou PR
5. Double underscore pour les noms d'outils de modules (`module__tool`)
6. WebSocket JSON comme unique protocole inter-composants
7. Logs rotatifs — jamais d'ecriture illimitee sur SD
8. Pas de polling — evenements push via WebSocket
9. Tokens DB en batch, pas par message
10. Vault chiffre : `pycryptodome` autorise comme exception stdlib-only (AES-256 pas dans stdlib)
11. Sanitize HTML obligatoire pour les panels modules (DOMPurify ou equivalent)

## Structure Projet & Frontieres

### Architecture Multi-Repos

```
ClawBot Ecosystem (4 repos independants)
├── ClawBot-OS/                    ← Firmware & build images
├── clawbot-cloud/                 ← API cloud FastAPI
├── ClawbotCore/ (clawbot-core)    ← Orchestrateur device Python
└── ClawbotCore-WebUI/             ← Dashboard SPA
```

### Repo 1 : ClawBot-OS (firmware)

```
ClawBot-OS/
├── .github/workflows/             ← CI GitHub Actions (4 variantes)
├── src/modules/                   ← Modules de build Armbian
│   ├── udev_fix/
│   ├── armbian/
│   ├── armbian_net/               ← WiFi, reseau, wifi-watchdog
│   ├── clawbot/                   ← Installation ClawbotCore + WebUI
│   ├── swap_setup/
│   ├── picoclaw/
│   ├── nginx_proxy/
│   ├── smartpad/                  ← SmartPad (rotation, cage, display)
│   ├── clawbot_core/
│   │   └── filesystem/root/usr/local/bin/
│   │       └── clawbot-cloud      ← Script tunnel device→cloud
│   ├── telegram_bot/
│   └── clawbot_wizard/            ← Wizard premiere connexion
├── build.sh
└── docs/planning-artifacts/
```

FRs couverts : FR11 (wizard reseau), FR15 (auto-enregistrement), FR37-FR42 (admin systeme)

### Repo 2 : clawbot-cloud (API)

```
clawbot-cloud/
├── main.py                        ← Point d'entree FastAPI
├── config.py                      ← Plans, model_ceiling, constantes
├── db.py                          ← Couche acces PostgreSQL
├── auth.py                        ← JWT, validation, admin
├── tunnel.py                      ← WebSocket tunnel device↔cloud
├── routes/
│   ├── users.py                   ← CRUD users, inscription, plans
│   ├── devices.py                 ← Provisioning, association MAC
│   ├── billing.py                 ← Tokens, quotas, groupes
│   └── admin.py                   ← Dashboard admin, flotte
├── middleware/
│   ├── rate_limiter.py            ← Token bucket par plan/groupe
│   └── cors.py
├── models/
│   ├── user.py                    ← User, Group (pool tokens)
│   ├── device.py                  ← Device, ActivationToken
│   └── session.py                 ← Sessions persistantes
├── tests/                         ← Tests API (pytest + httpx)
│   ├── test_users.py
│   ├── test_devices.py
│   ├── test_billing.py
│   └── test_tunnel.py
└── requirements.txt               ← FastAPI, asyncpg, pyjwt
```

Note : split routes/middleware/models requis pour travail parallele agents IA (evite conflits merge sur main.py monolithique).

FRs couverts : FR12-FR13 (QR/compte), FR16-FR21 (billing), FR28-FR31 (tunnel), FR33 (persistence), FR39 (MAJ distante)

### Repo 3 : ClawbotCore (orchestrateur device)

```
clawbot-core/
├── clawbot_core/
│   ├── main.py                    ← Orchestrateur principal, WebSocket server
│   ├── config.py                  ← Constantes (MAX_TOOL_ROUNDS, LLM_TIMEOUT...)
│   ├── llm/
│   │   ├── router.py              ← Smart LLM router (adapter pattern)
│   │   ├── anthropic.py           ← Adapter Anthropic (actuel)
│   │   ├── openai.py              ← Adapter OpenAI (Growth, urllib only)
│   │   └── deepseek.py            ← Adapter DeepSeek (Growth, urllib only)
│   ├── tools/
│   │   ├── bash.py
│   │   ├── python.py
│   │   ├── read_file.py
│   │   ├── write_file.py
│   │   ├── web_search.py
│   │   └── ssh.py
│   ├── modules/
│   │   ├── loader.py              ← Chargement manifests JSON
│   │   └── proxy.py               ← POST vers modules HTTP
│   ├── vault/
│   │   └── credential_vault.py    ← AES-256 via pycryptodome (exception stdlib)
│   ├── agents/
│   │   ├── manager.py             ← Gestion personas, historique
│   │   └── context.py             ← Compaction, memoire
│   └── session/
│       └── persistence.py         ← Sauvegarde/restauration sessions
├── tests/                         ← Tests unitaires (pytest)
│   ├── test_router.py
│   ├── test_tools.py
│   └── test_vault.py
└── modules/                       ← Modules installes (chacun autonome)
    ├── telegram/
    │   ├── manifest.json
    │   └── server.py
    └── [autres modules]/
```

Note : adapters LLM utilisent `urllib` (stdlib) uniquement, PAS `requests`/`httpx`. Exception stdlib : `pycryptodome` pour le vault AES-256.

FRs couverts : FR1-FR6 (chat IA), FR7-FR10 (agents), FR43-FR47 (modules), FR48-FR50 (vault)

### Repo 4 : ClawbotCore-WebUI (dashboard)

```
ClawbotCore-WebUI/
├── index.html                     ← SPA structure + init
├── css/
│   └── style.css                  ← Dark cyan theme, responsive
├── js/
│   ├── app.js                     ← Init, routing panels, WebSocket
│   ├── chat.js                    ← Chat, thinking, tool trace
│   ├── agents.js                  ← Panel agents, personas
│   ├── files.js                   ← Navigateur fichiers
│   ├── monitor.js                 ← CPU, RAM, services
│   ├── config.js                  ← Settings, WiFi, plans
│   ├── setup.js                   ← Wizard onboarding
│   └── modules/                   ← Panels dynamiques charges par module
│       └── [module_id].js
├── assets/
│   ├── fonts/                     ← Outfit, JetBrains Mono
│   └── icons/
└── lib/
    ├── marked.min.js
    ├── highlight.min.js
    └── purify.min.js              ← DOMPurify — sanitize HTML modules
```

**Mapping fichiers JS ↔ features :**
- `chat.js` → FR1-FR3, FR6 (chat, historique, tool trace)
- `agents.js` → FR7-FR9 (personas, selection, switch)
- `files.js` → FR22-FR24 (navigation, upload, fichiers)
- `monitor.js` → FR40-FR42 (logs, CPU/RAM, services)
- `config.js` → FR14, FR19 (mode, plans)
- `setup.js` → FR11-FR13 (wizard, QR, onboarding)

FRs couverts : FR2 (thinking), FR3 (historique), FR6 (tool trace), FR22-FR24 (fichiers), FR34 (etat connexion), FR35-FR36 (notifications, stats), FR40-FR42 (admin), FR45-FR46 (modules, panels), FR57 (SmartPad)

### Frontieres Architecturales

```
┌─────────────┐     WebSocket      ┌──────────────┐    HTTPS    ┌───────────┐
│  Dashboard   │◄──────────────────►│  ClawbotCore  │◄──────────►│  Anthropic │
│  (WebUI)     │     localhost       │  (device)     │   tunnel    │  API       │
└─────────────┘                     └──────┬───────┘            └───────────┘
                                           │
                              WebSocket    │    REST localhost
                              (WSS)        │    (modules)
                                           │
                                    ┌──────┴───────┐
                                    │ clawbot-cloud │
                                    │ (VPS IONOS)   │
                                    │ + PostgreSQL   │
                                    └───────────────┘
```

**Regle absolue :** aucune dependance croisee entre repos. Toute communication passe par WebSocket ou REST API.

### Mapping FRs → Repos

| Domaine FR | Repo principal | Repos secondaires |
|-----------|---------------|-------------------|
| AI Chat (FR1-6) | ClawbotCore | WebUI (affichage) |
| Agents (FR7-10) | ClawbotCore | WebUI (panels) |
| Onboarding (FR11-15) | ClawBot-OS + cloud | WebUI (wizard) |
| Billing (FR16-21) | clawbot-cloud | WebUI (config) |
| Fichiers (FR22-27) | ClawbotCore | WebUI (navigateur) |
| Tunnel (FR28-34) | clawbot-cloud | ClawbotCore (client WS) |
| Notifications (FR35-36) | ClawbotCore | WebUI + cloud |
| Admin (FR37-42) | ClawbotCore | WebUI (monitor) |
| Modules (FR43-47) | ClawbotCore + OS | WebUI (panels dynamiques) |
| Vault (FR48-50) | ClawbotCore | — |
| API externe (FR51-52) | clawbot-cloud | — |
| Multi-user (FR53-54) | clawbot-cloud | ClawbotCore |
| SmartPad (FR57) | ClawBot-OS | WebUI (avatar) |

### Flux de Donnees

1. **Chat** : User → WebUI (WS) → ClawbotCore → tunnel (WS) → cloud → Anthropic → retour inverse
2. **Tool** : ClawbotCore → tool built-in ou module REST → resultat → injecte dans contexte LLM
3. **Tokens** : ClawbotCore compte → batch fin de session → cloud API → PostgreSQL UPDATE
4. **OTA** : Cloud notifie → device update manager → git pull par repo → systemctl restart

### Ameliorations Party Mode (validees)

1. Split clawbot-cloud en routes/middleware/models (prerequis travail parallele agents)
2. Adapters LLM = urllib uniquement (coherence stdlib-only)
3. Vault chiffre : pycryptodome autorise comme exception stdlib-only
4. Dossiers tests/ dans clawbot-cloud et clawbot-core (pytest)
5. Mapping fichiers JS ↔ features documente (reduit conflits merge)
6. DOMPurify pour sanitize HTML des panels modules (securite XSS)

## Protocole de Versionnement API

### Strategie : URL Prefix Versioning

Convention : `/v{N}/resource` (deja en place avec `/v1/`). Le plus simple, le plus visible, zero ambiguite.

### Regles de Versionnement

**Incrementer la version majeure (v1 → v2) quand :**
- Suppression d'un champ obligatoire dans la reponse
- Changement de type d'un champ (string → int)
- Modification du format d'authentification
- Changement de la structure WebSocket (`type`/`payload`)

**PAS de nouvelle version pour :**
- Ajout d'un champ optionnel dans la reponse
- Ajout d'un nouvel endpoint
- Ajout d'un nouveau `type` WebSocket
- Changement interne (refactoring, optimisation)

### Compatibilite Multi-Version

```python
# clawbot-cloud/main.py
app.include_router(v1_router, prefix="/v1")  # Maintenu tant que des devices l'utilisent
app.include_router(v2_router, prefix="/v2")  # Nouvelle version
```

### Cycle de Vie d'une Version

```
Active → Deprecated (6 mois) → Sunset (suppression)
```
- **Active** : supportee, bugs corriges
- **Deprecated** : fonctionne, header `X-API-Deprecated: true` + `Sunset: <date>` dans les reponses, devices logguent un warning
- **Sunset** : supprimee apres 95%+ des devices migres (verifiable via logs)

### Versionnement WebSocket

```json
// Handshake initial
{"type": "hello", "protocol_version": 1, "device_version": "1.4.2"}
// Reponse cloud
{"type": "hello_ack", "protocol_version": 1, "min_supported": 1}
```

Cloud supporte toujours `protocol_version` N et N-1. Version trop vieille → `{"type": "error", "code": "UPGRADE_REQUIRED"}` + OTA force.

### Versionnement Modules (manifest.json)

```json
{
  "module_id": "telegram",
  "api_version": 1,
  "min_core_version": "1.0.0"
}
```

- `api_version` : version du protocole module↔core
- `min_core_version` : version minimale de ClawbotCore requise
- ClawbotCore refuse de charger un module incompatible (log warning + skip)

### Matrice de Compatibilite

| Composant | Controle MAJ | Delai migration |
|-----------|-------------|-----------------|
| clawbot-cloud | Deploiement immediat | 0 |
| ClawbotCore | OTA automatique | 24-48h |
| Dashboard WebUI | OTA automatique | 24-48h |
| Modules tiers | Auteur du module | Variable |

**Regle :** Le cloud DOIT supporter la version N-1 pendant minimum 1 semaine apres un push OTA.

## Architecture Decision Records (ADR)

### ADR-001 : PostgreSQL au lieu de SQLite (Cloud)

- **Statut :** Accepte
- **Contexte :** Scenario Kickstarter, milliers de devices ecrivent simultanement. SQLite = single-writer lock.
- **Options :** A) SQLite (en place, plafond ~50 ecritures concurrentes) | B) PostgreSQL (zero cout supplementaire, ecritures concurrentes natives) | C) MySQL (viable mais pas d'avantage)
- **Decision :** PostgreSQL
- **Consequences :** Migration driver sqlite3 → asyncpg. Schema identique. Backup pg_dump quotidien.
- **Risque accepte :** Complexite operationnelle legerement superieure. Mitigue par defauts PostgreSQL adaptes au volume.

### ADR-002 : Python Asyncio, pas de reecriture Go (Cloud)

- **Statut :** Accepte
- **Contexte :** Performance cloud pour 1000+ WebSocket simultanees.
- **Options :** A) Python/FastAPI (I/O-bound, asyncio suffit, ~50MB/1000 WS) | B) Go (meilleur CPU, mais reecriture totale) | C) Hybride Go+Python (complexite doublee)
- **Decision :** Python/FastAPI
- **Consequences :** Bottleneck = Anthropic API, pas le serveur. Scaling horizontal (dupliquer VPS).
- **Risque accepte :** Si workload CPU-bound futur → reevaluer. Pas le cas en agregateur pur.

### ADR-003 : VPS Prix Fixe, pas AWS/GCP

- **Statut :** Accepte
- **Contexte :** Couts maitrisables et previsibles.
- **Options :** A) VPS IONOS/Hetzner/Hostinger (~€5-15/mois fixe) | B) AWS/GCP (auto-scaling, vendor lock-in, couts imprevisibles) | C) Hybride VPS + Cloudflare DNS
- **Decision :** VPS prix fixe + Cloudflare DNS optionnel
- **Consequences :** Scaling manuel. Pas de managed DB. Pre-provisionning avant Kickstarter.
- **Risque accepte :** Scaling manuel peut prendre quelques heures en pic. Mitigue par pre-provisionning.

### ADR-004 : WebSocket comme protocole universel

- **Statut :** Accepte
- **Contexte :** Streaming temps reel (tokens LLM un par un), bidirectionnel.
- **Options :** A) WebSocket JSON (bidirectionnel, streaming natif) | B) REST + SSE (unidirectionnel server→client) | C) gRPC (lourd pour H3, pas supporte navigateurs)
- **Decision :** WebSocket JSON
- **Consequences :** Sticky sessions obligatoires en load balancing. Reconnexion backoff exponentiel.
- **Risque accepte :** Stateful, plus complexe a scaler que REST. Accepte car streaming LLM l'exige.

### ADR-005 : Agregateur LLM pur, aucun engagement provider

- **Statut :** Accepte
- **Contexte :** Dependance 100% Anthropic, marche LLM volatile.
- **Options :** A) Agregateur pur (adapter pattern, 1 fichier = 1 LLM) | B) Engagement Anthropic exclusif | C) Multi-provider des le MVP
- **Decision :** Agregateur pur, Anthropic seul au MVP, multi-provider en Growth
- **Consequences :** Adapters en urllib (stdlib). Routing par plan + par contenu. Interface abstraite des le MVP.
- **Risque accepte :** Couche d'abstraction supplementaire. Mitigee par simplicite de l'interface.

### ADR-006 : stdlib-only sur ClawbotCore (avec exceptions)

- **Statut :** Accepte
- **Contexte :** Device H3 1GB RAM, image minimale, pas de pip garanti.
- **Options :** A) stdlib strict (AES-256 et WS pas dans stdlib) | B) stdlib + websockets + pycryptodome | C) pip libre
- **Decision :** stdlib + 2 exceptions nommees
- **Consequences :** Adapters LLM = urllib. Parsing = json/re stdlib. Exceptions pre-installees dans l'image OS.
- **Risque accepte :** Si package casse compat ARM → fallback possible (hashlib, raw socket). Peu probable.

### ADR-007 : Vanilla JS, pas de framework frontend

- **Statut :** Accepte
- **Contexte :** Dashboard SPA servi en LAN, fondateur anti-framework.
- **Options :** A) Vanilla JS (zero build, controle total) | B) React/Vue (composants, mais toolchain lourde) | C) Lit/Web Components (leger mais learning curve)
- **Decision :** Vanilla JS avec split en fichiers thematiques
- **Consequences :** State = variables globales + evenements custom. DOMPurify pour sanitize. Mapping fichiers↔features documente.
- **Risque accepte :** Au-dela de ~5000 lignes, maintenabilite peut souffrir. Mitigue par split fichiers et conventions.

### ADR-008 : Token Pool Groupe (Growth)

- **Statut :** Planifie (Growth)
- **Contexte :** Familles avec plusieurs membres, besoin de partager quotas.
- **Options :** A) Pool sans limite de membres (regulation naturelle) | B) Pool avec limite (max 5, restrictif) | C) Pas de pool (penalise familles)
- **Decision :** Pool sans limite + CGV comme filet de securite
- **Consequences :** Rate limiting sur somme quotas groupe. Pricing adulte €8 (+200k/jour), enfant €2-3 (+50k/jour). Schema : `Group` + `User.group_id`.
- **Risque accepte :** Abus theorique (groupe 100 inconnus). Irrationnel en pratique. CGV en dernier recours.

### ADR-009 : Versionnement API par URL Prefix

- **Statut :** Accepte
- **Contexte :** Devices deployes avec OTA non instantanee (24-48h). Breaking change = devices cassees.
- **Options :** A) URL prefix `/v1/` (visible, simple, en place) | B) Header versioning (invisible, debugging penible) | C) Query param (pollue URLs)
- **Decision :** URL prefix
- **Consequences :** Cloud maintient N et N-1. Cycle Active → Deprecated (6 mois) → Sunset. WebSocket : `protocol_version` dans handshake. Modules : `api_version` dans manifest.
- **Risque accepte :** Duplication code entre versions. Mitigue par rarete des breaking changes.

## Resultats de Validation Architecture

### Validation de Coherence ✅

**Compatibilite des decisions :** Toutes les decisions fonctionnent ensemble sans contradiction. PostgreSQL + asyncpg + FastAPI = coherent. stdlib-only + 2 exceptions nommees = clair. WebSocket partout = un seul protocole. 9 ADRs documentent alternatives et risques acceptes.

**Coherence des patterns :** Conventions de nommage uniformes (snake_case Python/JSON, camelCase JS). Formats de donnees standardises. 11 regles obligatoires pour agents IA.

**Alignement structure :** 4 repos autonomes, zero dependance croisee. Communication uniquement WS/REST. Frontieres clairement documentees avec diagramme.

### Validation Couverture Requirements ✅

**Couverture Fonctionnelle :** 61/61 FRs couverts — mapping complet FR→repo documente dans la section Structure.

**Couverture Non-Fonctionnelle :** 26/26 NFRs adresses — performance (asyncio), ressources H3 (compaction, rotation logs), securite (WSS, AES-256, JWT), scalabilite (PostgreSQL, multi-VPS).

### Validation Pret pour Implementation ✅

**Completude des decisions :** 9 ADRs formalisees avec options/consequences/risques. Protocole de versionnement API complet (REST, WebSocket, modules). Sequence d'implementation priorisee (8 etapes).

**Completude de la structure :** 4 repos avec arborescences completes. Split cloud en routes/middleware/models. Directories de tests.

**Completude des patterns :** Nommage, data formats, WS events, error handling, logging, retry, validation — tout documente.

### Analyse de Gaps

**Gaps combles par elicitation avancee :**
- Versionnement API → Protocole complet ajoute (URL prefix, WS handshake, modules manifest)
- Decisions non formalisees → 9 ADRs avec options/consequences/risques

**3 gaps importants restants (non bloquants, adressables en sprint 1) :**
1. Strategie E2E tests — directories creees, framework a choisir (pytest + httpx probable)
2. Schema PostgreSQL detaille — tables documentees, DDL exact a ecrire lors de la migration
3. Flow QR provisioning detaille — endpoints documentes, sequence UX exacte a specifier en story

### Checklist de Completude Architecture

**✅ Analyse Requirements**
- [x] Contexte projet analyse (61 FRs, 26 NFRs, 7 contraintes, 6 cross-cutting)
- [x] Echelle et complexite evaluees (Medium-High, ~12-15 composants)
- [x] Contraintes techniques identifiees (H3 1GB, 4 repos, Moonraker, WebSocket)

**✅ Decisions Architecturales**
- [x] 9 ADRs formalisees avec versions, options, consequences, risques
- [x] Stack technologique complete (Python, FastAPI, PostgreSQL, Vanilla JS)
- [x] Patterns d'integration definis (WebSocket, REST, modules)
- [x] Performance adressee (asyncio, batch tokens, profil charge 1000 users)

**✅ Patterns d'Implementation**
- [x] Conventions de nommage etablies (DB, API, Python, JS, modules)
- [x] Patterns de structure definis (repos, fichiers, arborescences)
- [x] Patterns de communication specifies (WS events, module protocol)
- [x] Patterns de process documentes (erreurs, logging, retry, validation)

**✅ Structure Projet**
- [x] Arborescences completes pour 4 repos
- [x] Frontieres composants etablies (diagramme)
- [x] Points d'integration mappes (WS, REST, modules)
- [x] Mapping requirements→structure complet (FR→repo table)

**✅ Versionnement & ADRs**
- [x] Protocole versionnement API complet (REST, WS, modules)
- [x] Matrice de compatibilite documentee
- [x] 9 Architecture Decision Records formalisees

### Evaluation de Readiness

**Statut global :** PRET POUR IMPLEMENTATION

**Niveau de confiance :** HAUT — architecture coherente, complete, tous les FRs/NFRs couverts, gaps restants = details d'implementation

**Forces cles :**
- Architecture brownfield validee par le code existant en production
- 9 ADRs avec trade-offs explicites — zero decision implicite
- Regles agents IA claires (11 regles obligatoires) — coherence garantie
- Position agregateur LLM = flexibilite strategique maximale
- Scaling pragmatique (VPS prix fixe, PostgreSQL, horizontal)

**Axes d'amelioration future :**
- Schema PostgreSQL detaille (DDL) a formaliser en sprint 1
- Strategie E2E tests a definir (pytest + httpx)
- Flow QR provisioning : sequence UX a specifier en story
- Monitoring avance (metriques business, alerting multi-region)

### Handoff Implementation

**Directives pour agents IA :**
- Suivre toutes les decisions architecturales exactement comme documentees
- Utiliser les patterns d'implementation de maniere coherente sur tous les composants
- Respecter la structure projet et les frontieres
- Consulter ce document pour toute question architecturale
- Respecter les 11 regles obligatoires sans exception

**Premiere priorite d'implementation :**
Migration PostgreSQL (cloud) — prerequis pour scaling, rate limiting groupe, et multi-VPS
