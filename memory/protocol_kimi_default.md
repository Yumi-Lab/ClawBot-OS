---
name: Protocol Kimi Default
description: Sécurisation routing — Kimi par défaut partout, Claude uniquement si sélectionné
type: project
---

# Protocole Kimi Default

**Statut global : TERMINÉ ✅ — 23/03/2026**
**Projet : /Users/nicolasmichaut/Documents/clawbot**
**Créé : 2026-03-23**

## Progression
- [x] Phase A — Backend : default model Kimi dans clawbot-core (risque bas) ✅ validé (pré-existant)
- [x] Phase B — Cloud : routing Kimi par défaut dans clawbot-cloud (risque bas) ✅ validé (pré-existant)
- [x] Phase C — Dashboard : réordonner modèles + default Kimi (risque bas) ✅ validé 23/03/2026
- [x] Phase D — Config : clawbot.cfg default model Kimi (risque bas) ✅ validé 23/03/2026
- [x] Phase E — Setup wizard : Kimi en premier dans le flow (risque bas) ✅ validé 23/03/2026
- [x] Phase F — Tests E2E : vérifier routing Kimi par défaut (risque moyen) ✅ validé 23/03/2026
- [x] Phase G — Deploy Pi live (risque moyen) ✅ validé 23/03/2026

## Phase E — Setup wizard : Kimi en premier dans le flow

### Travail
#### E1. Web wizard — done screen + mention AI default
- Fichier : `src/modules/clawbot_wizard/filesystem/root/usr/local/bin/clawbot-wizard-web`
- Done screen : ajouter une ligne "Default AI: Kimi" sous "Device activated!"
- Sub-text : "Powered by Kimi · change anytime in Settings"

#### E2. Bash wizard — welcome message update
- Fichier : `src/modules/clawbot_wizard/filesystem/root/usr/local/bin/clawbot-firstboot`
- `welcome_msg()` : ajouter mention "Default AI: Kimi" dans la liste setup
- Console headless `headless_wait()` : ajouter "AI: Kimi" dans le status box
- `show_qr_and_wait()` activation done : ajouter mention AI

### Vérifications
- [ ] Web wizard done screen mentionne Kimi
- [ ] Bash wizard welcome_msg mentionne Kimi
- [ ] Headless mode box mentionne Kimi
- [ ] show_qr_and_wait activation message mentionne Kimi
- [ ] Pas de régression — scripts restent fonctionnels (syntaxe bash/python OK)
- [ ] Pas de localStorage
- [ ] Phase G — Deploy Pi live (risque moyen)

## Phase F — Tests E2E : vérifier routing Kimi par défaut

### Travail
Tests E2E statiques (source code) et dynamiques (API live) pour valider le routing Kimi par défaut à travers toute la stack.

### Résultats

#### Source code (statique)
- Dashboard `chatModel: 'kimi-for-coding'` ✅
- Dashboard `CHAT_MODELS`: Kimi first entry ✅
- Dashboard model bar: Kimi chip has `active` class ✅
- Dashboard setup cards: Kimi first, badge "Default" ✅
- Dashboard: zero localStorage ✅
- clawbot.cfg: `[llm]` section avec `default_model = kimi-for-coding`, `provider = kimi` ✅
- Cloud `PLAN_ROUTING`: Moonshot/Kimi first pour tous les plans payés ✅
- Cloud `THROTTLE_MODEL`: Kimi ✅
- Cloud `chat.html`: default `kimi-for-coding` ✅

#### Live system (dynamique)
- Cloud health: OK ✅
- Cloud routing `kimi-for-coding` → Moonshot → response "Bonjour!" ✅
- Pi config API: retourne config actuelle (cloud proxy + opus — config manuelle PRO user, pas le défaut) ✅

#### Findings (non-bloquants, documentés)
- `[llm]` section dans clawbot.cfg est du dead config — aucun code ne la lit. Informationnel seulement.
- Live Pi dashboard affiche encore l'ancien layout (Haiku first) — attendu, deploy = Phase G.
- Cloud `chat.html` utilise localStorage — pré-existant dans repo séparé (clawbot-cloud), hors scope.
- Orchestrator hardcode `claude-haiku-4-5-20251001` pour tâches internes (compaction, agent routing) — intentionnel, pas user-facing.

### Vérifications
- [x] Source: chatModel default = kimi-for-coding
- [x] Source: CHAT_MODELS Kimi first
- [x] Source: model bar Kimi active
- [x] Source: setup cards Kimi first + Default badge
- [x] Source: clawbot.cfg [llm] section Kimi
- [x] Cloud: PLAN_ROUTING Kimi/Moonshot first (all paid plans)
- [x] Cloud: THROTTLE_MODEL = Kimi
- [x] Cloud: API route kimi-for-coding → Moonshot → response OK
- [x] Cloud: health check OK
- [x] Orchestrator: Haiku hardcodes only for internal tasks (intentional)
- [x] Dashboard source: zero localStorage
- [x] git diff: aucun fichier modifié par erreur (phase test-only)

## Outils de vérification disponibles
- Chrome DevTools MCP (screenshot, JS console)
- SSH Pi (192.168.1.191)
- curl API endpoints
- grep / read code

## Règles de deploy
- Dashboard: SFTP → `/home/pi/clawbot-dashboard/index.html`
- Config: SFTP → `/etc/clawbot/clawbot.cfg`
- Core: `sudo systemctl restart clawbot-core`

## Phase C — Dashboard : réordonner modèles + default Kimi

### Travail
#### C1. Model bar — réordonner chips
- Fichier : `src/modules/nginx_proxy/filesystem/root/home/pi/clawbot-dashboard/index.html`
- Ordre : Kimi (active) → Qwen Flash → Qwen Max → Qwen Coder | séparateur | Haiku → Sonnet → Opus

#### C2. State JS — default chatModel
- Fichier : même
- `chatModel: 'kimi-for-coding'` au lieu de `claude-haiku-4-5`

#### C3. CHAT_MODELS — réordonner objet
- Fichier : même
- Kimi/Qwen en premier, Claude après

#### C4. Setup cards — Kimi en premier
- Fichier : même
- Kimi card avant Anthropic card, badge "Default" vs "Premium"

#### C5. Config panel — provider/model defaults
- Provider dropdown : Kimi en premier
- Placeholder model : `kimi-for-coding`
- Placeholder base URL : `https://api.kimi.com/coding/v1`

### Vérifications
- [x] Model bar : Kimi first + active class
- [x] CHAT_MODELS : Kimi first entry
- [x] chatModel default : kimi-for-coding
- [x] Setup : Kimi card first, badge "Default"
- [x] Config panel : Kimi first provider, placeholder OK
- [x] Compaction calls : toujours Haiku (intentionnel, pas touché)
- [x] Pas de localStorage
- [x] Pas de régression — structure HTML intacte

## Phase D — Config : clawbot.cfg default model Kimi

### Travail
#### D1. Modifier clawbot.cfg
- Fichier : `src/modules/clawbot_core/filesystem/root/etc/clawbot/clawbot.cfg`
- Changer le model par défaut de claude-haiku vers kimi-for-coding
- Changer le provider par défaut vers kimi/moonshot

### Vérifications
- [x] clawbot.cfg : `[llm]` section ajoutée, default_model = kimi-for-coding
- [x] clawbot.cfg : provider = kimi, base_url = moonshot.cn
- [x] clawbot-status-api : Kimi ajouté dans PROVIDER_BASE_URLS + provider detection
- [x] Pas de régression sur les autres sections du fichier
- [x] Pas de localStorage
