---
date: 2026-03-16
author: Nicolas
status: draft
project: OpenJarvis — Agents Personnalisés
parent: docs/planning-artifacts/product-brief-clawbot-2026-03-08.md
---

# Product Brief — Agents Personnalisés OpenJarvis

## Contexte & Problème

Le PRD principal définit le "module agent-manager" comme feature MVP (FR7-FR10). L'implémentation actuelle dispose de 4 agents par défaut (Julien/Python, Marc/Sysadmin, Sophie/Researcher, Thierry/FileManager) qui cohabitent avec les futurs agents utilisateur dans le même bucket, avec le même quota.

**Le problème fondamental :** ces deux catégories n'ont rien à voir l'une avec l'autre.

| | Agents système | Agents utilisateur |
|---|---|---|
| **Rôle** | Backbone technique du Pi (bash, python, fichiers, web) | Expert métier dédié à l'utilisateur |
| **Exemples** | Dev Python, Sysadmin Linux, Chercheur web | Expert-comptable, Chef de projet, Coach sportif |
| **Qui les gère** | Yumi Lab (livrés avec l'OS) | L'utilisateur (créés via wizard) |
| **Quota** | Illimité, toujours présents | Comptés dans `agents_included` du plan |
| **Supprimable** | Non | Oui |
| **Modifiable** | Oui (system_prompt, skills) | Oui (tout) |
| **Mémoire** | Non (stateless, technique) | Oui (mémoire longue durée) |

Si Marc crée son "expert comptable" sur un plan Starter (3 agents), les 4 agents système occupent déjà tout — il n'a plus de slot. Le produit est inutilisable pour son cas d'usage principal.

---

## Vision

Un utilisateur non-technicien peut, en quelques minutes via une conversation naturelle, créer un assistant IA qui :
- A une **identité et un rôle définis** (expert dans son domaine)
- **Se souvient** de toutes ses interactions passées avec lui
- **Connaît ses documents** (factures, dossiers, références)
- **Agit** avec les outils appropriés à son métier
- **Grandit** avec lui dans le temps

L'utilisateur ne sait pas ce qu'est un system_prompt. Il sait ce qu'il veut : un assistant qui le connaît, qui ne répète pas les mêmes questions, et qui devient meilleur avec le temps.

---

## Personas Cibles

### Marc — Entrepreneur (Pro)
Veut un assistant qui gère ses devis, classe ses factures, connaît ses clients. Il crée "Sophie la Comptable" — elle connaît ses tarifs, ses clients habituels, son logiciel de facturation. Quand il dit "fais-moi un devis pour Dupont", Sophie sait ce que Dupont a commandé la dernière fois.

### Sophie — Mère de famille (Particulier)
Veut un assistant familial qui connaît les enfants, leurs allergies, leurs emplois du temps. Elle crée "Max le Coordinateur Familial". Il connaît les prénoms, les horaires, les habitudes.

### GeekTech — Développeur (Beta)
Crée des agents techniques avancés avec accès SSH, git, deploy. Il écrit ses propres prompts en mode expert, maîtrise les skills.

---

## Features du Sous-Projet

### 1. Architecture deux niveaux — Système vs Utilisateur

**Backend (orchestrator.py + main.py)**
- Nouveau champ `"type": "system" | "user"` dans le schema agent JSON
- Agents système : non-supprimables via API, modifiables (system_prompt, skills), non-comptés dans le quota
- Agents utilisateur : comptés dans `agents_included`, CRUD complet
- Migration auto des agents existants sur le Pi : ids connus → `system`, reste → `user`
- `agents_included` poussé dans le payload de provisioning cloud → Pi, stocké localement dans `/etc/clawbot/plan.json`
- Quota check au POST /core/agents : si `type == "user"` et count(user agents) >= agents_included → refus

**UI (index.html — panel Agents)**
- Section "Agents système" : liste readonly avec 🔒, bouton Edit mais pas Supprimer
- Section "Mes agents" : compteur `X / N agents utilisés`, bouton "+ Créer un agent"

---

### 2. Wizard de création conversationnel

**Concept :** Un méta-agent (le "Créateur") engage une conversation avec l'utilisateur pour définir son agent. L'utilisateur n'écrit pas de prompt — il répond à des questions naturelles.

**Flow :**
```
Utilisateur : "Je veux créer un assistant comptable"
Créateur : "Super ! Comment tu veux l'appeler ?"
Utilisateur : "Sophie"
Créateur : "Qu'est-ce que Sophie doit savoir faire en priorité ?"
Utilisateur : "Générer des devis, classer mes factures, me rappeler les échéances TVA"
Créateur : "Elle a accès à quels outils ? Je lui donne accès aux fichiers de ton boîtier ?"
...
→ Génère automatiquement : id, name, avatar, system_prompt, skills, keywords
→ Propose un résumé pour validation
→ Crée l'agent en 1 clic
```

**Mode expert (optionnel) :** accessible depuis le formulaire de création, permet d'éditer le system_prompt généré manuellement.

**Implémentation :**
- Endpoint `/core/agents/wizard` : session de chat dédiée avec un méta-prompt de création
- Le méta-prompt guide la collecte des infos et génère le JSON de l'agent
- Résultat soumis à `/core/agents/{id}` POST pour sauvegarde

---

### 3. Mémoire persistante par agent

**Option C retenue : mémoire conversationnelle + base documentaire**

#### 3a. Mémoire conversationnelle (fil continu)

L'agent conserve un résumé structuré et évolutif de tout ce qu'il apprend sur l'utilisateur et ses interactions.

**Stockage :** fichier JSON par agent `/home/pi/.clawbot/agents/{id}.memory.json`
```json
{
  "agent_id": "sophie-comptable",
  "last_updated": "2026-03-16T10:00:00",
  "user_profile": {
    "prénom": "Marc",
    "entreprise": "Michaut Services",
    "clients_principaux": ["Dupont SA", "Martin SARL"],
    "tarif_journalier": "850€"
  },
  "facts": [
    {"date": "2026-03-10", "content": "Marc a envoyé sa déclaration TVA Q1"},
    {"date": "2026-03-12", "content": "Dupont SA doit 3 factures impayées"}
  ],
  "preferences": {
    "format_devis": "Word",
    "langue_formelle": true
  }
}
```

**Mécanisme :**
- Après chaque session, l'agent extrait et consolide les faits importants (via Haiku, low-cost)
- Les faits sont injectés dans le contexte système de l'agent au début de chaque conversation
- Résumé auto si la mémoire dépasse un seuil (même logique que le context compaction existant)

#### 3b. Base documentaire (RAG locale)

L'utilisateur peut uploader des documents que l'agent utilise comme référence.

**Stockage :** `/home/pi/.clawbot/agents/{id}/docs/`

**Implémentation V1 :**
- Documents stockés en texte plat (PDF → texte via extraction simple)
- L'agent liste ses documents disponibles au démarrage de session
- Il décide lui-même quoi lire via `read_file` selon la question posée
- Claude est parfaitement capable de cette sélection — pas besoin de vectorisation en V1

**Interface UI :**
- Onglet "Documents" dans la fiche de chaque agent
- Upload depuis le dashboard, liste des documents indexés, suppression

---

## Ce qui est HORS SCOPE

| Feature | Raison | Horizon |
|---|---|---|
| Marketplace d'agents communautaires | Nécessite base utilisateurs, validation, payment | V2 (6-12 mois) |
| Templates d'agents pré-faits | Dépend marketplace | V2 |
| Partage d'agent entre utilisateurs | Dépend marketplace | V2 |
| Vectorisation RAG (embeddings locaux) | H3 trop limité en RAM, V2 hardware requis | V2 |
| Mémoire inter-devices | Sync cloud complexe, donnée souveraine | V2 |
| Voix par agent (TTS/STT personnalisé) | Module voice hors MVP | V3 |

---

## Dépendances avec le PRD Principal

| Dépendance | Status PRD | Impact |
|---|---|---|
| Module agent-manager (FR7-FR10) | En cours MVP | Ce brief le spécifie en détail |
| Module system (FR43-FR46) | MVP | Le wizard est un module |
| Dashboard modulaire (FR46) | MVP | Deux sections agents dans le panel |
| Stockage local (FR22-FR25) | MVP | Mémoire + docs stockés sur Pi |
| Plan limits — agents_included | Config fait, non enforced | Enforcement requis ici |

---

## Success Metrics

| Métrique | Cible | Mesure |
|---|---|---|
| Création d'agent via wizard | <5 min du début à "agent prêt" | Temps mesuré en test utilisateur |
| Agent avec mémoire active | Agent reconnaît un fait de la session précédente | Test : mentionner un client, revenir le lendemain |
| Quota enforcement fonctionnel | Refus correct au dépassement | Test : plan Free, tenter de créer 2 agents user |
| Satisfaction wizard | L'utilisateur n'a pas besoin de modifier le prompt généré | >80% des agents créés sans édition manuelle |

---

## Prochaines Étapes BMAD

1. `/bmad-bmm-create-prd` — PRD dédié agents personnalisés
2. `/bmad-bmm-create-architecture` — Décisions techniques (mémoire, wizard, schema)
3. `/bmad-bmm-create-epics-and-stories` — Découpage en stories implémentables
