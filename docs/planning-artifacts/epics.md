---
stepsCompleted: [1, 2]
inputDocuments: ['docs/planning-artifacts/prd.md', 'docs/planning-artifacts/architecture.md', 'docs/planning-artifacts/ux-design-specification.md']
workflowType: 'epics-and-stories'
project_name: 'ClawBot'
user_name: 'Nicolas'
date: '2026-03-09'
---

# ClawBot - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for ClawBot, decomposing the requirements from the PRD, UX Design and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: L'utilisateur peut envoyer un message texte et recevoir une reponse generee par un LLM
FR2: L'utilisateur peut voir la progression du "thinking" de l'IA en temps reel pendant la generation
FR3: L'utilisateur peut consulter et rechercher l'historique de ses conversations avec persistance entre sessions
FR4: Le systeme peut compacter automatiquement le contexte quand il depasse le seuil pour maintenir la coherence
FR5: L'utilisateur peut utiliser une palette etendue d'outils via l'IA : outils systeme (bash, python, fichiers), MCP servers, APIs externes, SSH vers serveurs distants, navigateur web, et tout outil expose par les modules installes
FR6: Le systeme peut afficher les appels d'outils, leurs arguments et resultats dans le flux de conversation
FR7: L'utilisateur peut creer et configurer des agents specialises avec des personas et des instructions systeme
FR8: L'utilisateur peut selectionner le modele LLM utilise par chaque agent (Haiku, Sonnet, Opus)
FR9: L'utilisateur peut basculer entre plusieurs agents dans une meme session
FR10: Le systeme peut router les requetes vers le bon modele LLM en fonction du plan de l'utilisateur et du plafond associe
FR11: L'utilisateur peut configurer la connexion WiFi/Ethernet du boitier au premier demarrage (wizard reseau)
FR12: L'utilisateur peut scanner un QR code pour demarrer la creation de son compte
FR13: L'utilisateur peut associer un boitier a son compte lors du premier demarrage
FR14: L'utilisateur peut choisir son mode d'utilisation (Geek/Pro/Particulier) au premier lancement
FR15: Le boitier peut s'enregistrer automatiquement sur le cloud avec son identifiant MAC
FR16: L'utilisateur peut s'inscrire a un plan (Free, Particulier, Pro) avec les quotas de tokens associes
FR17: Le systeme peut suivre la consommation de tokens par utilisateur en temps reel
FR18: Le systeme peut appliquer le rate limiting quand un utilisateur atteint son quota quotidien
FR19: L'utilisateur peut upgrader son plan pour augmenter son quota de tokens
FR20: Le systeme peut offrir un credit d'abonnement equivalent au prix du boitier a l'achat
FR21: L'utilisateur peut associer plusieurs boitiers a un meme compte
FR22: L'utilisateur peut naviguer, lire et modifier des fichiers stockes localement sur le boitier
FR23: L'utilisateur peut utiliser le stockage USB externe (Pro) pour ses donnees
FR24: L'utilisateur peut telecharger des fichiers depuis le dashboard vers le boitier
FR25: Le systeme peut generer et sauvegarder des documents (devis, rapports) dans le stockage local
FR26: L'utilisateur peut exporter ses conversations et donnees (backup)
FR27: L'utilisateur peut restaurer ses donnees depuis un backup apres un crash ou remplacement de SD
FR28: Le boitier peut maintenir une connexion WebSocket persistante avec le cloud
FR29: Le boitier peut reconnaitre automatiquement si la connexion tombe et la retablir
FR30: L'utilisateur peut maintenir des sessions paralleles via le tunnel cloud
FR31: L'utilisateur peut acceder a son boitier depuis n'importe ou via le cloud (pas seulement en LAN)
FR32: L'utilisateur peut acceder a ses fichiers locaux meme quand le cloud est indisponible (mode degrade)
FR33: Le systeme peut persister les sessions en cours pour permettre la reprise apres une coupure
FR34: Le boitier peut afficher clairement l'etat de connexion a l'utilisateur
FR35: Le systeme peut notifier l'utilisateur d'evenements (tache terminee, quota atteint, MAJ disponible, erreur critique)
FR36: L'utilisateur peut consulter ses statistiques d'usage (tokens consommes, agents les plus utilises, historique d'activite)
FR37: L'administrateur peut verifier les mises a jour disponibles pour chaque composant (core, WebUI, modules)
FR38: L'administrateur peut declencher une mise a jour OTA par composant via l'update manager
FR39: L'administrateur peut forcer une mise a jour sur un ou plusieurs devices a distance
FR40: L'administrateur peut consulter les logs systeme du boitier
FR41: L'administrateur peut monitorer l'utilisation memoire et CPU du boitier
FR42: L'administrateur peut redemarrer les services individuellement depuis le dashboard
FR43: Le systeme peut charger dynamiquement des modules via leur manifest JSON
FR44: Un module peut exposer des outils (tools) accessibles par l'IA via le protocole REST standard
FR45: L'utilisateur peut installer et desinstaller des modules depuis le dashboard
FR46: Le dashboard peut afficher dynamiquement des panels specifiques a chaque module installe
FR47: Un developpeur tiers peut creer un module en suivant le SDK et le template manifest (Growth)
FR48: L'utilisateur peut stocker ses identifiants de services tiers dans un vault de mots de passe chiffre local
FR49: L'IA peut acceder aux credentials du vault pour se connecter aux services de l'utilisateur avec son autorisation
FR50: Les credentials du vault ne quittent jamais le boitier (pas de transit cloud)
FR51: Un developpeur peut interagir avec ClawBot via API REST pour integrer des automatisations externes (Growth)
FR52: Le systeme peut exposer des webhooks pour notifier des services tiers d'evenements (Growth)
FR53: Le systeme peut restreindre les commandes systeme et l'acces aux fichiers en mode Safe (Growth)
FR54: Plusieurs utilisateurs d'un meme foyer peuvent utiliser le boitier avec des sessions separees (Growth)
FR55: L'utilisateur peut dicter des messages vocaux via STT sur l'app mobile (Growth)
FR56: L'utilisateur peut acceder au dashboard depuis un navigateur mobile responsive (Growth)
FR57: Le SmartPad peut afficher un avatar anime qui reflete l'etat d'activite du boitier (MVP Pro)
FR58: Le boitier peut piloter l'ordinateur de l'utilisateur via un agent desktop WebSocket (Vision)
FR59: Plusieurs boitiers peuvent s'interconnecter en WebSocket pour deleguer des taches entre eux (Vision)
FR60: Un boitier peut etre configure en role Master, Esclave ou Mixte au moment du linking (Vision)
FR61: Un boitier Master peut orchestrer et distribuer des taches aux boitiers lies selon leur role (Vision)

### NonFunctional Requirements

NFR1: Temps de reponse LLM bout-en-bout <5s via tunnel cloud
NFR2: Time-to-first-value <10 minutes (du scan QR a la premiere reponse utile)
NFR3: Demarrage du dashboard <3s en LAN
NFR4: Reconnexion tunnel automatique <30s
NFR5: Execution d'outil <10s (configurable par outil)
NFR6: Stabilite device — uptime continu 7 jours consecutifs minimum sans crash critique
NFR7: Persistence de session — 100% des sessions actives restaurees apres coupure/reboot
NFR8: Tunnel cloud disponibilite >99% hors maintenance planifiee
NFR9: Mode degrade — fichiers, historique, config toujours accessibles sans cloud
NFR10: OTA sans bricker — zero brick sur update (rollback si echec)
NFR11: Empreinte memoire <500MB RSS total (ClawbotCore + modules actifs)
NFR12: Empreinte stockage SD <4GB (sur SD 16GB)
NFR13: Ecriture SD <100MB/jour (logs rotatifs, writes groupes)
NFR14: CPU idle <10% (pas de polling inutile)
NFR15: Sessions paralleles — 4+ WebSocket simultanees sans degradation
NFR16: Transport WSS (TLS) obligatoire pour device-cloud
NFR17: Credential vault chiffrement AES-256 at rest
NFR18: Blocage systemctl stop/restart/kill sur services proteges
NFR19: Authentification cloud JWT HS256, expiration 72h, rotation possible
NFR20: Donnees en transit chiffrees bout-en-bout (WSS), pas de log conversations cote cloud
NFR21: RGPD — zero champ de contenu conversationnel dans la DB cloud
NFR22: Devices simultanes — 100 (beta), 1000+ (scale)
NFR23: WebSocket par device — 4+ sans degradation serveur
NFR24: Base de donnees — >500 users sans degradation de performance
NFR25: API rate limiting par plan (Free/Particulier/Pro)
NFR26: Alerte si cout API > 70% du revenu user

### Additional Requirements

**Architecture :**
- Migration SQLite vers PostgreSQL sur le cloud (prerequis scaling — ADR-001)
- Protocole WebSocket uniforme JSON : type + payload + session_id
- Adapter pattern pour LLM providers (aggregateur pur, urllib stdlib-only — ADR-005)
- Split clawbot-cloud en routes/middleware/models (prerequis travail parallele)
- Versionnement API par URL prefix /v1/ avec cycle Active → Deprecated → Sunset (ADR-009)
- Handshake WebSocket avec protocol_version (ADR-009)
- Versionnement modules via api_version + min_core_version dans manifest.json
- Batch ecriture tokens en DB (fin de session ou toutes les 5 min, pas par message)
- DOMPurify pour sanitize HTML des panels modules (securite XSS)
- Pas de starter template — projet brownfield, code existant fonctionnel
- Token optimization niveau 1 : system prompt compresse, prompt caching Anthropic, max_tokens adaptatif
- Backup PostgreSQL pg_dump cron quotidien
- Multi-region EU + US + Chine avec geo-routing DNS (Growth)
- Pool de tokens groupe/famille avec Table Group + User.group_id (Growth — ADR-008)

**UX Design :**
- Vision "Un bouton, ca marche" — zero choix technique pour l'utilisateur
- Fusion des 3 modes chat (Core/Agent/Core-Agent) en une seule zone de texte invisible
- Routing LLM invisible — pas de selection de modele pour l'utilisateur
- Tool trace simplifie ("En train de chercher...", pas de noms d'outils techniques sauf mode Geek)
- Refonte visuelle complete direction Tesla — dark theme #0a0a0a, Inter font, tokens CSS
- Dual theme dark/light via CSS variables et data-theme
- Custom design system vanilla JS + CSS variables — 28 composants + 2 comportements
- 7 surfaces UX : Dashboard unifie, App mobile, SmartPad Avatar, SmartPad Kiosk, Telegram, Admin dashboard, Desktop widget
- SmartPad Avatar : page separee avatar.html, sprite engine, 3 registres de templates (mignon/pro/custom)
- Carousel infini dual-axis pour SmartPad (3 panels : Avatar, Dashboard Systeme, Mes Agents)
- Composants onboarding : WiFiSetup, QRDisplay, ProgressStepper, ProfileSelector
- Assistants (terme user pour "agents") : nom + description naturelle, systeme de slots (5 Particulier, 15 Pro)
- Planification de taches en langage naturel ("Fais ca tous les jours a 8h")
- Store double : Agent Store + Module Store
- Affiliation e-commerce : ProductCard, ProductGrid, ProductCompare, DualProductSearch, AffiliateLink
- Guided first prompt adapte au profil au onboarding
- Jauge d'utilisation douce "ce mois" (pas de compteur tokens anxiogene)
- Throttle progressif (ralentissement, jamais de coupure brutale)
- WCAG 2.1 AA sur dashboard et mobile, basique sur SmartPad
- Accessibilite : focus visible, aria-live debounce, prefers-reduced-motion, lang dynamique par bulle
- Backup USB 32Go avec sync automatique + script clawbot-restore
- Conformite RGPD : politique de confidentialite a l'onboarding, disclaimer affiliation, script factory-reset
- Mode Geek optionnel dans settings (deverrouille model bar, tool trace detaille, logs)
- Bouton "Gaucher" pour inverser le layout mobile
- Sidebar repliable en icon rail 50px avec animation cubic-bezier

### FR Coverage Map

FR1: Epic 2 — Chat IA Unifie (envoi message + reponse LLM)
FR2: Epic 2 — Chat IA Unifie (thinking temps reel)
FR3: Epic 2 — Chat IA Unifie (historique conversations)
FR4: Epic 2 — Chat IA Unifie (compaction contexte auto)
FR5: Epic 2 — Chat IA Unifie (outils systeme, MCP, SSH, web)
FR6: Epic 2 — Chat IA Unifie (tool trace dans le flux)
FR7: Epic 3 — Assistants Specialises (creer/configurer agents)
FR8: Epic 3 — Assistants Specialises (selection modele LLM)
FR9: Epic 3 — Assistants Specialises (basculer entre agents)
FR10: Epic 3 — Assistants Specialises (routing par plan)
FR11: Epic 1 — Onboarding Turnkey (wizard WiFi)
FR12: Epic 1 — Onboarding Turnkey (QR code scan)
FR13: Epic 1 — Onboarding Turnkey (association device/compte)
FR14: Epic 1 — Onboarding Turnkey (choix mode Geek/Pro/Particulier)
FR15: Epic 1 — Onboarding Turnkey (auto-enregistrement MAC)
FR16: Epic 4 — Abonnement & Tokens (inscription plan)
FR17: Epic 4 — Abonnement & Tokens (suivi tokens temps reel)
FR18: Epic 4 — Abonnement & Tokens (rate limiting quota)
FR19: Epic 4 — Abonnement & Tokens (upgrade plan)
FR20: Epic 4 — Abonnement & Tokens (credit abo hardware)
FR21: Epic 4 — Abonnement & Tokens (multi-boitiers)
FR22: Epic 6 — Fichiers & Sauvegarde (naviguer/lire/modifier fichiers)
FR23: Epic 6 — Fichiers & Sauvegarde (stockage USB Pro)
FR24: Epic 6 — Fichiers & Sauvegarde (telecharger fichiers)
FR25: Epic 6 — Fichiers & Sauvegarde (generer documents)
FR26: Epic 6 — Fichiers & Sauvegarde (export/backup)
FR27: Epic 6 — Fichiers & Sauvegarde (restauration backup)
FR28: Epic 5 — Connectivite & Resilience (WebSocket persistant)
FR29: Epic 5 — Connectivite & Resilience (reconnexion auto)
FR30: Epic 5 — Connectivite & Resilience (sessions paralleles)
FR31: Epic 5 — Connectivite & Resilience (acces distant cloud)
FR32: Epic 5 — Connectivite & Resilience (mode degrade local)
FR33: Epic 5 — Connectivite & Resilience (persistence sessions)
FR34: Epic 5 — Connectivite & Resilience (affichage etat connexion)
FR35: Epic 8 — Notifications, Stats & Administration (notifications evenements)
FR36: Epic 8 — Notifications, Stats & Administration (stats usage)
FR37: Epic 8 — Notifications, Stats & Administration (verifier MAJ)
FR38: Epic 8 — Notifications, Stats & Administration (OTA par composant)
FR39: Epic 8 — Notifications, Stats & Administration (MAJ a distance)
FR40: Epic 8 — Notifications, Stats & Administration (logs systeme)
FR41: Epic 8 — Notifications, Stats & Administration (monitoring CPU/RAM)
FR42: Epic 8 — Notifications, Stats & Administration (redemarrer services)
FR43: Epic 9 — Systeme de Modules (chargement dynamique manifest)
FR44: Epic 9 — Systeme de Modules (outils REST)
FR45: Epic 9 — Systeme de Modules (installer/desinstaller)
FR46: Epic 9 — Systeme de Modules (panels dynamiques)
FR47: Epic 11 — Marketplace & API Tiers (SDK module tiers)
FR48: Epic 7 — Credential Vault (stocker credentials chiffre)
FR49: Epic 7 — Credential Vault (IA accede avec autorisation)
FR50: Epic 7 — Credential Vault (zero transit cloud)
FR51: Epic 11 — Marketplace & API Tiers (API REST externe)
FR52: Epic 11 — Marketplace & API Tiers (webhooks)
FR53: Epic 12 — Famille & Mode Safe (mode Safe restrictions)
FR54: Epic 12 — Famille & Mode Safe (sessions separees multi-user)
FR55: Epic 13 — Voice Mobile (STT Whisper)
FR56: Epic 12 — Famille & Mode Safe (dashboard mobile responsive)
FR57: Epic 10 — SmartPad Avatar (avatar anime etats)
FR58: Epic 14 — Desktop Agent & Inter-Box (agent desktop WebSocket)
FR59: Epic 14 — Desktop Agent & Inter-Box (inter-box WebSocket)
FR60: Epic 14 — Desktop Agent & Inter-Box (roles Master/Esclave/Mixte)
FR61: Epic 14 — Desktop Agent & Inter-Box (orchestration taches distribuees)

## Epic List

### Epic 1 : Onboarding Turnkey — "Brancher, scanner, c'est pret"
L'utilisateur recoit son boitier, le branche, scanne le QR code, cree son compte et obtient sa premiere reponse utile en <10 min. Inclut le wizard WiFi sur SmartPad, la page openjarvis.io/setup, la segmentation profil (Pro/Famille/Expert), et l'auto-enregistrement MAC sur le cloud.
**FRs couverts :** FR11, FR12, FR13, FR14, FR15

### Epic 2 : Chat IA Unifie — "Tu parles, ca fait"
L'utilisateur converse avec l'IA dans une zone de texte unique, voit le travail en cours (thinking, tool trace simplifie), et obtient des resultats concrets. Commence par la Story "Design System Foundation" (tokens CSS, composants de base, dual theme) comme socle pour toutes les surfaces. Inclut la refonte visuelle Tesla du dashboard, la fusion des 3 modes chat en un seul, le streaming token par token, et l'historique avec persistence.
**FRs couverts :** FR1, FR2, FR3, FR4, FR5, FR6

### Epic 3 : Assistants Specialises — "Ton equipe d'IA"
L'utilisateur cree des assistants avec un nom et une description en langage naturel, bascule entre eux, et le systeme route invisiblement vers le bon modele LLM selon le plan. Systeme de slots (5 Particulier, 15 Pro). Le terme "agents" n'apparait jamais cote utilisateur — uniquement "assistants".
**FRs couverts :** FR7, FR8, FR9, FR10

### Epic 4 : Abonnement & Tokens — "Paye pour la puissance"
L'utilisateur s'inscrit a un plan (Free/Particulier/Pro), voit sa consommation avec une jauge douce (pas de compteur tokens anxiogene), peut upgrader, et beneficie du credit hardware. Throttle progressif (ralentissement, jamais de coupure). Inclut la migration SQLite vers PostgreSQL comme prerequis scaling et rate limiting.
**FRs couverts :** FR16, FR17, FR18, FR19, FR20, FR21

### Epic 5 : Connectivite Cloud & Resilience — "Toujours connecte"
Le boitier maintient une connexion WebSocket stable avec le cloud, gere les pannes transparemment (reconnexion auto <30s, mode degrade local), et l'utilisateur accede de partout via le tunnel. Sessions paralleles (4+). Contexte brownfield : tunnel et reconnexion deja implementes, cet Epic polit et complete.
**FRs couverts :** FR28, FR29, FR30, FR31, FR32, FR33, FR34

### Epic 6 : Fichiers & Sauvegarde — "Tes donnees chez toi"
L'utilisateur navigue ses fichiers locaux, utilise le stockage USB (Pro), telecharge/genere des documents (devis, rapports), et peut sauvegarder/restaurer ses donnees. Inclut le backup USB 32Go avec sync automatique et le script clawbot-restore.
**FRs couverts :** FR22, FR23, FR24, FR25, FR26, FR27

### Epic 7 : Credential Vault — "Tes acces securises"
L'utilisateur stocke ses identifiants dans un coffre-fort chiffre AES-256 local. L'IA utilise les acces via reference vault:// sans jamais voir les vrais mots de passe. Panel "Mes acces" dans le dashboard avec cadenas et confirmation avant utilisation. Zero transit cloud.
**FRs couverts :** FR48, FR49, FR50

### Epic 8 : Notifications, Stats & Administration — "Controle total"
L'utilisateur recoit des notifications (tache terminee, quota atteint, MAJ dispo) et consulte ses stats d'usage. L'admin surveille CPU/RAM, consulte les logs, declenche les MAJ OTA par composant, et redemarre les services depuis le dashboard. Panel Monitor en mode Geek.
**FRs couverts :** FR35, FR36, FR37, FR38, FR39, FR40, FR41, FR42

### Epic 9 : Systeme de Modules — "L'ecosysteme s'agrandit"
Le systeme charge dynamiquement des modules via manifest JSON. Les modules exposent des outils accessibles par l'IA via REST standard. L'utilisateur installe/desinstalle depuis le dashboard. Les panels apparaissent automatiquement. DOMPurify pour sanitize HTML des panels.
**FRs couverts :** FR43, FR44, FR45, FR46

### Epic 10 : SmartPad Avatar — "Le visage de ton IA"
Le SmartPad affiche un compagnon anime (sprites 30fps via requestAnimationFrame) qui reagit a l'activite : idle, travaille, content, nuit. Page separee avatar.html, ultra-legere, toujours dark theme. Carousel infini 3 panels (Avatar, Dashboard Systeme, Mes Agents). 3 registres de templates (mignon/pro/custom).
**FRs couverts :** FR57

### Epic 11 : Marketplace & API Tiers (Growth)
Les developpeurs creent des modules avec le SDK et le template manifest, les soumettent au store. Agent Store + Module Store avec browse par categories et installation en un clic. L'API REST et les webhooks permettent des integrations externes.
**FRs couverts :** FR47, FR51, FR52

### Epic 12 : Famille & Mode Safe (Growth)
Mode Safe restreint les commandes systeme et l'acces aux fichiers pour les enfants. Plusieurs membres d'un foyer utilisent le boitier avec des sessions separees. Dashboard mobile responsive. Protection donnees mineurs (chat 100% local).
**FRs couverts :** FR53, FR54, FR56

### Epic 13 : Voice Mobile (Growth)
L'utilisateur dicte ses demandes via STT (Open Whisper) sur l'app mobile dediee. App native avec base locale synchronisee, mode offline, chat integre.
**FRs couverts :** FR55

### Epic 14 : Desktop Agent & Inter-Box (Vision)
Le boitier pilote l'ordinateur de l'utilisateur via un agent desktop leger en WebSocket (fenetre flottante "Jarvis"). Plusieurs boitiers s'interconnectent en reseau avec roles Master/Esclave/Mixte pour deleguer et orchestrer des taches.
**FRs couverts :** FR58, FR59, FR60, FR61

## Epic 1 : Onboarding Turnkey — "Brancher, scanner, c'est pret"

L'utilisateur recoit son boitier, le branche, et en <10 min il a un compte, un essai gratuit, et sa premiere reponse utile. Pas de paiement au setup. Premiere dose gratuite — l'effet drogue fait le reste.

### Story 1.1 : Wizard WiFi sur SmartPad

As a **nouvel utilisateur**,
I want **connecter mon boitier au WiFi au premier demarrage**,
So that **le boitier puisse acceder au cloud et afficher le QR code**.

**Acceptance Criteria:**

**Given** le boitier est branche pour la premiere fois
**When** le firstboot demarre sur le SmartPad
**Then** la liste des reseaux WiFi disponibles s'affiche avec la force du signal
**And** l'utilisateur peut saisir le mot de passe et se connecter

**Given** la connexion WiFi echoue
**When** l'utilisateur voit le message d'erreur
**Then** il peut reessayer avec un autre mot de passe ou choisir un autre reseau
**And** un fallback Ethernet est propose si disponible

**Given** la connexion WiFi reussit
**When** le boitier obtient une IP
**Then** le SmartPad passe automatiquement a l'ecran QR code

### Story 1.2 : Affichage QR Code & page d'inscription

As a **nouvel utilisateur**,
I want **scanner un QR code avec mon telephone pour creer mon compte ou lier mon appareil**,
So that **je puisse commencer a utiliser ClawBot sans configuration manuelle**.

**Acceptance Criteria:**

**Given** le WiFi est connecte
**When** le SmartPad affiche le QR code
**Then** le QR encode l'URL openjarvis.io/setup?mac=XXX (MAC du boitier)
**And** l'URL est affichee en texte sous le QR (fallback si scan echoue)

**Given** l'utilisateur scanne le QR avec son telephone
**When** la page openjarvis.io/setup s'ouvre
**Then** le MAC du boitier est conserve cote serveur pendant la session d'inscription

**Given** l'utilisateur a deja un compte
**When** il se connecte sur la page
**Then** le systeme propose "Voulez-vous lier cet appareil a votre compte ?"
**And** un clic sur "Oui" associe le MAC au compte

**Given** l'utilisateur n'a pas de compte
**When** il remplit le formulaire (email + mot de passe)
**Then** le compte est cree et le systeme propose immediatement "Voulez-vous lier cet appareil ?"
**And** le MAC est associe automatiquement apres confirmation

### Story 1.3 : Auto-enregistrement device & association MAC

As a **systeme**,
I want **enregistrer automatiquement le boitier sur le cloud avec son MAC**,
So that **le device soit identifie et pret a etre lie a un compte utilisateur**.

**Acceptance Criteria:**

**Given** le boitier est connecte au WiFi
**When** il contacte le cloud pour la premiere fois
**Then** il s'enregistre avec son MAC (uppercase, sans colons)
**And** le cloud cree une entree Device en attente de liaison

**Given** un utilisateur confirme "Lier cet appareil" sur openjarvis.io/setup
**When** le cloud recoit la confirmation
**Then** le Device est associe au User (user_id renseigne)
**And** le SmartPad detecte la liaison et passe a l'ecran suivant

**Given** le boitier est deja lie a un compte
**When** un autre utilisateur tente de le lier
**Then** le systeme refuse avec un message clair

### Story 1.4 : Profilage rapide & activation essai gratuit

As a **nouvel utilisateur**,
I want **repondre a 3 questions simples sur mon usage et recevoir un essai gratuit genereux**,
So that **je puisse commencer immediatement sans payer ni choisir un plan**.

**Acceptance Criteria:**

**Given** le device est lie au compte
**When** la page de profilage s'affiche
**Then** 3 questions courtes sont posees : "Pourquoi ClawBot ?" (pro / famille / pro+perso / perso / maker)
**And** les reponses identifient le profil utilisateur (stocke en DB)

**Given** le profilage est termine
**When** l'utilisateur valide
**Then** un essai gratuit d'1 mois minimum est active avec acces complet
**And** le routing LLM intelligent optimise les couts (Haiku pour le simple, Sonnet/Opus si necessaire)
**And** le message affiche est : "Decouvrez votre essai gratuit d'1 mois. Amusez-vous."
**And** aucun paiement n'est demande

### Story 1.5 : Premier prompt guide — effet wow

As a **nouvel utilisateur**,
I want **recevoir une suggestion de premiere demande adaptee a mon profil**,
So that **j'obtienne un resultat spectaculaire qui me donne envie de continuer**.

**Acceptance Criteria:**

**Given** le dashboard s'ouvre pour la premiere fois apres l'essai gratuit
**When** la zone de chat est vide
**Then** 3 suggestions de prompts sont affichees, adaptees au profil :
- Pro : "Genere-moi un modele de devis pour..."
- Famille : "Planifie les repas de la semaine avec..."
- Maker : acces direct, pas de suggestion

**Given** l'utilisateur clique sur une suggestion ou tape sa propre demande
**When** la reponse arrive en streaming
**Then** le resultat est concret et spectaculaire (document, plan, action)
**And** le tool trace simplifie montre l'IA au travail
**And** le temps total est <30s pour la premiere reponse

## Epic 2 : Chat IA Unifie — "Tu parles, ca fait"

L'utilisateur converse dans une zone de texte unique, voit l'IA travailler en temps reel, et obtient des resultats concrets. Commence par la fondation du design system, puis refond le dashboard direction Tesla, et unifie les 3 modes chat en un seul invisible. Contexte brownfield : le chat, le streaming et les outils fonctionnent deja — cet Epic refond le visuel et unifie l'experience.

### Story 2.1 : Design System Foundation

As a **developpeur**,
I want **un design system avec tokens CSS, composants de base et dual theme**,
So that **toutes les surfaces partagent une identite visuelle coherente et premium**.

**Acceptance Criteria:**

**Given** le fichier tokens.css est cree
**When** un composant l'importe
**Then** il a acces a la palette Tesla dark (#0a0a0a, #1a1a1a, #00ffe0), la palette light (#f5f5f5, #008b7a), la typo Inter/JetBrains Mono, les espacements et les animations

**Given** le composant Spinner est implemente
**When** une action async est en cours
**Then** un cercle cyan anime s'affiche

**Given** le composant Panel est implemente
**When** un panel est rendu dans le dashboard
**Then** il a un titre, un contenu, et peut etre collapse

**Given** le composant Notification (toast) est implemente
**When** un evenement se produit
**Then** un toast apparait (succes/erreur/warning/info), stackable, auto-dismiss

**Given** html[data-theme] est bascule
**When** l'utilisateur change de theme
**Then** tous les composants s'adaptent (dark ou light) via les tokens CSS
**And** le light theme utilise --accent-light (#008b7a) au lieu de --accent (#00ffe0)

### Story 2.2 : Refonte visuelle du dashboard

As a **utilisateur**,
I want **un dashboard premium, moderne et lisible**,
So that **l'experience soit agreable et inspire confiance**.

**Acceptance Criteria:**

**Given** le dashboard existant est refonde
**When** l'utilisateur ouvre le dashboard
**Then** le layout affiche une sidebar repliable (250px ouverte, 50px icon rail) + zone chat centrale
**And** la direction visuelle est Tesla : fond #0a0a0a, cards #1a1a1a, radius 12px, Inter font

**Given** la sidebar est en mode icon rail
**When** l'utilisateur survole un icone
**Then** un tooltip affiche le label
**And** les badges deviennent des micro-pastilles cyan (14px)
**And** l'animation de collapse est cubic-bezier fluide 250ms

**Given** le dashboard est charge
**When** le temps de chargement est mesure en LAN
**Then** il est <3s (NFR3)

**Given** prefers-reduced-motion est actif
**When** le dashboard s'affiche
**Then** toutes les animations decoratives sont desactivees

### Story 2.3 : Zone de chat unifiee & streaming

As a **utilisateur**,
I want **une seule zone de texte ou je tape ma demande et l'IA repond en streaming**,
So that **je n'ai aucun choix technique a faire — je parle, ca fait**.

**Acceptance Criteria:**

**Given** l'utilisateur ouvre le dashboard
**When** la zone de chat s'affiche
**Then** il y a UNE seule zone de texte avec placeholder "Just ask it..."
**And** les 3 anciens modes (Core/Agent/Core-Agent) sont fusionnes invisiblement
**And** le routing se fait automatiquement cote backend

**Given** l'utilisateur envoie un message
**When** la reponse arrive du LLM
**Then** le texte s'affiche token par token en streaming temps reel
**And** le markdown est rendu (marked.js) avec coloration syntaxique (highlight.js)

**Given** l'utilisateur appuie sur Enter
**When** le message est envoie
**Then** le premier token s'affiche en <5s via le tunnel cloud (NFR1)

**Given** l'utilisateur navigue avec ArrowUp/Down dans la zone de saisie
**When** il a un historique de prompts
**Then** les prompts precedents sont rappeles (prompt history)

### Story 2.4 : Thinking indicator & tool trace simplifie

As a **utilisateur**,
I want **voir que l'IA travaille avec des animations et des messages clairs**,
So that **je sache que ma demande est en cours sans voir de jargon technique**.

**Acceptance Criteria:**

**Given** l'IA reflechit avant de repondre
**When** le backend envoie un evenement thinking
**Then** une animation etoile + textes rotatifs (2s) s'affiche ("Reflexion en cours...", "Analyse de la demande...", etc.)

**Given** l'IA appelle un outil
**When** un tool_call est recu
**Then** le tool trace simplifie affiche des dots animes + texte descriptif :
- "En train de chercher..." (web_search)
- "En train de coder..." (python/bash)
- "En train de lire..." (read_file)
- "En train de verifier..." (generique)

**Given** un outil retourne un resultat
**When** le tool_result est recu
**Then** le dot passe au vert (succes) ou rouge (erreur)
**And** le resultat est expandable en cliquant dessus

**Given** le mode Geek est active dans les settings
**When** un tool_call est recu
**Then** le nom technique de l'outil, les arguments et le resultat complet sont affiches

**Given** l'IA itere sur plusieurs outils
**When** la tache n'est pas terminee
**Then** l'IA continue jusqu'a ce que le resultat soit satisfaisant ou qu'elle detecte une impasse
**And** il n'y a pas de limite arbitraire visible pour l'utilisateur

### Story 2.5 : Historique conversations & persistence

As a **utilisateur**,
I want **retrouver mes conversations precedentes et reprendre ou j'en etais**,
So that **rien ne soit perdu entre les sessions**.

**Acceptance Criteria:**

**Given** l'utilisateur a des conversations precedentes
**When** il ouvre la sidebar
**Then** les conversations sont listees par date (Aujourd'hui, Hier, Cette semaine, Ce mois)

**Given** l'utilisateur cherche un message
**When** il tape dans la barre de recherche
**Then** la recherche full-text filtre les conversations en temps reel (debounce 300ms)

**Given** l'utilisateur ferme le dashboard et revient plus tard
**When** il rouvre le dashboard
**Then** sa derniere session est restauree exactement ou il l'avait laissee
**And** les sessions sont persistees cote serveur (pas localStorage)

**Given** le contexte depasse le seuil de compaction
**When** la compaction automatique se declenche
**Then** le contexte est reduit sans perdre les informations essentielles
**And** l'operation est invisible pour l'utilisateur

### Story 2.6 : Execution d'outils via l'IA

As a **utilisateur**,
I want **que l'IA execute des actions concretes (commandes, code, fichiers, recherche web, SSH)**,
So that **j'obtienne des resultats tangibles, pas juste du texte**.

**Acceptance Criteria:**

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
**Then** l'outil est appele via POST http://127.0.0.1:{port}/v1/{tool_id}/execute
**And** le resultat est integre dans le contexte LLM

**Given** une commande dangereuse est detectee (systemctl stop/restart/kill sur services proteges)
**When** l'IA tente de l'executer
**Then** la commande est bloquee avec un message explicatif

## Epic 3 : Assistants Specialises — "Ton equipe d'IA"

L'utilisateur cree des assistants avec un nom et une description naturelle. Le systeme genere le prompt technique. L'utilisateur bascule entre assistants, et le routing LLM est invisible. Systeme de slots comme levier d'upsell — les agents poussent vers le plan superieur.

### Story 3.1 : Creer un assistant avec nom et description naturelle

As a **utilisateur**,
I want **creer un assistant specialise en lui donnant un nom et une description en langage naturel**,
So that **j'aie un expert dedie a mes besoins sans ecrire de prompt technique**.

**Acceptance Criteria:**

**Given** l'utilisateur ouvre le panel "Mes assistants"
**When** il clique sur "Creer un assistant"
**Then** un formulaire s'affiche : nom (ex: "Alice"), description en langage naturel (ex: "Ma comptable, elle fait mes devis et ma TVA"), avatar optionnel

**Given** l'utilisateur valide la creation
**When** le systeme recoit la description
**Then** un system prompt technique est genere automatiquement a partir de la description naturelle
**And** l'assistant est disponible immediatement dans la liste

**Given** l'utilisateur veut modifier un assistant existant
**When** il ouvre le profil de l'assistant
**Then** il peut editer le nom, la description et l'avatar
**And** le system prompt est regenere si la description change

**Given** le terme "agent" n'apparait jamais cote utilisateur
**When** l'interface affiche les assistants
**Then** le mot utilise est toujours "assistant" (jamais "agent")

### Story 3.2 : Selection et switch entre assistants

As a **utilisateur**,
I want **basculer entre mes assistants dans une meme session**,
So that **je puisse utiliser le bon expert selon ma demande**.

**Acceptance Criteria:**

**Given** l'utilisateur a plusieurs assistants
**When** il ouvre le picker d'assistants (AgentPicker)
**Then** une grille de cartes s'affiche : nom, description, avatar, statut (actif/inactif)

**Given** l'utilisateur selectionne un assistant
**When** il commence a chatter
**Then** le system prompt de l'assistant est injecte dans le contexte
**And** la conversation s'adapte a la personnalite de l'assistant

**Given** l'utilisateur bascule vers un autre assistant en cours de session
**When** le switch se fait
**Then** le contexte de conversation est conserve
**And** le nouvel assistant reprend avec le meme historique

**Given** aucun assistant n'est selectionne
**When** l'utilisateur tape directement dans le chat
**Then** le systeme utilise l'assistant par defaut (generaliste)

### Story 3.3 : Routing LLM intelligent par plan

As a **systeme**,
I want **router invisiblement les requetes vers le bon modele LLM selon le plan et la complexite**,
So that **l'utilisateur obtienne la meilleure reponse possible sans choisir un modele**.

**Acceptance Criteria:**

**Given** un utilisateur avec un plan Particulier ($7.99)
**When** il envoie un message simple
**Then** le systeme route vers un modele leger (Haiku) pour optimiser les couts

**Given** un utilisateur avec un plan Pro ($80+)
**When** il envoie un message
**Then** le systeme peut router vers le meilleur modele disponible (Opus)

**Given** la complexite d'une demande est evaluee
**When** le routing decide du modele
**Then** le choix est base sur : plafond du plan (model_ceiling) + complexite detectee
**And** l'utilisateur ne voit JAMAIS quel modele est utilise (sauf mode Geek)

**Given** le mode Geek est active
**When** un message est envoye
**Then** le model bar technique s'affiche avec le modele utilise
**And** l'utilisateur peut forcer un modele specifique

### Story 3.4 : Systeme de slots & gestion des assistants

As a **utilisateur**,
I want **voir mes slots d'assistants et gerer mon quota**,
So that **je sache combien d'assistants je peux utiliser et comment en avoir plus**.

**Acceptance Criteria:**

**Given** l'utilisateur a un plan avec X slots (ex: 3 Particulier, 10 Particulier+, 15 Pro)
**When** il ouvre le panel "Mes assistants"
**Then** l'indicateur affiche "X/Y assistants utilises" (ex: "2/3 assistants")

**Given** l'utilisateur atteint sa limite de slots
**When** il tente de creer un nouvel assistant
**Then** le systeme propose : ajouter un slot (+$3/mois) ou upgrader vers le plan superieur
**And** le message est non-bloquant et non-anxiogene

**Given** l'utilisateur a un plan Pro Business+ (30 slots)
**When** il cree des assistants
**Then** les slots sont quasi-illimites — au-dessus de Pro, les agents sont cadeau

**Given** l'utilisateur veut supprimer un assistant
**When** il confirme la suppression
**Then** le slot est libere immediatement
**And** l'historique des conversations avec cet assistant est conserve
