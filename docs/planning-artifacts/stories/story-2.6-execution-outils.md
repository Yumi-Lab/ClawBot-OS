# Story 2.6 : Execution d'outils via l'IA

**Epic :** 2 — Chat IA Unifie — "Tu parles, ca fait"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** clawbot-core (orchestrator.py), ClawbotCore-WebUI (index.html)

---

## User Story

As a **utilisateur**,
I want **que l'IA execute des actions concretes (commandes, code, fichiers, recherche web, SSH)**,
So that **j'obtienne des resultats tangibles, pas juste du texte**.

---

## Acceptance Criteria

**Given** l'utilisateur demande une action qui necessite un outil systeme
**When** l'IA determine l'outil necessaire
**Then** l'outil est execute localement sur le boitier (bash, python, read_file, write_file)
**And** le resultat s'affiche dans le flux de conversation

**Given** l'utilisateur demande une recherche web
**When** l'IA utilise web_search
**Then** DuckDuckGo HTML est interroge et les resultats sont synthetises

**Given** l'utilisateur demande une connexion SSH a un serveur distant
**When** l'IA utilise l'outil ssh
**Then** la commande est executee sur le serveur distant et le resultat est retourne

**Given** un module expose des outils via manifest JSON
**When** l'IA determine qu'un outil de module est necessaire
**Then** l'outil est appele via POST `http://127.0.0.1:{port}/v1/{tool_id}/execute`
**And** le resultat est integre dans le contexte LLM

**Given** une commande dangereuse est detectee (systemctl stop/restart/kill sur services proteges)
**When** l'IA tente de l'executer
**Then** la commande est bloquee avec un message explicatif

---

## Technical Notes

### Outils built-in (ClawbotCore)
| Outil | Timeout | Notes |
|-------|---------|-------|
| `system__bash` | 30s | sshpass disponible |
| `system__python` | 30s | subprocess |
| `system__read_file` | — | lecture fichier local |
| `system__write_file` | — | ecriture fichier local |
| `system__web_search` | 10s | DuckDuckGo HTML scraping |
| `system__ssh` | 30s | sshpass sur le Pi |

### Services proteges (blocage systemctl)
```python
PROTECTED_SERVICES = ['clawbot-core', 'picoclaw', 'nginx', 'clawbot-cloud', 'clawbot-status-api']
DANGEROUS_COMMANDS = ['stop', 'restart', 'kill', 'disable', 'mask']
```

### Execution outils de module
```python
# POST http://127.0.0.1:{port}/v1/{module_id}/execute
# Body: {"tool": "tool_name", "arguments": {...}}
# Response: {"result": "..."} ou {"output": "..."} ou texte brut
# Timeout: TOOL_TIMEOUT = 10s
```

### Tool execution parallele
- `ThreadPoolExecutor(max_workers=4)` si multiple tool calls dans un round
- `asyncio.Queue` + `loop.call_soon_threadsafe()` pour SSE

### TOOL_RESULT_MAX_CHARS
- Truncate output a 6000 chars pour eviter overflow contexte
- Si truncate : ajouter `...[truncated]` a la fin

### Constantes ClawbotCore
```python
MAX_TOOL_ROUNDS = 15
LLM_TIMEOUT = 240
TOOL_TIMEOUT = 10
TOOL_RESULT_MAX_CHARS = 6000
```

### Contexte brownfield
Cette story couvre les fonctionnalites EXISTANTES et fonctionnelles.
L'objectif ici est de s'assurer que l'integration avec la Story 2.3 (chat unifie)
et Story 2.4 (tool trace) est propre et que les outils fonctionnent
avec le nouveau design system.
Pas de nouveau code backend pour cette story — uniquement wiring frontend.
