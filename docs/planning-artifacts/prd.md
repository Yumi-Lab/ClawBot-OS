---
stepsCompleted: [step-01-init, step-02-discovery, step-02b-vision, step-02c-executive-summary, step-03-success, step-04-journeys, step-05-domain, step-06-innovation, step-07-project-type, step-08-scoping, step-09-functional, step-10-nonfunctional, step-11-polish, step-12-complete]
inputDocuments: ['docs/planning-artifacts/product-brief-clawbot-2026-03-08.md', 'docs/brainstorming/brainstorming-session-2026-03-08-10h00.md']
workflowType: 'prd'
documentCounts:
  briefs: 1
  research: 0
  brainstorming: 1
  projectDocs: 0
classification:
  projectType: iot_embedded
  domain: scientific
  complexity: medium
  projectContext: brownfield
---

# Product Requirements Document - ClawBot

**Author:** Nicolas
**Date:** 2026-03-08

## Executive Summary

ClawBot est un boitier d'IA agentique cle en main destine aux professionnels (TPE/PME) et aux particuliers. Il transforme une stack open source complexe (orchestrateur Python, API cloud, dashboard web) en un produit physique que n'importe qui peut utiliser : brancher, scanner le QR code, c'est pret en moins de 10 minutes.

Le produit cible en priorite les entrepreneurs et dirigeants de TPE/PME (Phase 2 de lancement) qui perdent des heures sur des taches automatisables — devis, factures, emails, planning. ClawBot leur rend ce temps. Le marche grand public (familles, $8/mois) ouvre en Phase 3 quand les temoignages Pro circulent et que le bouche-a-oreille est amorce.

L'architecture repose sur ClawbotCore, un aggregateur pur (pattern Moonraker) qui route les requetes LLM et expose des modules independants via un systeme de manifests. Le hardware (Smart Pi One, H3) est fabrique dans l'usine du fondateur en Chine a cout marginal. Deux SKUs : ClawBot Home (~$80, familles) et ClawBot Pro (~$200, ecran + stockage + dock).

### Ce qui rend ClawBot unique

1. **L'effet drogue** — L'IA agentique cree une dependance immediate. Quand Marc genere un devis en 10 secondes au lieu d'une heure, il ne revient pas en arriere. Le produit se vend par l'experience et le bouche-a-oreille, pas par l'explication technique.

2. **Le dernier kilometre** — Les LLM sont matures en 2026, les outils existent, mais personne n'a fait le hardware agentique grand public. ClawBot comble ce gap avec un boitier physique qui materialise l'IA et la rend tangible.

3. **Pattern prouve** — Le fondateur a deja transforme un ecosysteme open source complexe en produit hardware turnkey vendu a des milliers d'unites. Meme strategie, meme execution, nouveau marche.

4. **Triple revenue** — Hardware (marge one-shot) + abonnement ($8-300/mois recurring) + marketplace communautaire (commission sur les modules).

## Project Classification

- **Type de projet :** IoT/Embedded — boitier hardware avec OS embarque, connectivite cloud, OTA, multi-interface
- **Domaine :** IA agentique (orchestration LLM, systeme de modules, multi-agent)
- **Complexite :** Medium — pas de compliance reglementaire lourde, mais stack technique multi-composants (4 repos, hardware + cloud + device + dashboard)
- **Contexte :** Brownfield — code existant dans 4 repos (ClawBot-OS, clawbot-cloud, ClawbotCore, ClawbotCore-WebUI), CI/CD fonctionnel, builds operationnels

## Success Criteria

### User Success

| Persona | Critere | Mesure | Seuil |
|---------|---------|--------|-------|
| **Marc (Pro)** | Gain de temps | Heures economisees/semaine, declaratif | "Je gagne X heures/semaine" |
| **Marc (Pro)** | Usage quotidien | Sessions/jour, retention daily | >80% retention daily |
| **Marc (Pro)** | Upsell naturel | Passage a un plan superieur | Augmentation abo = preuve de valeur |
| **Sophie (Famille)** | Adoption multi-users | Membres du foyer actifs | >2 users par boitier |
| **Sophie (Famille)** | Retention | Renouvellement mensuel | Renouvellement sans friction |
| **Tous** | Time-to-first-value | Temps scan QR → premiere reponse utile | <10 minutes |

### Business Success

| Horizon | Phase | Objectif | KPI mesurable |
|---------|-------|----------|---------------|
| **0-3 mois** | Beta GeekTech | Validation technique | 50-100 boitiers actifs, retention >80%, zero crash critique 7j consecutifs |
| **3-6 mois** | Lancement Pro | Premiers revenus | 10+ ClawBot Pro vendus, MRR >$2k, temoignages video |
| **6-12 mois** | Ouverture Particulier | Croissance organique | 500+ boitiers (Pro+Home), MRR >$20k, bouche-a-oreille mesurable |
| **12+ mois** | Scale | Machine autonome | 1000+ boitiers, marketplace active, marge Particulier positive |

### Technical Success

| Critere | Mesure | Seuil |
|---------|--------|-------|
| Stabilite | Uptime service continu | Zero crash critique sur 7 jours consecutifs |
| Performance | Temps de reponse LLM bout-en-bout | <5s pour une requete standard via tunnel |
| Module system | Chargement dynamique de modules | Un module s'installe et apparait dans le dashboard sans redemarrage |
| Tunnel cloud | Sessions paralleles | 4+ sessions WebSocket simultanees stables |
| Build CI/CD | Images flashables | 4 variantes buildent sans erreur |

### Measurable Outcomes

- **NPS >50** — recommandation organique, le bouche-a-oreille est le moteur de croissance
- **Churn <5% Pro, <10% Particulier** — si les gens restent, le produit marche
- **Cout API moyen par user** — a definir apres beta, c'est la marge reelle
- **Revenue par user Pro $200 → $400+** en 6 mois — la montee en valeur prouve l'adoption

## User Journeys

### Journey 1 — Marc decouvre la puissance (Pro, happy path)

Marc, 42 ans, patron d'une boite de services avec 8 salaries. Il fait tout lui-meme : compta, devis, planning, depannage IT. 60h/semaine. Il voit une pub LinkedIn : "Votre assistant IA pour $200/mois au lieu d'un salarie".

Il commande le ClawBot Pro. Le boitier arrive — ecran tactile, stockage, dock. Il branche, scanne le QR code. En 2 minutes il a un compte, mode Pro active. Le dashboard s'ouvre.

Il tape : "Genere-moi un modele de devis pour une prestation de conseil IT a la journee." En 10 secondes, il a un devis propre, formate, pret a envoyer. Il reste fige. "Ca me prenait l'apres-midi."

Semaine 2 : il connecte son Gmail. ClawBot lui fait un recap quotidien de ses emails importants. Il installe le module compta, charge ses factures sur le stockage USB. ClawBot classe, categorise, prepare la TVA.

Mois 3 : il a recupere 2h/jour. Il augmente son abo pour plus de tokens. Il montre le boitier a un ami entrepreneur. "T'as vu ce truc ? Ca change ta vie."

**Requirements reveles :** Onboarding QR <10 min, generation de documents, integration email (Gmail), module compta, stockage local USB, gestion de tokens/abo.

### Journey 2 — Marc face a une panne (Pro, edge case)

Vendredi 17h. Marc prepare un devis urgent pour lundi. Le tunnel cloud tombe — le boitier affiche "Connexion au serveur perdue".

Il ouvre l'app sur son telephone (dashboard web responsive). Meme message. Il attend 2 minutes. Le tunnel se reconnecte automatiquement (failover). Il reprend sa session exactement ou il en etait — rien n'est perdu, le brouillon de devis est toujours la.

Si le tunnel ne revient pas, le boitier reste fonctionnel en local : il peut acceder a ses fichiers, ses historiques de chat. Seules les nouvelles requetes LLM sont bloquees (elles necessitent le cloud).

**Requirements reveles :** Failover tunnel automatique, persistence de session, mode degrade local (fichiers accessibles sans cloud), notification claire de l'etat de connexion.

### Journey 3 — Sophie et la famille (Particulier, Phase 3)

Sophie, 38 ans, 2 enfants, mi-temps. Son mari ramene un ClawBot Home pour Noel ($80). Elle le branche dans la cuisine, scanne le QR code. Mode Safe automatique — pas de jargon, pas de config.

Premier reflexe : "Qu'est-ce qu'on mange cette semaine avec ce qu'il y a dans le frigo ?" ClawBot genere un planning repas. Elle est bluffee.

Le fils de 12 ans decouvre le boitier. "Aide-moi pour mon exercice de maths." ClawBot explique pas a pas. Sophie n'est plus derangee quand elle travaille.

En mode Safe, pas de commandes systeme, pas d'acces fichiers sensibles. Les enfants ne peuvent pas casser quoi que ce soit. Le budget API est plafonne a 200k tokens/jour — si la famille consomme beaucoup, ca ralentit en fin de journee plutot que de couper.

**Requirements reveles :** Mode Safe (restrictions commandes/fichiers), plafonnement tokens par jour (throttle, pas coupure), onboarding zero-config, interface simple sans jargon.

### Journey 4 — Nicolas, l'admin (Ops)

Nicolas gere la flotte de boitiers depuis le cloud. Un nouveau client Pro commande. Le boitier est flashe avec la derniere image CI/CD, expedie.

Le client scanne le QR code → le boitier s'enregistre automatiquement sur clawbot-cloud avec son MAC. Nicolas voit le device apparaitre dans le dashboard admin : MAC, plan, usage tokens, derniere connexion, version OS.

Alerte : un boitier beta n'a pas ping depuis 48h. Nicolas envoie un SSH distant via le tunnel pour diagnostiquer. Le service ClawbotCore a crashe. Il relance, verifie les logs, identifie un bug. Il pousse un fix via l'update manager (OTA).

**Requirements reveles :** Dashboard admin cloud, auto-enregistrement device, monitoring flotte (uptime, usage, versions), SSH distant via tunnel, OTA update manager, alerting.

### Journey 5 — Thomas, developpeur de modules (Marketplace, Growth)

Thomas est un dev de la communaute Yumi Lab. Il veut creer un module "assistant immobilier" pour les agents immobiliers.

Il lit la doc du SDK de module. Il cree un `manifest.json` avec ses tool_definitions, son port, son service. Il code en Python un serveur HTTP qui repond a `/v1/{tool_id}/execute`. Il teste en local sur son propre boitier en mode Geek.

Son module est pret. Il le soumet au marketplace. Apres validation, il est disponible. Un agent immobilier Pro l'installe depuis le dashboard — le nouveau panel "Immobilier" apparait automatiquement.

Thomas touche une commission sur chaque installation payante.

**Requirements reveles :** SDK de module documente, template manifest.json, systeme de soumission/validation marketplace, installation de module depuis le dashboard, commission tracking.

### Journey Requirements Summary

| Capability | Journeys | Priorite |
|-----------|----------|----------|
| QR onboarding (<10 min) | Marc, Sophie | MVP |
| Routing LLM + outils systeme | Marc, Sophie | MVP |
| Tunnel cloud + failover | Marc (panne), Nicolas | MVP |
| Persistence de session | Marc (panne) | MVP |
| Dashboard modulaire | Marc, Sophie, Nicolas | MVP |
| Module agent-manager | Marc | MVP |
| Auto-enregistrement device | Nicolas | MVP |
| OTA update manager | Nicolas | MVP |
| Mode Safe (restrictions) | Sophie | Growth |
| Dashboard admin cloud | Nicolas | Growth |
| Integration email (Gmail) | Marc | Growth |
| Module compta | Marc | Growth |
| Throttle tokens/jour | Sophie | Growth |
| SSH distant via tunnel | Nicolas | Growth |
| SDK de module + marketplace | Thomas | Growth |
| Commission tracking | Thomas | Vision |

## Domain-Specific Requirements

### Contraintes IoT / Embedded

- **Ressources limitees** — H3 1GB RAM, ARM 32-bit. ClawbotCore + modules doivent tenir dans ~500MB RSS. Monitoring memoire obligatoire.
- **Stockage SD** — Ecriture limitee, risque de corruption. Logs rotatifs, writes minimaux, journalisation filesystem.
- **Connectivite intermittente** — WiFi domestique/bureau pas toujours stable. Mode degrade local obligatoire, reconnexion automatique, queue de messages.
- **OTA sans bricker** — Mise a jour qui echoue = boitier mort chez le client. Fallback partition, validation post-update, rollback automatique.

### Contraintes IA / LLM

- **Dependance API externe** — 100% des requetes LLM passent par Anthropic. Si Anthropic tombe, ClawBot est muet. Mitigation : multi-LLM en Growth, cache de reponses frequentes en local.
- **Couts API imprevisibles** — Un user Pro qui abuse peut couter plus en tokens qu'il ne paye. Rate limiting par plan, monitoring cout/user, alerting si cout > seuil.
- **Qualite des reponses** — ClawBot depend de la qualite du LLM. Si Claude change de version et que les reponses degradent, le NPS chute. Mitigation : version pinning du modele, tests de regression sur des prompts de reference.
- **Securite des prompts** — Un user en mode Geek/Pro peut injecter des prompts malveillants via les outils systeme (bash, ssh). Sandboxing des commandes, blocage des commandes destructives sur services proteges (deja en place).

### Conformite & Donnees

- **RGPD** — Donnees utilisateur sur le boitier = responsabilite de l'utilisateur. Mais les requetes LLM transitent par le cloud Yumi puis Anthropic. Politique de non-retention a documenter. DPA (Data Processing Agreement) necessaire avec Anthropic.
- **Donnees de mineurs** — Sophie en mode Safe avec ses enfants. Pas de collecte de donnees sur le boitier au-dela du chat local. Le cloud ne voit que les tokens consommes, pas le contenu des conversations.
- **Credentials utilisateur** — Gmail, mots de passe stockes localement sur le boitier. Chiffrement at rest recommande (SD chiffree ou fichier de credentials chiffre).

## Innovation & Novel Patterns

### Detected Innovation Areas

**1. Nouvelle categorie de produit : le boitier agentique turnkey**

Aucun produit n'existe aujourd'hui a l'intersection de : hardware physique abordable (<$200) + IA agentique cloud + onboarding turnkey pour non-techniciens. Les tentatives anterieures (Rabbit R1, Humane AI Pin) ciblaient le remplacement du smartphone et ont echoue (~$200M perdus). ClawBot ne remplace rien — il ajoute une capacite inexistante.

**2. Architecture hybride edge-cloud optimisee pour le cout**

Contrairement aux "Home AI Servers" qui cherchent a tout faire tourner localement (hardware cher, Jetson a $200+), ClawBot utilise un hardware minimal (H3, $15) comme orchestrateur et delegue l'inference au cloud. C'est l'inverse du consensus "local-first" du CES 2026 — et c'est delibere : le cloud est le moat, pas un compromis.

**3. Modele "box telecom" applique a l'IA**

Credit d'abonnement offert egal au prix du hardware. Pattern de distribution eprouve en telecom, jamais applique a l'IA agentique. Reduit la friction d'achat a zero pour le hardware.

**4. Module marketplace comme effet reseau**

Le systeme de manifests JSON + SDK public permet a des devs tiers de creer des modules verticaux (immobilier, compta, medical) sans toucher au core. Chaque module ajoute de la valeur a l'ecosysteme, creant un effet reseau defavorable aux clones.

### Market Context & Competitive Landscape

| Segment | Exemples | Difference avec ClawBot |
|---------|----------|------------------------|
| AI mobile devices | Rabbit R1 (mort), Humane AI Pin (mort) | Gadgets de poche vs. outil de bureau/maison. Ils remplacent, ClawBot augmente. |
| Home AI Servers | FutureProofHomes Nexus1, DIY builds | Domotique/voix seulement. Hardware cher (Jetson). Cible geeks. |
| AI SaaS | ChatGPT, Claude.ai | Software only, pas de hardware physique, pas de donnees locales, pas de modules. |
| Smart speakers | Alexa, Google Home | Commandes pre-programmees, pas d'IA agentique. |
| Enterprise edge AI | Veea, NVIDIA AGX | B2B infrastructure, pas consumer. |

Aucun acteur n'occupe le segment "boitier agentique turnkey abordable pour PME et familles".

### Validation Approach

1. **Beta GeekTech (50-100 boitiers)** — valider la stabilite technique et le time-to-first-value (<10 min)
2. **Early adopters Pro (10+ clients)** — valider le ROI mesurable (heures economisees/semaine)
3. **Kickstarter** — valider la demande a grande echelle et generer de la visibilite investisseurs
4. **Metriques de validation** — retention daily >80%, NPS >50, upsell naturel comme signal d'adoption

## IoT/Embedded Specific Requirements

### Project-Type Overview

ClawBot est un produit IoT/Embedded hybride : un device physique (Smart Pi One, H3 ARM 32-bit) qui fonctionne comme orchestrateur agentique local avec un lien permanent vers le cloud via WebSocket. Le device ne fait pas d'inference IA locale — il delegue au cloud et execute les resultats localement (outils systeme, fichiers, modules).

### Hardware Requirements

| Spec | V1 (Smart Pi One) | V2 (Smart Pi One v2) | V2 Pocket (SmartPi 4.0) |
|------|-------------------|----------------------|--------------------------|
| SoC | AllWinner H3, ARM 32-bit | ARM 64-bit (meme format PCB) | ARM 64-bit (carte dediee) |
| RAM | 1GB DDR3 | 2-4GB | 2-4GB |
| Stockage | microSD (16-32GB) | microSD + eMMC | eMMC |
| Connectivite | WiFi + RJ45 Ethernet | WiFi + RJ45 | WiFi + 4G/5G (SIM slot a confirmer) |
| USB | 2x USB 2.0 (Pro: 2x1TB) | USB 3.0 | USB-C |
| Ecran | SmartPad (Pro SKU) | SmartPad (accessoire) | Aucun (SmartPad en accessoire) |
| Alimentation | 5V/2A secteur, ~2.5-3W | Secteur | Batterie rechargeable |
| Format | Boitier acrylique (Home) / Dock+ecran (Pro) | Meme boitier, memes connecteurs | Format cle/mini-routeur |

**Strategie industrielle** : V2 garde le meme format PCB et les memes connecteurs que V1 — seul le SoC change. Retrocompatibilite boitiers existants. SmartPi 4.0 (V2 Pocket) est une nouvelle carte mere dediee au format miniature.

### Connectivity Protocol

**WebSocket comme protocole universel :**

- **Device - Cloud** : WebSocket persistant (WSS), outbound depuis le device. Traverse NAT/firewall sans port forwarding. Reconnexion automatique. Sessions paralleles (4+ simultanees).
- **Device - Dashboard** : WebSocket local pour le dashboard web (SPA).
- **Device - Desktop (Growth)** : WebSocket pour le futur agent desktop — soft leger sur le PC qui permet a ClawBot de piloter l'ordinateur (commandes, fichiers, automatisation).
- **Fallback** : REST API en complement pour les operations non-temps-reel.
- **Pas de MQTT/BLE/mDNS** prevu en V1. WebSocket couvre tous les cas d'usage.

**Resilience physique** : debranchement du boitier = deconnexion securisee. Rebranchement → reboot automatique → resync avec le cloud → reprise de service. Zero donnee perdue (tout est sur le cloud + stockage local).

### Power Profile

- Consommation V1 : ~2.5W idle, ~3W en charge (H3 + WiFi + SD)
- Alimentation secteur 5V/2A obligatoire V1 — pas de batterie
- Cout energetique negligeable pour l'utilisateur (~$3/an)
- V2 Pocket : batterie rechargeable, consommation a optimiser

### Security Model

**V1 — Securite pragmatique, iterative :**

- **Identite device** : MAC address comme identifiant unique, associe au compte via QR code / provisioning cloud
- **Transport** : WebSocket sur HTTPS (WSS), certificats serveur
- **Commandes systeme** : sandboxing existant, blocage commandes destructives sur services proteges
- **Credentials utilisateur** : stockage local sur SD, chiffrement at rest post-MVP
- **Pas de certificat device** en V1 — validation via MAC + token de provisioning
- **Evolution** : certificat device, chiffrement SD, audit de securite avant scale

### Update Mechanism

**OTA Moonraker-style :**

- **Granularite** : par repository Git, pas par image complete. Chaque composant (ClawbotCore, WebUI, modules) se met a jour independamment via git pull sur releases/tags GitHub.
- **Dependances** : mise a jour des librairies Python selon les requirements de chaque repo.
- **Declenchement** : update manager lit les configs INI (`/etc/clawbot/clawbot.cfg` + `conf.d/*.cfg`), verifie les nouvelles versions, propose la mise a jour.
- **Pas de signature cryptographique** des updates en V1 — repos sur GitHub (HTTPS).
- **Pas de rollback automatique** en V1 — rollback manuel via git revert si necessaire.
- **Evolution** : signature des releases, rollback automatique sur boot failure, delta updates.

### Implementation Considerations

- **WebSocket partout** simplifie l'architecture : un seul protocole, un seul modele de securite transport
- **OTA par repo** permet des mises a jour incrementales sans risquer de bricker le device
- **Securite V1 volontairement legere** — risque acceptable en beta/early adopters, couches ajoutees avec le scale
- **Desktop agent (Growth)** — client leger multiplateforme qui recoit des commandes WebSocket du boitier pour piloter le PC de l'utilisateur
- **Retrocompatibilite hardware** — V2 meme PCB layout garantit que le meme OS/soft tourne sur V1 et V2

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**Approche MVP : Problem-Solving MVP** — livrer le minimum qui fait dire a un Pro "ca me change la vie". Un seul dev (fondateur) + vibe coding + ClawBot comme outil de dev.

**Ressources :** 1 fondateur solo, augmente par IA (vibe coding + ClawBot boxes en interne). Pas d'embauche prevue — le scaling de l'equipe passe par l'ajout de boitiers, pas de salaries. Un boitier avec les bons skills peut remplacer une equipe de devs specialises.

### MVP Feature Set (Phase 1 — Beta + Lancement Pro)

**Core Journeys supportes :** Marc (Pro happy path), Marc (panne/recovery)

**Must-Have :**

| Composant | Status | Description |
|-----------|--------|-------------|
| ClawbotCore stable | Quasi fait | Aggregateur pur, routing LLM, API REST + WebSocket, outils systeme |
| Tunnel cloud | Fait | WebSocket device-cloud, sessions paralleles, reconnexion auto |
| Dashboard web | Fait | SPA chat + fichiers + config + agents |
| QR code onboarding | A finaliser | Scan → compte → mode → pret en <10 min |
| Plans d'abonnement | A finaliser | Free/Particulier/Pro, gestion tokens, credit abo a l'achat |
| Agent-manager | En cours | Personas, multi-agent, selection modele, historique |
| OS image CI/CD | Fait | 4 variantes buildables, image flashable SD |

**Explicitement hors MVP :**
- Dashboard admin cloud (SSH + SQLite suffisent en beta, micro-dashboard rapide si besoin)
- Mode Safe (Particuliers = Phase 3)
- Modules compta/email (pas critique pour le "wow" Pro initial)
- Marketplace (pas de devs tiers en beta)
- Voice/Desktop agent

### Phase 2 — Growth (Post-lancement Pro)

| Feature | Justification |
|---------|---------------|
| App mobile PWA + Whisper STT | Les Pros veulent parler a leur boitier depuis le telephone |
| Mode Safe | Ouverture Particuliers (Phase 3 business) |
| Dashboard admin cloud | Necessaire a 200+ boitiers |
| Integration email (Gmail) | Le "wow" level 2 pour Marc |
| Module compta | Devis, factures, TVA — la killer app Pro |
| Multi-LLM | OpenAI, Mistral, modeles locaux — reduction dependance Anthropic |
| Kickstarter | Post-beta quand le soft est stable |
| SDK module + docs | Ouvrir l'ecosysteme aux devs tiers |
| Task scheduler | Taches recurrentes (backup, rapports, veille) |

### Phase 3 — Expansion (Vision)

| Feature | Description |
|---------|-------------|
| Desktop agent | Soft leger sur PC, ClawBot pilote l'ordinateur via WebSocket |
| Inter-box orchestration | Boitiers interconnectes en WebSocket, mode hierarchique maitre/esclaves, delegation de taches entre boxes |
| NAS Pro | Stockage RAID integre pour les pros |
| Marketplace active | Modules communautaires payants, commission tracking |
| SaaS-only | Mini VPS par user, meme stack, thin provisioning, pour ceux sans hardware |
| V2 hardware | ARM 64-bit meme PCB (retro-compatible), puis SmartPi 4.0 Pocket (carte dediee, format miniature, batterie, 4G/5G optionnel) |
| Ecosysteme distribue | Chaque boitier est un noeud d'un reseau d'agents collaboratifs |

## IP & Licensing Strategy

- **Licence BUSL-1.1** — source-available mais usage commercial interdit sans accord. Conversion Apache 2.0 en 2036.
- **Protection reelle = le cloud** — sans provisioning sur clawbot-cloud, le boitier ne fonctionne pas. Tunnel, tokens, abonnements, tout passe par le serveur.
- **SDK de module public** — API documentee, template de module, protocole manifest.json. Les devs creent des modules sans acceder au core.
- **Modules non-critiques open source** — telegram, exemples, templates. Le core et le cloud restent BUSL.
- **Moat = vitesse d'execution + marque + ecosysteme** — pas la protection du code.

## Risques & Mitigations

| Risque | Probabilite | Impact | Mitigation |
|--------|------------|--------|------------|
| Anthropic augmente ses prix | Moyenne | Marge erodee | Multi-LLM (Growth), negociation volume, cache local |
| Panne cloud Yumi | Faible | Tous les boitiers muets | Infra redondante, mode degrade local |
| SD corrompue | Faible | Boitier inutilisable | Image recovery, backup USB, re-flash facile |
| Prompt injection via outils systeme | Moyenne | Securite compromise | Sandboxing, blocage commandes destructives |
| Categorie incomprise par le marche | Moyenne | Haut | Lancement Pro d'abord (comprennent le ROI), Particulier apres bouche-a-oreille |
| Clone chinois a bas cout | Faible a court terme | Moyen | Cloud lock-in + BUSL-1.1 + presence en Chine rend le rachat plus interessant que le clone |
| Le hardware physique ne prend pas | Faible | Haut | Pivot SaaS trivial : mini VPS par user, meme stack, thin provisioning |
| Commoditisation par Big Tech | Moyenne a long terme | Haut | Vitesse d'execution + ecosysteme modules |
| H3 1GB RAM limitant | Haute | Performance degradee | Compaction de contexte agressive (deja en place), migration V2 64-bit |
| Solo dev = bus factor de 1 | Haute | Bloquant | Vibe coding + ClawBot comme equipe de dev interne |
| Cout API > revenus par user | Moyenne | Marge negative | Monitoring cout/user des la beta, rate limiting par plan, ajustement pricing |
| Qualite LLM degrade (changement de version) | Faible | NPS chute | Version pinning du modele, tests de regression prompts de reference |

## Functional Requirements

### AI Interaction & Chat

- **FR1:** L'utilisateur peut envoyer un message texte et recevoir une reponse generee par un LLM
- **FR2:** L'utilisateur peut voir la progression du "thinking" de l'IA en temps reel pendant la generation
- **FR3:** L'utilisateur peut consulter et rechercher l'historique de ses conversations avec persistance entre sessions
- **FR4:** Le systeme peut compacter automatiquement le contexte quand il depasse le seuil pour maintenir la coherence
- **FR5:** L'utilisateur peut utiliser une palette etendue d'outils via l'IA : outils systeme (bash, python, fichiers), MCP servers, APIs externes, SSH vers serveurs distants, navigateur web (distant ou simule dans l'environnement interne), et tout outil expose par les modules installes
- **FR6:** Le systeme peut afficher les appels d'outils, leurs arguments et resultats dans le flux de conversation

### Agent Management

- **FR7:** L'utilisateur peut creer et configurer des agents specialises avec des personas et des instructions systeme
- **FR8:** L'utilisateur peut selectionner le modele LLM utilise par chaque agent (Haiku, Sonnet, Opus)
- **FR9:** L'utilisateur peut basculer entre plusieurs agents dans une meme session
- **FR10:** Le systeme peut router les requetes vers le bon modele LLM en fonction du plan de l'utilisateur et du plafond associe

### Device Setup & Onboarding

- **FR11:** L'utilisateur peut configurer la connexion WiFi/Ethernet du boitier au premier demarrage (wizard reseau)
- **FR12:** L'utilisateur peut scanner un QR code pour demarrer la creation de son compte
- **FR13:** L'utilisateur peut associer un boitier a son compte lors du premier demarrage
- **FR14:** L'utilisateur peut choisir son mode d'utilisation (Geek/Pro/Particulier) au premier lancement
- **FR15:** Le boitier peut s'enregistrer automatiquement sur le cloud avec son identifiant MAC

### Subscription & Billing

- **FR16:** L'utilisateur peut s'inscrire a un plan (Free, Particulier, Pro) avec les quotas de tokens associes
- **FR17:** Le systeme peut suivre la consommation de tokens par utilisateur en temps reel
- **FR18:** Le systeme peut appliquer le rate limiting quand un utilisateur atteint son quota quotidien
- **FR19:** L'utilisateur peut upgrader son plan pour augmenter son quota de tokens
- **FR20:** Le systeme peut offrir un credit d'abonnement equivalent au prix du boitier a l'achat
- **FR21:** L'utilisateur peut associer plusieurs boitiers a un meme compte

### File & Data Management

- **FR22:** L'utilisateur peut naviguer, lire et modifier des fichiers stockes localement sur le boitier
- **FR23:** L'utilisateur peut utiliser le stockage USB externe (Pro) pour ses donnees
- **FR24:** L'utilisateur peut telecharger des fichiers depuis le dashboard vers le boitier
- **FR25:** Le systeme peut generer et sauvegarder des documents (devis, rapports) dans le stockage local
- **FR26:** L'utilisateur peut exporter ses conversations et donnees (backup)
- **FR27:** L'utilisateur peut restaurer ses donnees depuis un backup apres un crash ou remplacement de SD

### Cloud Connectivity & Resilience

- **FR28:** Le boitier peut maintenir une connexion WebSocket persistante avec le cloud
- **FR29:** Le boitier peut reconnaitre automatiquement si la connexion tombe et la retablir
- **FR30:** L'utilisateur peut maintenir des sessions paralleles via le tunnel cloud
- **FR31:** L'utilisateur peut acceder a son boitier depuis n'importe ou via le cloud (pas seulement en LAN)
- **FR32:** L'utilisateur peut acceder a ses fichiers locaux meme quand le cloud est indisponible (mode degrade)
- **FR33:** Le systeme peut persister les sessions en cours pour permettre la reprise apres une coupure
- **FR34:** Le boitier peut afficher clairement l'etat de connexion a l'utilisateur

### Notifications & Analytics

- **FR35:** Le systeme peut notifier l'utilisateur d'evenements (tache terminee, quota atteint, MAJ disponible, erreur critique)
- **FR36:** L'utilisateur peut consulter ses statistiques d'usage (tokens consommes, agents les plus utilises, historique d'activite)

### System Administration & Updates

- **FR37:** L'administrateur peut verifier les mises a jour disponibles pour chaque composant (core, WebUI, modules)
- **FR38:** L'administrateur peut declencher une mise a jour OTA par composant via l'update manager
- **FR39:** L'administrateur peut forcer une mise a jour sur un ou plusieurs devices a distance
- **FR40:** L'administrateur peut consulter les logs systeme du boitier
- **FR41:** L'administrateur peut monitorer l'utilisation memoire et CPU du boitier
- **FR42:** L'administrateur peut redemarrer les services individuellement depuis le dashboard

### Module System

- **FR43:** Le systeme peut charger dynamiquement des modules via leur manifest JSON
- **FR44:** Un module peut exposer des outils (tools) accessibles par l'IA via le protocole REST standard
- **FR45:** L'utilisateur peut installer et desinstaller des modules depuis le dashboard
- **FR46:** Le dashboard peut afficher dynamiquement des panels specifiques a chaque module installe
- **FR47:** Un developpeur tiers peut creer un module en suivant le SDK et le template manifest (Growth)

### Credential Vault

- **FR48:** L'utilisateur peut stocker ses identifiants de services tiers (email, banque, outils) dans un vault de mots de passe chiffre local sur le boitier
- **FR49:** L'IA peut acceder aux credentials du vault pour se connecter aux services de l'utilisateur avec son autorisation
- **FR50:** Les credentials du vault ne quittent jamais le boitier (pas de transit cloud)

### API & Integrations (Growth)

- **FR51:** Un developpeur peut interagir avec ClawBot via API REST pour integrer des automatisations externes (Growth)
- **FR52:** Le systeme peut exposer des webhooks pour notifier des services tiers d'evenements (Growth)

### Multi-User & Modes (Growth)

- **FR53:** Le systeme peut restreindre les commandes systeme et l'acces aux fichiers en mode Safe (Growth)
- **FR54:** Plusieurs utilisateurs d'un meme foyer peuvent utiliser le boitier avec des sessions separees (Growth)

### Voice & Mobile (Growth)

- **FR55:** L'utilisateur peut dicter des messages vocaux via STT (speech-to-text) sur l'app mobile (Growth)
- **FR56:** L'utilisateur peut acceder au dashboard depuis un navigateur mobile responsive (Growth)

### SmartPad Display (MVP Pro)

- **FR57:** Le SmartPad peut afficher un avatar anime qui reflete l'etat d'activite du boitier (idle, travail, erreur) avec des controles minimaux (restart, deconnexion, MAJ, stats basiques)

### Desktop & Inter-Box (Vision)

- **FR58:** Le boitier peut piloter l'ordinateur de l'utilisateur via un agent desktop WebSocket (Vision)
- **FR59:** Plusieurs boitiers peuvent s'interconnecter en WebSocket pour deleguer des taches entre eux (Vision)
- **FR60:** Un boitier peut etre configure en role Master, Esclave ou Mixte au moment du linking avec un autre boitier (Vision)
- **FR61:** Un boitier Master peut orchestrer et distribuer des taches aux boitiers lies selon leur role (Vision)

## Non-Functional Requirements

### Performance

| Critere | Mesure | Seuil |
|---------|--------|-------|
| Temps de reponse LLM (bout-en-bout) | Du clic "envoyer" au premier token affiche | <5s via tunnel cloud |
| Time-to-first-value | Du scan QR a la premiere reponse utile | <10 minutes |
| Demarrage du dashboard | Temps de chargement initial du SPA | <3s en LAN |
| Reconnexion tunnel | Temps entre deconnexion et retablissement WebSocket | <30s automatique |
| Execution d'outil | Temps entre l'appel d'outil et le retour du resultat | <10s (configurable par outil) |

### Reliability & Availability

| Critere | Mesure | Seuil |
|---------|--------|-------|
| Stabilite device | Uptime continu sans crash critique | 7 jours consecutifs minimum |
| Persistence de session | Sessions survivent a une coupure reseau/reboot | 100% des sessions actives restaurees |
| Tunnel cloud | Disponibilite du tunnel WebSocket | >99% hors maintenance planifiee |
| Mode degrade | Fonctionnalites locales accessibles sans cloud | Fichiers, historique, config toujours accessibles |
| OTA sans bricker | Mise a jour qui echoue ne rend pas le boitier inutilisable | Zero brick sur update (rollback si echec) |

### Resource Constraints (H3 / 1GB RAM)

| Critere | Mesure | Seuil |
|---------|--------|-------|
| Empreinte memoire | RAM utilisee par ClawbotCore + modules actifs | <500MB RSS total |
| Empreinte stockage SD | Espace disque utilise par l'OS + logiciel | <4GB (sur SD 16GB) |
| Ecriture SD | Volume d'ecriture quotidien (usure) | <100MB/jour (logs rotatifs, writes groupes) |
| CPU idle | Consommation CPU au repos | <10% (pas de polling inutile) |
| Sessions paralleles | WebSocket simultanees stables via le tunnel | 4+ sessions sans degradation |

### Security

| Critere | Mesure | Seuil |
|---------|--------|-------|
| Transport | Chiffrement des communications device-cloud | WSS (TLS) obligatoire |
| Credential vault | Chiffrement des identifiants stockes sur le boitier | Chiffrement AES-256 at rest |
| Commandes systeme | Protection contre les commandes destructives | Blocage systemctl stop/restart/kill sur services proteges |
| Authentification cloud | Securite des sessions utilisateur | JWT HS256, expiration 72h, rotation possible |
| Donnees en transit | Contenu des conversations via le tunnel | Chiffre bout-en-bout (WSS), pas de log cote cloud |
| RGPD | Non-retention des conversations cote cloud | Zero champ de contenu conversationnel dans la DB cloud, verifiable par audit schema |

### Scalability (Cloud)

| Critere | Mesure | Seuil |
|---------|--------|-------|
| Devices simultanes | Nombre de boitiers connectes au cloud | 100 devices (beta), 1000+ (scale) |
| WebSocket par device | Connexions WebSocket paralleles par boitier | 4+ sans degradation serveur |
| Base de donnees | Croissance des utilisateurs et devices | Supporte >500 users sans degradation de performance |
| API rate limiting | Requetes par seconde par utilisateur | Selon plan (Free/Particulier/Pro) |
| Cout API par user | Monitoring et alerte sur la marge | Alerte si cout API > 70% du revenu user |
