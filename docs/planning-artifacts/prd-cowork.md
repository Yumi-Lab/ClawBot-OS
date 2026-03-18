---
stepsCompleted: [step-01-init, step-02-discovery, step-02b-vision, step-02c-executive-summary, step-03-success, step-04-journeys, step-05-domain, step-06-innovation, step-07-project-type, step-08-scoping, step-09-functional, step-10-nonfunctional, step-11-polish, step-12-complete]
inputDocuments:
  - 'docs/brainstorming/brainstorming-session-2026-03-16-cowork.md'
  - 'docs/planning-artifacts/prd.md'
  - 'docs/planning-artifacts/architecture.md'
  - 'docs/agents-personnalises/prd-agents-personnalises.md'
workflowType: 'prd'
documentCounts:
  briefs: 0
  research: 0
  brainstorming: 1
  projectDocs: 3
classification:
  projectType: 'desktop_app + developer_tool'
  domain: 'general'
  complexity: 'high'
  projectContext: 'brownfield'
---

# Product Requirements Document — OpenJarvis Cowork

**Author:** Nicolas
**Date:** 2026-03-16
**Version:** 1.0
**Parent:** docs/planning-artifacts/prd.md (PRD principal ClawBot)
**Ref:** FR58 du PRD principal

---

## Executive Summary

OpenJarvis Cowork est une application desktop cross-platform (Mac/Windows/Linux) qui transforme le boitier ClawBot en un coworker IA capable d'agir directement sur l'ordinateur de l'utilisateur. L'application se connecte au boitier via WebSocket — en LAN direct quand on est sur le meme reseau, ou via le cloud tunnel quand on est a l'autre bout du monde.

Contrairement a Claude Desktop qui utilise l'API cloud Anthropic comme cerveau, OpenJarvis Cowork utilise le boitier de l'utilisateur. Le cerveau IA vit chez lui, avec ses agents personnalises, sa memoire, ses donnees. L'app desktop est le bras articule qui donne a ce cerveau acces au PC.

Le produit repose sur deux piliers : un systeme de fichiers distant (navigateur de fichiers en MVP, sync Dropbox-like en Phase 2) et le Computer Use (l'IA prend la main sur l'ordinateur — screenshots, souris, clavier, commandes). L'app embarque egalement un hub MCP extensible permettant au boitier de piloter des serveurs MCP locaux (Chrome DevTools, filesystem, plugins tiers).

### Ce qui rend Cowork unique

1. **Le cerveau est prive** — Pas de serveur tiers generique. Les agents de l'utilisateur sont pimpes pour son business, avec sa memoire, ses documents. L'IA sait qui est "le client Dupont" parce qu'elle l'a appris au fil du temps.

2. **Accessible de partout** — Le boitier est chez toi, mais tu peux coworker depuis n'importe ou. Hotel, coworking, avion (avec connexion). Le cloud tunnel rend le boitier joignable sans VPN ni port forwarding.

3. **Hub MCP ouvert** — L'app expose des serveurs MCP locaux que le boitier consomme. Les devs communaute peuvent creer des serveurs MCP custom (Notion, Figma, Slack) et les plugger dans l'ecosysteme.

4. **Securite E2E** — Les screenshots Computer Use sont chiffres bout-en-bout. Le cloud tunnel transporte les donnees sans jamais voir le contenu. Les entreprises peuvent desactiver Computer Use par politique.

## Project Classification

- **Type de projet :** Desktop App + Developer Tool — bridge agent cross-platform (Tauri 2) + hub MCP extensible
- **Domaine :** General (assistant IA multi-profil, pas outil de recherche)
- **Complexite :** High — Computer Use E2E chiffre + dual mode LAN/cloud + MCP versioning + multi-profil Safe + 3 OS
- **Contexte :** Brownfield — extension de l'ecosysteme ClawBot existant (4 repos + 1 nouveau repo desktop)

## Success Criteria

### User Success

| Persona | Critere | Mesure | Seuil |
|---------|---------|--------|-------|
| **Marc (Pro)** | Delegation de tache | L'IA complete une tache operationnelle sur le PC | Tache completee sans intervention manuelle |
| **Marc (Pro)** | Diagnostic PC | L'IA diagnostique et resout un probleme technique | Resolution en <15 min (vs 1h+ sans) |
| **Marc (Pro)** | Acces fichiers distant | Naviguer les fichiers du boitier depuis un autre lieu | <3s pour lister un dossier via tunnel |
| **Sophie (Famille)** | Acces fichiers simple | Voir les fichiers du boitier depuis le laptop | Navigation fluide sans Computer Use |
| **Thomas (Dev)** | Plugin MCP | Creer et plugger un serveur MCP custom | <30 min pour un hello world MCP |
| **Karim (RSSI)** | Audit trail | Exporter le log des actions Computer Use | Export CSV complet et lisible |

### Business Success

| Horizon | Phase | Objectif | KPI |
|---------|-------|----------|-----|
| **0-3 mois** | MVP beta | Validation technique | 20+ testeurs actifs, connexion LAN+tunnel stable, zero crash 7j |
| **3-6 mois** | Lancement | Adoption early Pro | 100+ installations, retention >60% a 30j |
| **6-12 mois** | Growth | Expansion | 500+ installations, marketplace MCP servers, sync fichiers lance |
| **12+ mois** | Scale | Plateforme | 1000+ installations, 50+ MCP servers communaute |

### Technical Success

| Critere | Mesure | Seuil |
|---------|--------|-------|
| Latence Computer Use (LAN) | Temps screenshot → action → screenshot | <2s bout-en-bout |
| Latence Computer Use (tunnel) | Idem via cloud | <5s bout-en-bout |
| Connexion WebSocket | Stabilite de la connexion | Zero deconnexion non-recoveree sur 24h |
| Taille installeur | Poids du .dmg / .exe / .deb | <50MB |
| RAM au repos | Empreinte memoire tray mode | <100MB RSS |
| Auto-update | Mise a jour silencieuse | Aucune action utilisateur requise |

## User Journeys

### Journey 1 — Marc resout un bug depuis l'hotel (Pro, Computer Use)

Marc est en deplacement a Lyon. Son boitier ClawBot est a Bordeaux. Il ouvre l'app Cowork sur son laptop, elle se connecte automatiquement via le tunnel cloud. L'icone tray passe au vert — connexion etablie.

Il clique sur l'icone, le mini-panel s'ouvre. Il tape : "Mon logiciel de facturation plante au demarrage, aide-moi." L'app bascule en mode assiste. Son agent Sophie prend la main.

Sophie demande : "Je vais regarder ton ecran. Tu m'autorises ?" Marc clique Allow. Sophie prend un screenshot, voit le message d'erreur. "C'est un probleme de mise a jour Java. Je vais le corriger." Elle propose la commande. Marc valide. Sophie execute, relance l'application. Ca marche.

Duree totale : 8 minutes. Sans Cowork : appel au support IT, 1h minimum.

**Requirements reveles :** Connexion auto au boitier (LAN ou tunnel), mode assiste (validation par action), Computer Use (screenshot + commandes), permissions Allow/Deny par action, fonctionnement via tunnel distant.

### Journey 2 — Marc delegue une tache de recherche (Pro, delegation autonome)

Marc prepare un appel d'offres. Il ouvre l'app Cowork en mode expand (double-clic). Il selectionne son agent Max le Coordinateur et tape : "Compare les 5 meilleurs logiciels de gestion de chantier. Fais-moi un tableau comparatif dans un fichier Excel sur le boitier."

Max travaille en mode autonome. Il ouvre Chrome via MCP, visite les sites, prend des notes, compile. Marc regarde de temps en temps — il voit le stream de screenshots dans l'app. Apres 20 minutes, Max a cree un fichier Excel sur le boitier. Marc le voit apparaitre dans le file browser de l'app.

**Requirements reveles :** Mode autonome (surveillance passive), navigation Chrome via MCP, file browser distant (voir les fichiers du boitier), stream de screenshots en temps reel, creation de fichiers sur le boitier visible cote PC.

### Journey 3 — Sophie accede aux recettes depuis chez sa mere (Famille, file browser)

Sophie a un ClawBot Home. Elle est chez sa mere avec son laptop. Elle ouvre l'app Cowork. Connexion via tunnel. Elle ouvre le file browser et navigue dans le dossier "Recettes" que son agent a cree sur le boitier. Elle telecharge la recette de la semaine.

Pas de Computer Use — le mode Safe de son profil le desactive automatiquement. Pas de commandes bash. Juste du chat et du file browsing.

**Requirements reveles :** Profil Safe herite du boitier, Computer Use desactive par profil, file browser distant sans sync, telechargement de fichiers unitaire.

### Journey 4 — Karim audite les actions IA (RSSI Pro)

Karim est RSSI. Un employe a utilise l'app Cowork avec Computer Use pendant une semaine. Karim ouvre le panneau admin de l'app et exporte le log d'audit : chaque screenshot pris, chaque clic, chaque commande executee, avec horodatage et utilisateur.

Il verifie qu'aucune donnee confidentielle n'a fuite. Il constate que les screenshots sont chiffres E2E — le cloud tunnel n'a jamais vu le contenu. Il configure la politique d'entreprise : Computer Use autorise uniquement en mode assiste (validation par action), jamais en autonome.

**Requirements reveles :** Audit log exportable, chiffrement E2E des screenshots, politique d'entreprise configurable (desactiver/restreindre Computer Use), panneau admin.

### Journey 5 — Thomas cree un serveur MCP Notion (Dev communaute)

Thomas veut que son boitier puisse interagir avec Notion. Il cree un serveur MCP en TypeScript en suivant la doc du SDK MCP officiel. Il le bundle dans l'app Cowork via le registre de plugins. Au prochain demarrage, l'app annonce au boitier : "Nouveau MCP disponible : notion, version 1.0, 3 tools." Le boitier repond : "Compatible, active."

Maintenant quand Thomas demande a son agent de "mettre a jour le kanban Notion", l'agent appelle les tools du MCP Notion via l'app Cowork.

**Requirements reveles :** SDK MCP standard (TypeScript/Python), registre de plugins locaux, handshake de compatibilite MCP ↔ boitier, hot-reload des MCP servers.

### Journey Requirements Summary

| Capability | Journeys | Phase |
|-----------|----------|-------|
| Connexion WebSocket (LAN + tunnel) | Tous | MVP |
| Chat avec agents du boitier | Tous | MVP |
| File browser distant | Marc, Sophie | MVP |
| Computer Use (screenshot + actions) | Marc, Karim | MVP |
| Mode assiste (validation par action) | Marc, Karim | MVP |
| Mode autonome (surveillance passive) | Marc | MVP |
| Permissions Allow/Ask/Block | Marc, Karim | MVP |
| Profil Safe herite du boitier | Sophie | MVP |
| Stream screenshots temps reel | Marc | MVP |
| Tray icon + mini-panel | Tous | MVP |
| App expand (mode complet) | Marc, Thomas | MVP |
| Telechargement fichiers | Sophie | MVP |
| MCP servers integres (Chrome, FS) | Marc, Thomas | MVP |
| Installeur 2 clics + auto-update | Tous | MVP |
| Audit log Computer Use | Karim | Growth |
| Chiffrement E2E screenshots | Karim | Growth |
| Politique entreprise (desactiver CU) | Karim | Growth |
| Registre plugins MCP tiers | Thomas | Growth |
| Handshake compatibilite MCP | Thomas | Growth |
| Sync fichiers Dropbox-like | Marc | Phase 2 |
| Upload fichiers vers boitier | Marc | Phase 2 |

## Desktop App Specific Requirements

### Format du produit

**Hybride tray widget → app complete :**

- **Tray icon** — toujours actif en arriere-plan, indicateur de connexion (vert/rouge/orange)
- **Clic** = mini-panel : chat rapide + notifications agents + statut sync + derniere activite
- **Double-clic / expand** = app complete : file browser, Computer Use, panel agents, audit log

### Stack technique

- **Tauri 2** — Rust (backend natif) + TypeScript (frontend web)
- **Reference :** Jan.ai (Apache 2.0, Tauri, 41k stars) comme inspiration architecturale
- **Installeur :** .dmg (Mac), .exe NSIS (Windows), .deb + .AppImage (Linux)
- **Auto-update :** Tauri updater integre, silencieux, signature verifiee

### Dual connexion

| Mode | Quand | Protocole | Latence |
|------|-------|-----------|---------|
| **LAN direct** | Meme reseau que le boitier | WebSocket `ws://192.168.x.x:port` | <50ms |
| **Cloud tunnel** | Reseau different | WebSocket `wss://clawbot-api.yumi-lab.com` | 100-500ms |

**Detection automatique :** L'app tente d'abord la connexion LAN (mDNS ou IP sauvegardee). Si echec, bascule sur le tunnel cloud. Reconnexion automatique avec backoff exponentiel.

### Computer Use — Architecture

```
Boitier ClawBot (cerveau)
    │
    │  WebSocket : {"type": "computer_use", "action": "screenshot"}
    │
    ▼
App Cowork (bras)
    │
    ├── Capture screenshot (API OS native via Tauri)
    ├── Encode base64 + chiffre E2E (AES-256, cle partagee boitier↔app)
    ├── Envoie au boitier via WebSocket
    │
    ▼
Boitier : analyse screenshot via LLM → decide action
    │
    │  WebSocket : {"type": "computer_use", "action": "click", "x": 450, "y": 320}
    │
    ▼
App Cowork : execute l'action (clic souris a x,y)
    ├── Prend un nouveau screenshot
    └── Boucle agent continue...
```

**Actions supportees :**
- `screenshot` — capture ecran complet ou region
- `click` / `right_click` / `double_click` — clic a coordonnees (x, y)
- `type` — saisie texte
- `key` — raccourci clavier (ex: ctrl+s)
- `scroll` — scroll directionnel
- `mouse_move` — deplacement curseur
- `bash` — execution commande shell
- `open_app` — ouvrir une application

### MCP Hub — Architecture

```
App Cowork
    ├── MCP Server: filesystem (lecture/ecriture fichiers locaux)
    ├── MCP Server: chrome-devtools (navigation, clics, formulaires)
    ├── MCP Server: screenshot (capture ecran)
    ├── MCP Server: shell (execution commandes)
    └── [Plugins tiers: notion, figma, slack, ...]
         │
         │  Chaque MCP server expose des tools via le protocole MCP standard
         │
         ▼
    WebSocket vers boitier : {"type": "mcp_tools_available", "tools": [...]}
         │
         ▼
    Boitier : integre les tools MCP dans le contexte LLM de l'agent actif
```

**Handshake MCP au demarrage :**
```json
// App → Boitier
{"type": "mcp_hello", "servers": [
  {"name": "filesystem", "version": 1, "tools": ["read", "write", "list"]},
  {"name": "chrome", "version": 1, "tools": ["navigate", "click", "screenshot"]}
]}

// Boitier → App
{"type": "mcp_hello_ack", "accepted": ["filesystem", "chrome"], "rejected": []}
```

Support N et N-1 pour le versioning MCP. Meme strategie que l'API cloud.

### Securite

| Couche | Mecanisme | Ce qu'elle protege |
|--------|-----------|-------------------|
| **Transport** | WSS (TLS) pour le tunnel, WS local en LAN | Donnees en transit |
| **Chiffrement E2E** | AES-256, cle partagee lors du provisioning | Screenshots, contenu des actions — le cloud ne voit rien |
| **Permissions** | Allow / Ask / Block par type d'action | Utilisateur controle ce que l'IA peut faire |
| **Profil Safe** | Herite du boitier, desactive Computer Use + bash | Protection enfants et utilisateurs non-techniques |
| **Politique entreprise** | Config au niveau du boitier, propagee a l'app | RSSI desactive ou restreint des fonctionnalites |
| **Audit log** | Historique horodate de toutes les actions Computer Use | Tracabilite, conformite |

**Permissions granulaires :**

| Action | Defaut Particulier | Defaut Pro | Configurable |
|--------|-------------------|-----------|--------------|
| Screenshot | Ask | Ask | Oui |
| Clic / clavier | Ask | Ask | Oui |
| Execution commande | Ask | Ask | Oui |
| Lecture fichier PC | Allow | Allow | Oui |
| Ecriture fichier PC | Ask | Ask | Oui |
| Suppression fichier | Ask (toujours) | Ask (toujours) | Non |
| Navigation Chrome | Allow | Allow | Oui |
| Installation logiciel | Ask (toujours) | Ask (toujours) | Non |

### Profils herites du boitier

| Profil boitier | Computer Use | Bash/commandes | File browser | Chat | MCP |
|----------------|-------------|----------------|-------------|------|-----|
| **Geek** | Oui | Oui | Oui | Oui | Oui |
| **Pro** | Oui (configurable) | Oui (configurable) | Oui | Oui | Oui |
| **Particulier** | Oui | Non | Oui | Oui | Chrome uniquement |
| **Safe (enfant)** | Non | Non | Oui (read-only) | Oui | Non |

## Positionnement vs Dashboard Web

| | Dashboard web (index.html) | App Cowork (Tauri) |
|---|---|---|
| **Role** | Monitoring, config, chat simple | Assistant IA complet sur le bureau |
| **Acces** | Navigateur, aucune installation | Installée sur le PC |
| **Devices** | Smartphone, tablette, PC d'un ami | PC principal de l'utilisateur |
| **Computer Use** | Non (sandbox navigateur) | Oui |
| **Sync fichiers** | Non | Oui (Phase 2) |
| **MCP** | Non | Oui |
| **Commandes locales** | Non | Oui |
| **Toujours actif** | Non (onglet ferme = mort) | Oui (tray icon) |
| **Connexion** | LAN seulement (ou tunnel pour chat) | LAN + tunnel automatique |

**Les deux coexistent.** Le dashboard web reste l'interface principale pour le monitoring, la configuration et l'acces leger depuis n'importe quel appareil. L'app Cowork est pour le coworking actif — quand l'IA doit agir sur le PC.

## Project Scoping & Phased Development

### MVP (Phase 1 — 3 mois)

**Objectif :** Prouver que le concept fonctionne. Un utilisateur Pro peut se connecter a son boitier depuis n'importe ou et faire travailler ses agents sur son PC.

| Composant | Description |
|-----------|-------------|
| App Tauri scaffold | Shell Tauri 2, tray icon, mini-panel, mode expand |
| Connexion WebSocket | LAN direct + fallback tunnel cloud |
| Chat avec agents | Envoyer des messages, recevoir des reponses streamees |
| Panel agents | Liste des agents du boitier, selection, switch |
| Computer Use basique | Screenshot + clic + type + key + bash |
| Mode assiste | Popup Allow/Deny avant chaque action Computer Use |
| Mode autonome | Stream de screenshots, bouton Stop |
| File browser distant | Naviguer/lire/telecharger les fichiers du boitier |
| MCP servers integres | filesystem + chrome-devtools + screenshot + shell |
| Profil Safe | Herite du boitier, desactive Computer Use si Safe |
| Installeur | .dmg + .exe + .deb |
| Auto-update | Tauri updater |

**Explicitement hors MVP :**
- Sync fichiers Dropbox-like (file browser suffit)
- Chiffrement E2E (WSS suffit en beta)
- Audit log (logs basiques seulement)
- Registre plugins MCP tiers (MCP servers bundles seulement)
- Politique entreprise (Pro = config manuelle)
- Upload fichiers vers le boitier
- Taches planifiees depuis l'app

### Phase 2 — Growth (3-6 mois post-MVP)

| Feature | Justification |
|---------|---------------|
| Sync fichiers Dropbox-like | Le killer feature demande : sync selective, cache local, offline |
| Chiffrement E2E screenshots | Obligatoire pour les pros serieux (RGPD, confidentialite) |
| Audit log complet | Export CSV, historique horodate, filtrage par agent/action |
| Upload fichiers vers boitier | Bidirectionnel : PC → boitier, pas juste boitier → PC |
| Politique entreprise | Panneau admin : desactiver/restreindre Computer Use, bash, etc. |
| Notifications desktop | Agent a termine sa tache, fichier modifie, alerte boitier |
| Registre plugins MCP | Devs communaute publient et installent des MCP servers |
| Handshake MCP versioning | Support N et N-1, depreciation propre |

### Phase 3 — Vision (6-12 mois)

| Feature | Description |
|---------|-------------|
| Taches planifiees | "Tous les lundis a 9h, fais-moi un recap de mes emails" — schedule depuis l'app |
| Multi-device | Un boitier, plusieurs PC connectes simultanement |
| Collaboration | Partage d'ecran entre deux utilisateurs via le boitier |
| Voice input | STT integre dans l'app (Whisper ou STT natif OS) |
| Inter-box | Deux boitiers collaborent via l'app |
| Marketplace MCP | Store de plugins MCP avec installation one-click |

## Functional Requirements

### Connexion & Communication

- **CW-FR1:** L'app peut detecter et se connecter au boitier en LAN direct (mDNS ou IP sauvegardee)
- **CW-FR2:** L'app peut se connecter au boitier via le cloud tunnel quand le LAN n'est pas disponible
- **CW-FR3:** L'app peut basculer automatiquement entre LAN et tunnel sans intervention utilisateur
- **CW-FR4:** L'app peut se reconnecter automatiquement apres une coupure (backoff exponentiel)
- **CW-FR5:** L'app peut afficher clairement l'etat de connexion (connecte LAN / connecte tunnel / deconnecte)

### Chat & Agents

- **CW-FR6:** L'utilisateur peut envoyer des messages texte a ses agents via l'app
- **CW-FR7:** L'utilisateur peut voir les reponses streamees en temps reel (token par token)
- **CW-FR8:** L'utilisateur peut voir la liste de ses agents personnalises (employes) du boitier
- **CW-FR9:** L'utilisateur peut selectionner un agent et lui parler directement
- **CW-FR10:** L'utilisateur peut voir le thinking et le tool trace de l'agent
- **CW-FR11:** L'utilisateur peut consulter l'historique de ses conversations

### Computer Use

- **CW-FR12:** L'app peut capturer des screenshots de l'ecran sur demande du boitier
- **CW-FR13:** L'app peut executer des actions souris (clic, double-clic, drag, scroll) sur demande du boitier
- **CW-FR14:** L'app peut executer des actions clavier (saisie texte, raccourcis) sur demande du boitier
- **CW-FR15:** L'app peut executer des commandes shell (bash/PowerShell) sur demande du boitier
- **CW-FR16:** L'utilisateur peut voir un stream en temps reel des screenshots pris par l'IA
- **CW-FR17:** L'utilisateur peut stopper l'execution Computer Use a tout moment (bouton Stop)

### Permissions & Securite

- **CW-FR18:** Le systeme doit demander l'approbation de l'utilisateur avant chaque action Computer Use (mode assiste)
- **CW-FR19:** L'utilisateur peut basculer en mode autonome (l'IA execute sans demander, utilisateur surveille)
- **CW-FR20:** L'utilisateur peut configurer les permissions par type d'action (Allow / Ask / Block)
- **CW-FR21:** La suppression de fichiers et l'installation de logiciels requierent TOUJOURS une approbation
- **CW-FR22:** L'app doit heriter du profil du boitier (Safe = pas de Computer Use ni bash)
- **CW-FR23:** L'entreprise peut desactiver Computer Use par politique au niveau du boitier (Growth)
- **CW-FR24:** Toutes les actions Computer Use sont loguees avec horodatage (Growth)
- **CW-FR25:** Les screenshots sont chiffres E2E — le cloud tunnel ne voit pas le contenu (Growth)

### File Browser

- **CW-FR26:** L'utilisateur peut naviguer l'arborescence de fichiers du boitier
- **CW-FR27:** L'utilisateur peut lire le contenu d'un fichier du boitier
- **CW-FR28:** L'utilisateur peut telecharger un fichier du boitier vers son PC
- **CW-FR29:** L'utilisateur peut voir les fichiers crees par les agents en temps reel
- **CW-FR30:** L'utilisateur peut uploader un fichier de son PC vers le boitier (Phase 2)
- **CW-FR31:** L'utilisateur peut synchroniser selectivement des dossiers en local — sync Dropbox-like (Phase 2)
- **CW-FR32:** Les fichiers synchronises sont accessibles offline si le boitier est deconnecte (Phase 2)
- **CW-FR33:** Le systeme gere les conflits de modification (Phase 2)

### MCP Hub

- **CW-FR34:** L'app embarque des serveurs MCP de base : filesystem, chrome-devtools, screenshot, shell
- **CW-FR35:** L'app annonce les tools MCP disponibles au boitier a la connexion (handshake)
- **CW-FR36:** Le boitier peut appeler les tools MCP de l'app via WebSocket
- **CW-FR37:** L'utilisateur peut installer des plugins MCP tiers depuis un registre (Growth)
- **CW-FR38:** Le handshake MCP inclut le versioning — support N et N-1 (Growth)

### Interface

- **CW-FR39:** L'app dispose d'un tray icon toujours actif avec indicateur de connexion
- **CW-FR40:** Le clic sur le tray icon ouvre un mini-panel (chat rapide + notifications + statut)
- **CW-FR41:** Le double-clic ou un bouton expand ouvre l'app complete (file browser, Computer Use, agents)
- **CW-FR42:** L'installeur est en 2 clics maximum (.dmg / .exe / .deb)
- **CW-FR43:** L'app se met a jour automatiquement sans action utilisateur (Tauri updater)
- **CW-FR44:** L'app peut envoyer des notifications desktop (agent a termine, fichier modifie) (Growth)

## Non-Functional Requirements

### Performance

| Critere | Mesure | Seuil |
|---------|--------|-------|
| Latence Computer Use (LAN) | Screenshot → action → screenshot | <2s bout-en-bout |
| Latence Computer Use (tunnel) | Idem via cloud | <5s bout-en-bout |
| Taille screenshot compresse | JPEG quality pour transmission | <200KB par capture |
| Streaming chat | Premier token affiche | <3s apres envoi |
| File browser | Lister un dossier distant | <3s via tunnel |
| Demarrage app | Temps de lancement a froid | <3s |
| Reconnexion auto | Temps entre coupure et retablissement | <30s |

### Ressources

| Critere | Mesure | Seuil |
|---------|--------|-------|
| RAM tray mode | Empreinte memoire au repos | <100MB RSS |
| RAM app complete | Empreinte en utilisation active | <300MB RSS |
| Taille installeur | Poids du package | <50MB |
| CPU idle | Consommation au repos (tray) | <1% |
| Stockage | Espace disque installe | <200MB |
| Stockage sync (Phase 2) | Cache local fichiers synchronises | Configurable par l'utilisateur |

### Securite

| Critere | Mesure | Seuil |
|---------|--------|-------|
| Transport tunnel | Chiffrement | WSS (TLS 1.3) obligatoire |
| Chiffrement E2E (Growth) | Screenshots et actions | AES-256-GCM, cle partagee |
| Authentification | Identite du boitier | JWT valide du cloud |
| Permissions | Actions Computer Use | Systeme Allow/Ask/Block actif |
| Audit trail (Growth) | Actions loguees | 100% des actions Computer Use |
| Profil Safe | Heritage du boitier | Computer Use desactive si Safe |

### Compatibilite

| OS | Version minimale | Architecture |
|----|-----------------|-------------|
| macOS | 12 Monterey+ | ARM64 (Apple Silicon) + x64 |
| Windows | 10 (21H2)+ | x64 |
| Linux | Ubuntu 22.04+ / Fedora 38+ | x64 |

## Architecture — Nouveau Repo

### Repo 5 : openjarvis-cowork (nouveau)

```
openjarvis-cowork/
├── src-tauri/                    ← Backend Rust (Tauri 2)
│   ├── src/
│   │   ├── main.rs               ← Point d'entree Tauri
│   │   ├── websocket/
│   │   │   ├── client.rs         ← Client WebSocket (LAN + tunnel)
│   │   │   ├── discovery.rs      ← Detection boitier en LAN (mDNS)
│   │   │   └── reconnect.rs     ← Reconnexion backoff exponentiel
│   │   ├── computer_use/
│   │   │   ├── screenshot.rs     ← Capture ecran (API OS native)
│   │   │   ├── input.rs          ← Controle souris/clavier
│   │   │   ├── shell.rs          ← Execution commandes
│   │   │   └── permissions.rs    ← Allow/Ask/Block
│   │   ├── mcp/
│   │   │   ├── hub.rs            ← Gestionnaire MCP servers
│   │   │   ├── filesystem.rs     ← MCP server: fichiers locaux
│   │   │   ├── chrome.rs         ← MCP server: Chrome DevTools
│   │   │   └── registry.rs      ← Registre plugins tiers (Growth)
│   │   ├── files/
│   │   │   ├── browser.rs        ← Navigation fichiers boitier
│   │   │   ├── download.rs       ← Telechargement
│   │   │   └── sync.rs          ← Sync Dropbox-like (Phase 2)
│   │   ├── security/
│   │   │   ├── crypto.rs         ← Chiffrement E2E (Growth)
│   │   │   ├── audit.rs          ← Audit log (Growth)
│   │   │   └── profile.rs       ← Profil Safe herite du boitier
│   │   └── tray/
│   │       └── mod.rs            ← Tray icon + mini-panel
│   ├── Cargo.toml
│   └── tauri.conf.json
├── src/                          ← Frontend TypeScript
│   ├── App.tsx                   ← Shell principal
│   ├── components/
│   │   ├── TrayPanel.tsx         ← Mini-panel (chat rapide + statut)
│   │   ├── Chat.tsx              ← Chat avec agents
│   │   ├── AgentList.tsx         ← Liste des agents du boitier
│   │   ├── FileBrowser.tsx       ← Navigateur fichiers distant
│   │   ├── ComputerUse.tsx       ← Stream screenshots + controles
│   │   ├── Permissions.tsx       ← Popup Allow/Deny
│   │   └── StatusBar.tsx         ← Indicateur connexion
│   ├── lib/
│   │   ├── websocket.ts          ← Client WebSocket frontend
│   │   ├── mcp.ts                ← Interface MCP tools
│   │   └── store.ts             ← State management
│   └── styles/
│       └── globals.css           ← Dark cyan theme (coherent WebUI)
├── plugins/                      ← MCP servers tiers (Growth)
├── scripts/
│   ├── build-mac.sh
│   ├── build-win.sh
│   └── build-linux.sh
└── README.md
```

**Regle :** Ce repo est 100% autonome. Communication avec le boitier uniquement via WebSocket. Aucune dependance vers les 4 autres repos.

### Protocole WebSocket Cowork

**Events App → Boitier :**

| Type | Payload | Description |
|------|---------|-------------|
| `cowork_hello` | `{app_version, os, mcp_servers: [...]}` | Handshake initial |
| `chat_message` | `{agent_id, text, session_id}` | Message utilisateur |
| `computer_use_result` | `{action, screenshot_b64, success}` | Resultat d'action CU |
| `mcp_tool_result` | `{tool, result}` | Resultat d'appel MCP |
| `file_request` | `{path, action: "list|read|download"}` | Requete fichier |

**Events Boitier → App :**

| Type | Payload | Description |
|------|---------|-------------|
| `cowork_hello_ack` | `{agents: [...], profile, mcp_accepted}` | Reponse handshake |
| `chat_response` | `{agent_id, delta, type: "text|thinking|tool"}` | Streaming reponse |
| `computer_use_request` | `{action, params}` | Demande d'action CU |
| `mcp_tool_call` | `{server, tool, arguments}` | Appel MCP tool |
| `file_response` | `{path, content|listing}` | Reponse fichier |
| `agent_notification` | `{agent_id, message}` | Notification agent |

## Risques & Mitigations

| Risque | Probabilite | Impact | Mitigation |
|--------|------------|--------|------------|
| Latence Computer Use via tunnel | Haute | UX degradee | LAN prioritaire, compression screenshots JPEG, actions groupees |
| Prompt injection via Computer Use | Moyenne | Securite | Mode assiste par defaut, pas d'execution auto sans validation, audit log |
| Screenshots avec donnees sensibles | Haute | RGPD/legal | Chiffrement E2E (Growth), politique desactivation, audit trail |
| Sync fichiers = scope trap | Haute | Retard MVP | File browser distant en MVP, sync Phase 2 — decision actee |
| MCP servers tiers instables | Moyenne | Crash app | Sandboxing des plugins, handshake compatibilite, hot-reload |
| 3 OS a maintenir | Haute | Cout dev | Tauri cross-compile, CI multi-OS, beta par plateforme |
| Installeur trop complexe | Moyenne | Abandon | .dmg/.exe/.deb standard, 2 clics, auto-update |
| Concurrence Claude Desktop | Haute | Adoption | Differenciateur = agents perso + boitier prive + hub MCP ouvert |
| H3 trop lent pour router CU | Moyenne | Latence | Le boitier route vers le LLM, pas de traitement image cote H3 |

## Dependances

| Dependance | Status | Impact |
|------------|--------|--------|
| Tunnel WebSocket cloud | Fait (clawbot-cloud) | Route CW-FR2 |
| ClawbotCore agents API | Fait (FR7-FR10) | Fournit la liste agents |
| Agents personnalises | PRD ecrit, implementation en cours | Les agents que l'app expose |
| MCP SDK TypeScript | Open source (Anthropic) | Base des MCP servers bundles |
| Tauri 2 stable | Released | Framework de l'app |
| Computer Use protocol | Documente (Anthropic) | Boucle screenshot→action |

## IP & Licensing

- **Licence :** BUSL-1.1 (coherent avec l'ecosysteme ClawBot)
- **MCP servers bundles :** MIT (permet fork et redistribution par la communaute)
- **Plugins tiers :** licence libre du developpeur
- **Protection :** Le cloud tunnel est le verrou — l'app sans boitier provisionne ne sert a rien
