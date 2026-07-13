---
name: Protocol WebSearch Fix
description: Fix web_search — Kimi loop, cloud 502, quality, page fetch, crash protection
type: project
---

# Protocole WebSearch Fix

**Statut global : EN COURS — Phase C a demarrer**
**Bonus B+ (qualite + page fetch) : TERMINE 03/04/2026**
**Projet : /Users/nicolasmichaut/Documents/clawbot-core**
**Cree : 2026-04-03**

## Progression
- [x] Phase A — Limiter les appels web_search repetes (risque bas) ✅ valide 03/04/2026
- [x] Phase B — Fix cloud 502 _from_tunnel (risque moyen) ✅ valide 03/04/2026
- [x] Phase B+ — Qualite recherche + page content fetch ✅ valide 03/04/2026
- [ ] Phase C — Crash protection timeouts (risque moyen)
- [ ] Phase D — Test integration E2E (risque bas)

## Outils de verification disponibles
- grep / read : code review
- git diff : verification pas de modification parasite
- SSH Pi (192.168.50.13) : test live
- curl : test API endpoints

## Regles de deploy
- SFTP vers Pi : `/usr/local/lib/clawbot-core/clawbot_core/orchestrator.py`
- Restart : `sudo systemctl restart clawbot-core`

## Phase A — Limiter les appels web_search repetes

### Contexte
Kimi (et parfois Claude) entre en boucle infinie d'appels web_search quand les resultats ne lui conviennent pas. Il rappelle web_search avec des variantes de la meme query, consumant des tokens et du temps.

### Travail
#### A1. Ajouter constante MAX_WEB_SEARCH_CALLS
- Fichier : `orchestrator.py`
- Ajouter `MAX_WEB_SEARCH_CALLS = 2` pres des autres constantes (ligne ~188)

#### A2. Compteur web_search dans chat_with_tools (non-stream)
- Fichier : `orchestrator.py`, fonction `chat_with_tools()`
- Initialiser `_web_search_calls = 0` avant la boucle
- Dans `_run_tc()`, verifier si le tool est dans `_WEB_SEARCH_TOOL_NAMES`
- Si oui et `_web_search_calls >= MAX_WEB_SEARCH_CALLS` : retourner un message d'erreur explicite demandant au LLM d'utiliser les resultats deja obtenus
- Sinon incrementer le compteur

#### A3. Compteur web_search dans chat_with_tools_stream (stream)
- Meme logique dans la version streaming

### Verifications
- [ ] grep MAX_WEB_SEARCH_CALLS → constante presente
- [ ] grep _web_search_calls → compteur dans les 2 fonctions (stream et non-stream)
- [ ] Le message d'erreur est clair pour le LLM
- [ ] git diff : seul orchestrator.py modifie
- [ ] Pas de regression : les tool calls non-web-search ne sont pas affectes

## Phase B — Fix cloud 502 _from_tunnel

### Contexte
Les endpoints cloud `/v1/kimi-web-search` et `/v1/claude-web-search` sont `async def` mais utilisent `urllib.request.urlopen` (bloquant). Ca gele l'event loop asyncio de FastAPI, provoquant des 502 quand d'autres requetes (notamment le stream `_from_tunnel`) sont en cours. De plus, le Pi attend 35s mais le cloud peut mettre 120s (Kimi 2 rounds x 60s).

### Travail
#### B1. Cloud — asyncio.to_thread pour kimi_web_search
- Fichier : `clawbot-cloud/app/routers/llm_proxy.py`
- Extraire la logique bloquante (les 2 rounds Kimi) dans une fonction sync `_kimi_search_sync()`
- Appeler via `await asyncio.to_thread(_kimi_search_sync, ...)`
- L'endpoint reste `async def` (besoin de `await request.json()`)

#### B2. Cloud — asyncio.to_thread pour claude_web_search
- Meme refactor pour `claude_web_search`
- Extraire dans `_claude_search_sync()`
- Appeler via `await asyncio.to_thread()`

#### B3. Pi — augmenter timeout web_search proxy
- Fichier : `clawbot-core/clawbot_core/orchestrator.py`
- `_web_search_kimi()` : timeout 35s → 90s
- `_web_search_claude()` : timeout 35s → 90s

### Verifications
- [ ] grep `to_thread` dans llm_proxy.py → present dans les 2 endpoints
- [ ] grep `timeout=90` dans orchestrator.py → present dans les 2 fonctions
- [ ] git diff cloud : seul llm_proxy.py modifie
- [ ] git diff core : seul orchestrator.py modifie
- [ ] Les endpoints retournent toujours le meme format JSON

## Phase C — Crash protection timeouts

### Contexte
Si un moteur de recherche (DuckDuckGo, Bing, Brave) est down ou tres lent, `_web_search()` peut bloquer le thread pendant longtemps. De plus, si le LLM produit un tool_call invalide ou un argument malformed, il n'y a pas de protection.

### Travail
#### C1. Timeout global sur _web_search (DDG/Bing/Brave)
- Fichier : `orchestrator.py`, fonction `_web_search()`
- Verifier que chaque engine a un timeout raisonnable (≤15s)
- Ajouter un timeout global sur l'ensemble de la fonction (max 30s total)

#### C2. Protection tool_call arguments malformed
- Fichier : `orchestrator.py`, fonctions `chat_with_tools()` et `chat_with_tools_stream()`
- Wraper l'appel `json.loads(arguments)` dans try/except
- Si malformed → retourner un message d'erreur clair au LLM

#### C3. Log structured pour debug
- Ajouter un log `[WEB_SEARCH]` avec query, engine, status, duree pour chaque appel
- Permettra de diagnostiquer les lenteurs en production

### Verifications
- [ ] Chaque engine dans `_web_search()` a un timeout ≤15s
- [ ] Arguments malformed → message d'erreur, pas de crash
- [ ] Logs `[WEB_SEARCH]` visibles dans journalctl

## Phase D — Test integration E2E

### Travail
#### D1. Test web_search via dashboard (local Pi)
- Ouvrir le dashboard, poser une question qui declenche web_search
- Verifier que les resultats s'affichent correctement
- Verifier les logs Pi `journalctl -u clawbot-core -f`

#### D2. Test web_search via cloud tunnel (_from_tunnel)
- Ouvrir openjarvis.io, poser une question web_search
- Verifier pas de 502, resultats corrects
- Verifier les logs cloud `journalctl -u clawbot-cloud -f`

#### D3. Test MAX_WEB_SEARCH_CALLS limit
- Poser une question qui genere plusieurs web_search
- Verifier que le compteur coupe apres 2 appels
- Verifier le message d'erreur au LLM

### Verifications
- [ ] Dashboard local : web_search fonctionne
- [ ] Cloud tunnel : web_search fonctionne, pas de 502
- [ ] Limite 2 appels : respectee
