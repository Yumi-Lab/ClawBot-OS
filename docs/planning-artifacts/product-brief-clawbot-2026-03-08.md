---
stepsCompleted: [1, 2, 3, 4, 5]
inputDocuments: ['docs/brainstorming/brainstorming-session-2026-03-08-10h00.md']
date: 2026-03-08
author: Nicolas
---

# Product Brief: ClawBot

## Executive Summary

ClawBot est un boitier physique d'IA agentique cle en main qui democratise l'acces a l'intelligence artificielle pour les professionnels et les particuliers. Branche, scanne le QR code, c'est pret. Le boitier orchestre des agents IA specialises via le cloud tout en gardant les donnees utilisateur en local. ClawBot applique a l'IA agentique la meme logique qui a fait le succes des produits tech grand public : transformer une technologie complexe en un objet simple que tout le monde peut utiliser — le Nest de l'IA domestique.

---

## Core Vision

### Problem Statement

L'IA agentique en 2026 est reservee aux developpeurs et aux entreprises qui ont les moyens d'embaucher des consultants. Open WebUI, Claude Code, LangChain — tous ces outils sont puissants mais inaccessibles au commun des mortels. Le professionnel qui veut automatiser sa comptabilite, sa gestion de projet ou sa maintenance IT doit soit recruter, soit renoncer. Le particulier qui veut un assistant IA veritablement utile doit accepter que ses donnees partent chez des tiers.

### Problem Impact

- **Professionnels (TPE/PME)** : surcout salarial pour des taches automatisables, perte de competitivite face aux entreprises qui maitrisent l'IA
- **Particuliers** : aucune solution d'IA agentique accessible sans competences techniques, sacrifice systematique de la vie privee pour acceder a l'IA
- **Marche global** : l'IA agentique reste un outil de niche au lieu de devenir un service universel

### Why Existing Solutions Fall Short

| Solution | Forces | Faiblesses |
|----------|--------|------------|
| ChatGPT / Claude web | Puissant, accessible | Pas agentique, donnees dans le cloud, pas d'outils systeme |
| Open WebUI | Puissant, auto-hebergeable | Necessite un dev/consultant, installation complexe, pas de hardware dedie |
| N8N / Make | Automation, workflows | Pas d'IA conversationnelle, pas de hardware, courbe d'apprentissage |
| Assistants vocaux (Alexa, Siri) | Cle en main | Pas agentique, donnees chez GAFAM, capacites limitees |

**Le gap** : aucune solution ne combine boitier physique cle en main + donnees locales souveraines + agents IA configurables + acces en 30 secondes via QR code.

### Proposed Solution

Un boitier hardware a cout marginal (Smart Pi One, H3, fabrique dans notre propre usine en Chine) pre-equipe d'un OS agentique (ClawBot-OS) qui :
- S'active en 30 secondes (QR code → compte → pret)
- Orchestre des agents IA specialises via API cloud (Claude, futur multi-LLM)
- Garde toutes les donnees en local sur le boitier (SD + USB extensible, possibilite RAID)
- Propose 3 modes adaptes (Safe pour tous, Geek pour les tech, Pro pour les entreprises)
- Evolue en continu via un marketplace de skills/modules crees par la communaute

### Key Differentiators

1. **Hardware propre** — usine en Chine, cout marginal, capacite de production de dizaines de milliers d'unites/mois avec 5 personnes
2. **Pattern prouve par le fondateur** — a deja transforme un ecosysteme open source complexe en produit hardware turnkey vendu a des milliers d'unites, avec la meme strategie
3. **Experience zero friction** — QR code, zero configuration, valeur immediate en <10 min. Deux SKUs adaptes (Home €80, Pro €200)
4. **Effet drogue** — Une fois que l'utilisateur a goute a l'IA agentique, il ne revient pas en arriere. Le produit se vend par l'experience et le bouche-a-oreille, pas par l'explication
5. **Cercle vertueux auto-referentiel** — ClawBot developpe ClawBot (armee de boitiers-agents comme equipe de dev)
6. **Timing parfait** — 2026, les LLM sont matures mais personne n'a fait le hardware agentique cle en main
7. **Triple revenue** — hardware (marge one-shot) + abonnement (recurring €8-300/mois) + marketplace (commission sur skills communautaires)

---

## Target Users

### Insight fondamental

La souverainete des donnees n'est PAS l'argument de vente principal. Les gens savent que leurs donnees sont deja partout. Ce qu'ils veulent c'est **se simplifier la vie** et **gagner du temps**. Le boitier physique materialise l'IA — il la rend tangible, rassurante, concrete. C'est un cheval de Troie : le produit reel c'est la plateforme, le boitier c'est l'experience.

### Le vrai defi : l'education du marche

Les Pros comprennent immediatement — "gain de temps = argent economise". On montre un devis genere en 10 secondes, c'est vendu.

Les Particuliers sont a des annees-lumiere de comprendre ce que l'IA agentique peut faire pour eux. Beaucoup n'ont meme plus d'ordinateur, juste un telephone. Ils connaissent ChatGPT mais ne savent pas que l'IA peut repondre a leurs emails, faire un recap de leur journee, organiser leur vie. C'est quand ils touchent au produit que ca devient une evidence — "putain, ca va changer ma vie". C'est comme une drogue : une fois qu'ils ont goute, ils ne reviennent pas en arriere.

**Consequence strategique :** Le produit doit se vendre par l'experience et le bouche-a-oreille, pas par l'explication technique. Les Pros sont la tete de pont — ils comprennent, payent, et deviennent les ambassadeurs qui declenchent l'adoption grand public.

### Strategie de lancement phasee

1. **Phase 1 — Beta GeekTech (0-3 mois)** : 50-100 boitiers chez les early adopters, validation technique, stabilisation
2. **Phase 2 — Lancement Pro (3-6 mois)** : Cible entrepreneurs/TPE/PME, ROI immediat demontrable, les Pros financent la croissance
3. **Phase 3 — Ouverture Particulier (6-12 mois)** : Quand les temoignages Pro existent, que les videos "regarde ce que mon boitier fait" circulent, et que le bouche-a-oreille est amorce

Le plan Particulier a €8/mois est un **produit d'appel a marge potentiellement negative** au debut. C'est viable uniquement si les Pros financent la croissance. Le pricing Particulier augmentera progressivement avec l'usage et la valeur percue.

### Primary Users

#### Persona 1 — Marc, entrepreneur independant (Pro)

- **Profil :** 42 ans, dirige une societe de services, 8 salaries, pas de DSI
- **Probleme :** Gere tout seul (compta, devis, planning, depannage IT), travaille 60h/semaine
- **Ce qu'il veut :** Puissance x10 — ce qui prenait des heures prend 10 minutes
- **Experience ClawBot :** Branche, scanne, en 10 min il a un assistant qui genere ses devis, classe ses factures, repond a ses mails. Il recupere 2h/jour.
- **Budget :** €200-600/mois sans hesiter (ROI immediat vs cout salarial)
- **Moment "aha" :** "Attendez, je faisais ca avant, ca me prenait l'apres-midi. La j'ai mis 10 minutes."
- **Segment :** Tous les entrepreneurs independants, patrons TPE/PME, managers, artisans, consultants

#### Persona 2 — Sophie, mere de famille (Particulier)

- **Profil :** 38 ans, 2 enfants, travaille a mi-temps
- **Probleme :** Jongle entre ecole, courses, devoirs, organisation familiale, budget
- **Ce qu'il veut :** Se simplifier la vie — un assistant familial intelligent
- **Experience ClawBot :** Un boitier dans la cuisine, branche sur l'ecran HDMI ou via l'app mobile. Tableau familial intelligent — planning repas, aide devoirs, budget, rappels, listes. Toute la famille est connectee au meme boitier.
- **Budget :** €8/mois (modele Netflix familial)
- **Moment "aha" :** Les enfants demandent de l'aide pour leurs devoirs au boitier au lieu de la deranger quand elle travaille.
- **Segment :** Familles, un boitier par foyer. C'est la cible la plus dure mais le plus gros volume.

### Secondary Users (Beta only)

#### GeekTech / Early adopters

- Devs, makers, communaute Yumi Lab existante
- Pas une cible commerciale — le carburant du lancement
- Ils testent, ils tweakent, ils creent des skills, ils evangelisent
- Transition naturelle : certains deviendront createurs de modules sur le marketplace

### User Journey

#### Journey Pro (Marc)

1. **Decouverte :** Pub LinkedIn/Instagram "Votre assistant IA pour €200/mois au lieu d'un salarie"
2. **Achat :** Commande le ClawBot Pro en ligne (€200, credit abo equivalent offert)
3. **Onboarding :** Recoit le boitier avec ecran + stockage, le branche, scanne le QR code, cree son compte, mode Pro
4. **Premiere valeur :** En 10 min, il demande a ClawBot de lui generer un modele de devis. Ca marche. Il est accro.
5. **Usage quotidien :** ClawBot gere ses mails, ses factures, son planning. Il installe des skills metier (compta, gestion projet).
6. **Scale :** Il augmente son abo pour plus de tokens, il recommande a d'autres entrepreneurs.

#### Journey Famille (Sophie)

1. **Decouverte :** Bouche-a-oreille, pub Instagram/TikTok "Un cerveau IA pour toute la famille, €8/mois"
2. **Achat :** ClawBot Home a €80, offert pour Noel ou achat impulsif (1er mois offert)
3. **Onboarding :** Branche dans la cuisine, scanne le QR code, mode Safe active par defaut
4. **Premiere valeur :** Demande un planning de repas pour la semaine avec ce qu'il y a dans le frigo
5. **Usage quotidien :** Les enfants utilisent pour les devoirs, elle pour l'organisation, le mari pour bricoler
6. **Scale :** Connexion a un ecran HDMI (tableau familial), ajout de stockage USB

### Hardware : deux SKUs, meme carte

Meme carte (Smart Pi One) a l'interieur, packaging et accessoires differents pour correspondre a la perception de valeur de chaque cible.

| | ClawBot Home | ClawBot Pro |
|---|---|---|
| **Hardware** | Smart Pi One, boitier acrylique, SD | Smart Pi One + SmartPad (ecran tactile), dock, 2x 1TB USB |
| **Prix** | ~€80 | ~€200 |
| **Offre lancement** | 1er mois abo offert (€8) | Credit abo equivalent au prix du boitier (€200) |
| **Cible** | Familles (Phase 3) | Entrepreneurs/TPE/PME (Phase 2) |
| **Perception** | "Assistant familial abordable" | "Outil pro serieux et complet" |

**Logique box telecom :** Le credit d'abo offert dit implicitement "le hardware, on vous l'offre — payez juste le service".

### Hardware Roadmap

- **V1 (actuelle) :** Smart Pi One (H3, 1GB RAM), beta/early adopter — suffisant pour un aggregateur API
- **V2 (prioritaire) :** ARM 64-bit, plus de RAM, format pocket router 4G — necessaire avant le scale Particulier
- **Module desktop :** Logiciel PC permettant au boitier de piloter l'ordinateur
- **A terme :** Option SaaS-only pour ceux qui ne veulent pas de hardware

---

## Success Metrics

### User Success

| Persona | Metrique de succes | Indicateur |
|---------|-------------------|------------|
| **Marc (Pro)** | Gain de temps mesurable | "Je gagne X heures/semaine" |
| **Marc (Pro)** | Usage quotidien | Retention daily >80% |
| **Marc (Pro)** | Upsell naturel | Augmentation abo = preuve de valeur |
| **Sophie (Famille)** | Adoption multi-users | Plusieurs membres du foyer actifs |
| **Sophie (Famille)** | Retention Netflix | Renouvellement mensuel sans friction |

### Business Objectives

| Horizon | Phase | Objectif | KPI |
|---------|-------|----------|-----|
| **0-3 mois** | Beta GeekTech | Valider que ca marche | 50-100 boitiers, retention >80%, bugs critiques resolus |
| **3-6 mois** | Lancement Pro | Premiers clients payants | 10+ ClawBot Pro vendus, MRR >€2k, temoignages video |
| **6-12 mois** | Ouverture Particulier | Croissance organique | 500+ boitiers (Pro+Home), MRR >€20k, bouche-a-oreille mesurable |
| **12+ mois** | Scale | Machine qui tourne | 1000+ boitiers, marketplace active, marge Particulier positive |

### Key Performance Indicators

| KPI | Pourquoi | Cible |
|-----|----------|-------|
| **Churn mensuel** | Si les gens restent, le produit marche | <5% Pro, <10% Particulier |
| **Revenue par user Pro** | Monte = plus de valeur percue | €200 → €400+ en 6 mois |
| **Cout API moyen par user** | La marge reelle | A definir apres beta |
| **Time-to-first-value** | Entre scan QR et "wow" | <10 minutes |
| **NPS** | Recommandation organique | >50 |

---

## Principes UX

1. **Zero friction** — Le produit ne demande jamais rien qu'il peut deviner. Pas de configuration, pas de choix technique, pas de jargon.
2. **Donnees locales par defaut** — Fichiers, credentials, historiques restent sur le boitier. Ce n'est pas un argument marketing, c'est juste le fonctionnement normal. On n'en parle pas, on le fait. Quand l'utilisateur connecte son Gmail ou met un mot de passe, ca reste dans le boitier chez lui — point.
3. **Show, don't tell** — Pas d'explication de ce que l'IA peut faire. Le produit le montre immediatement. Premiere interaction = premiere valeur en <10 min.
4. **Le boitier est invisible** — L'utilisateur pense a ce que l'IA fait pour lui, pas au hardware. Le boitier est un moyen, pas une fin.

---

## MVP Scope

### Principe architectural

ClawbotCore est un **aggregateur pur** (pattern Moonraker) : il ne fait que router les requetes, exposer les endpoints et agreger les modules. Toute fonctionnalite avancee (agents, scheduling, voice, etc.) vit dans des **modules independants** qui se branchent via le systeme existant (manifest.json, port, service, tool_definitions). Si un module n'est pas installe, il n'apparait pas dans l'interface — zero pollution.

### Core Features (MVP)

1. **ClawbotCore stable** — Aggregateur pur, routing LLM, API REST + WebSocket, gestion sessions, outils systeme (bash, python, read_file, write_file, web_search, ssh)
2. **Module agent-manager** (nouveau) — Gestion des agents specialises, creation/edition de personas, selection de modele par agent, historique par agent. Se branche sur ClawbotCore via manifest.json comme tout module.
3. **Dashboard unifie** — SPA modulaire : les panels s'affichent uniquement si le module correspondant est installe. Chat, fichiers, moniteur systeme, config, setup en base. Panels agents/workspace uniquement si agent-manager present.
4. **QR code onboarding** — Scan → creation compte → choix mode (Safe/Geek/Pro) → pret en <10 min. Wizard de premiere connexion integre.
5. **Tunnel cloud** — WebSocket device↔cloud, sessions paralleles, failover. L'utilisateur accede a son boitier depuis n'importe ou.
6. **Plans d'abonnement** — Free (10k tokens/jour, Haiku), Particulier (200k/jour, Sonnet, €8/mois, lancement Phase 3), Pro (2M/jour, Opus, €200+/mois, lancement Phase 2). Credit abo offert a l'achat du boitier. Pricing Particulier progressif selon usage.
7. **OS image buildable** — CI/CD 4 variantes (Smart Pi One + SmartPad, Bookworm + Trixie), image flashable sur SD.

### Out of Scope pour le MVP

| Feature | Raison du report | Horizon |
|---------|-----------------|---------|
| App mobile native | Le dashboard web responsive suffit pour valider | V2 (6 mois) |
| Marketplace de modules | Necessite base utilisateurs et createurs actifs | V2 (6-12 mois) |
| Module task-scheduler | Scheduling cron/periodique, pas essentiel au MVP | Post-MVP (3 mois) |
| Multi-LLM (OpenAI, Mistral) | Claude suffit pour valider, ajout iteratif apres | Post-MVP |
| Module voice | TTS/STT, necessite hardware micro/speaker | V2+ |
| RAID / stockage avance | USB basique suffit pour beta | V2+ |
| Module desktop (pilotage PC) | Complexe, necessite agent desktop | V3 (12 mois) |
| Option SaaS-only | Le hardware est le differenciateur MVP | V3+ |

### MVP Success Gate

| Critere | Seuil | Methode de mesure |
|---------|-------|-------------------|
| Beta testers actifs | 50+ boitiers | Comptage devices provisionnes avec usage >1 session/semaine |
| Time-to-first-value | <10 min | Temps entre scan QR et premiere reponse utile du chat |
| Stabilite | Zero crash critique sur 7 jours consecutifs | Monitoring logs + uptime service |
| Retention beta | >80% a 30 jours | Users actifs semaine 4 / users actifs semaine 1 |
| Module agent-manager fonctionnel | Creer et utiliser un agent specialise | Test utilisateur : creer un agent "comptable" et obtenir un devis |

**Decision point :** Si ces 5 criteres sont valides apres la beta de 3 mois → lancement commercial Pro (Phase 2). Ouverture Particulier (Phase 3) uniquement quand les Pros financent la croissance et que le bouche-a-oreille est amorce.

### Future Vision

**Court terme (3-6 mois post-MVP) :**
- Module task-scheduler — planification de taches recurrentes (backup quotidien, rapport hebdo, veille)
- Multi-LLM — ajout OpenAI, Mistral, modeles locaux pour les plans qui le justifient
- App mobile — PWA ou app native pour acces simplifie

**Moyen terme (6-12 mois) :**
- Marketplace de modules — la communaute cree et vend des modules specialises (compta, immobilier, sante, education)
- Module voice — interaction vocale avec le boitier (micro/speaker, TTS/STT)
- Hardware V2 — format pocket router 4G, plus compact, ARM 64-bit

**Long terme (12+ mois) :**
- Module desktop — le boitier pilote l'ordinateur de l'utilisateur (automatisation desktop)
- Option SaaS-only — pour ceux qui ne veulent pas de hardware
- Ecosysteme complet — chaque boitier est un noeud d'un reseau d'agents collaboratifs
- ClawBot developpe ClawBot — armee de boitiers comme equipe de dev auto-referentielle
