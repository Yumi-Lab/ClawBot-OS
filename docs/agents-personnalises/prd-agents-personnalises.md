---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-02b-vision', 'step-02c-executive-summary']
inputDocuments:
  - 'docs/agents-personnalises/product-brief-agents-personnalises.md'
  - 'docs/planning-artifacts/product-brief-clawbot-2026-03-08.md'
  - 'docs/planning-artifacts/prd.md'
workflowType: 'prd'
classification:
  projectType: 'saas_b2b + iot_embedded'
  domain: 'general'
  complexity: 'medium'
  projectContext: 'brownfield'
terminology:
  marketing_ui: 'employé'
  backend_api: 'agent'
  verbs_ui: 'embaucher, licencier, mon équipe'
  verbs_api: 'create, delete, list'
---

# Product Requirements Document — Agents Personnalisés OpenJarvis

**Author:** Nicolas
**Date:** 2026-03-16
**Version:** 0.3 — Aligné code + vision
**Parent:** docs/planning-artifacts/prd.md (PRD principal ClawBot)

---

## Executive Summary

OpenJarvis Agents Personnalisés transforme un boîtier Pi à 29$ en une équipe d'employés IA spécialisés, embauchés par l'utilisateur en 5 minutes via conversation vocale. Contrairement à ChatGPT, Claude ou tout autre assistant IA généraliste, chaque employé OpenJarvis possède une identité, un rôle métier, une mémoire persistante automatique, et un sous-ensemble d'outils adapté à sa mission. L'utilisateur ne configure rien — il décrit son besoin, le wizard génère l'employé.

Le système repose sur deux couches : une fondation de ~30 tools atomiques invisibles (fichiers, web, exécution, email, git, SSH) et une couche employés qui orchestre ces tools avec intelligence métier. Les employés collaborent entre eux via délégation transversale — n'importe quel employé peut solliciter n'importe quel collègue, sans hiérarchie imposée.

Le différenciateur décisif est la mémoire système automatique : contrairement à tous les concurrents où l'IA "oublie" entre les sessions, OpenJarvis extrait automatiquement les faits importants après chaque conversation, les stocke dans un système de mémoire subdivisée avec index master, et les ré-injecte au démarrage de chaque session. L'écriture mémoire est atomique (write tmp + rename) avec 10 backups rotatifs pour garantir l'intégrité.

La sécurité est assurée au niveau OS : un user Linux dédié `openjarvis-agents`, créé à la construction de l'image, sandbox tous les accès.

### Ce qui rend ce produit unique

**Mémoire automatique et illimitée** — L'extraction post-conversation est système, pas volontaire. Index master toujours injecté + sous-mémoires chargées à la demande + subdivision automatique au seuil. Le moment "wow" : l'utilisateur revient le lendemain, dit "Sophie, reprends le devis Dupont" — Sophie sait exactement de quoi il parle.

**Des employés, pas un chatbot** — Chaque agent a un nom, un avatar, un rôle métier, ses propres outils et sa propre mémoire. Ce sont des collaborateurs, pas des assistants génériques.

**Équipes transversales avec délégation** — Les employés collaborent entre eux sans hiérarchie. Le wizard "Créer une équipe" génère une composition complète depuis une description de projet — avec upsell intégré quand le quota est insuffisant.

**Souveraineté locale** — Tout tourne sur le Pi. Les données ne quittent jamais le domicile.

**Onboarding en 5 minutes, voice-first** — Deux modes au choix (5 min rapide ou 20 min guidé). Pas de jargon — juste une question de temps.

### Classification projet

- **Type :** SaaS B2B hybride IoT embarqué
- **Domaine :** Général (employés IA personnalisés multi-métiers)
- **Complexité :** Medium
- **Contexte :** Brownfield — extension du système ClawBot/OpenJarvis existant

---

## 0. Terminologie

| Contexte | Terme | Exemples |
|---|---|---|
| **Marketing / UI** | **employé** | "Mes employés", "Embaucher un employé", "Mon équipe" |
| **Backend / API / code** | **agent** | `agent_id`, `/core/agents`, `load_agents()` |
| **Verbes UI** | embaucher, licencier, équipe | "Embauchez votre premier employé" |
| **Verbes API** | create, delete, list | `POST /core/agents/{id}` |

L'utilisateur ne voit **jamais** le mot "agent" dans l'interface (sauf mode Geek). Le code ne change **jamais** ses noms de variables — `agent` reste `agent` partout.

---

## 1. Contexte & Correction Architecturale Fondamentale

### 1.1 Le problème de départ

Le PRD principal définit 4 "agents système" (Julien/Python, Marc/Sysadmin, Sophie/Researcher, Thierry/FileManager) qui cohabitent avec les futurs agents utilisateur dans le même bucket et le même quota. Sur un plan Starter (3 agents inclus), les 4 agents système occupent tout l'espace — l'utilisateur ne peut pas embaucher un seul employé.

### 1.2 La correction fondamentale — Julien, Marc, Sophie, Thierry ne sont PAS des agents

**Décision :** Les 4 entités actuelles ne sont pas des agents — ce sont des **outils déguisés en agents**. Ils ont des noms, des avatars, mais leur fonction est purement technique : exécuter du Python, du Bash, chercher sur le web, gérer des fichiers. Ce sont des wrappers de capacités, pas des employés avec identité ou mémoire.

**Correction :** Supprimer Julien, Marc, Sophie système et Thierry comme agents. Leurs capacités sont absorbées dans la couche **Tools** de la nouvelle architecture.

---

## 2. Architecture — Deux Couches

### 2.1 Vue d'ensemble

```
┌─────────────────────────────────────────────────────────┐
│                    EMPLOYÉS                              │
│   Agents personnalisés — identité, mémoire, rôle métier │
│   Sophie la Comptable · Max le Coordinateur · ...       │
│   Embauchés par l'utilisateur via wizard                │
│   Comptés dans le quota du plan                         │
├─────────────────────────────────────────────────────────┤
│               CLAWBOT CORE (mode root)                  │
│   Accès direct à tous les tools — mode expert/geek      │
│   Aucun développement requis — existe déjà              │
│   Non exposé au grand public au premier démarrage       │
├─────────────────────────────────────────────────────────┤
│                      TOOLS                              │
│   ~30 tools atomiques en ~8 modules                     │
│   Invisibles pour l'utilisateur final                   │
│   Activés par module selon le rôle de l'employé         │
│   Exécutés sous user OS dédié : openjarvis-agents       │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Les Employés

Un employé est un agent IA personnalisé embauché par l'utilisateur :

| Attribut | Description |
|---|---|
| **Identité** | Nom, avatar, rôle métier défini par l'utilisateur |
| **Mémoire persistante** | Index master + sous-mémoires subdivisées par domaine |
| **Base documentaire** | Dossier de documents uploadés, lus via `files__read` |
| **Modules activés** | Sous-ensemble de tools sélectionné à l'embauche |
| **Équipe** | Liste des collègues auxquels il peut déléguer (`team`) |
| **Quota** | Comptabilisé dans `agents_included` du plan |

### 2.3 La couche Tools

Les tools sont atomiques — chaque tool fait **une seule action**. L'employé reçoit uniquement les tools de ses modules activés.

**Convention de nommage :** `{module}__{action}` (double underscore)

#### Tools obligatoires — tous les employés, toujours

| Tool | Description |
|---|---|
| `web__search` | Recherche DuckDuckGo |
| `web__fetch` | Extraire texte d'une URL |

#### Module `files` — gestion de fichiers

| Tool | Description |
|---|---|
| `files__read` | Lire le contenu d'un fichier |
| `files__write` | Écrire ou créer un fichier |
| `files__list` | Lister le contenu d'un dossier |
| `files__move` | Déplacer ou renommer |
| `files__delete` | Supprimer un fichier |
| `files__mkdir` | Créer un dossier |

#### Module `documents` — traitement de documents

| Tool | Description |
|---|---|
| `documents__pdf_to_text` | Extraire le texte d'un PDF |
| `documents__csv_read` | Lire et parser un CSV |
| `documents__csv_write` | Écrire des données CSV |

#### Module `exec` — exécution de code

| Tool | Description |
|---|---|
| `exec__python` | Exécuter un script Python |
| `exec__bash` | Exécuter une commande Bash |

#### Module `network` — requêtes réseau

| Tool | Description |
|---|---|
| `network__http_get` | Requête HTTP GET |
| `network__http_post` | Requête HTTP POST |
| `network__download` | Télécharger un fichier |

#### Module `email` — messagerie

| Tool | Description |
|---|---|
| `email__send` | Envoyer un email |
| `email__read` | Lire un email |
| `email__list` | Lister les emails |

#### Module `git` — gestion de version (GeekTech)

| Tool | Description |
|---|---|
| `git__status` | État du dépôt |
| `git__commit` | Créer un commit |
| `git__push` | Pousser vers distant |
| `git__pull` | Récupérer modifications |
| `git__log` | Historique des commits |

#### Module `system` — système et SSH

| Tool | Description |
|---|---|
| `system__ssh` | Commande SSH distante |
| `system__info` | Informations système Pi |
| `system__disk` | Espace disque disponible |

#### Module `agents` — délégation inter-employés

| Tool | Description |
|---|---|
| `agents__delegate` | Déléguer une tâche à un collègue |

#### Module `scheduler` — tâches planifiées

| Tool | Description |
|---|---|
| `scheduler__create` | Créer une tâche planifiée |
| `scheduler__list` | Lister les tâches actives |
| `scheduler__cancel` | Annuler une tâche |

**Total V1 : 2 tools obligatoires + 31 tools en 9 modules = 33 tools atomiques**

#### Modules hors scope V1

| Module | Raison du report |
|---|---|
| Apache/PHP | Non pertinent grand public |
| Vectorisation RAG | RAM Pi H3 insuffisante pour embeddings |
| Image/Vision | Modèles trop lourds pour H3 |
| Calendrier | Dépend intégrations tierces |

---

## 3. Sécurité — Modèle de sandboxing

### 3.1 User Linux dédié

Un user OS `openjarvis-agents` est créé **à la construction de l'image** (CI GitHub ClawBot-OS). C'est un compte de service — le Pi démarre toujours sur `pi`.

```bash
useradd -r -m -d /home/openjarvis-agents -s /bin/bash openjarvis-agents
```

### 3.2 Structure du workspace

```
/home/openjarvis-agents/
  ├── agents/
  │   ├── {agent_id}/
  │   │   ├── memory/
  │   │   │   ├── memory-index.md       ← index master (toujours injecté)
  │   │   │   ├── memory-clients.md     ← sous-mémoire par domaine
  │   │   │   ├── memory-factures.md    ← chargée à la demande
  │   │   │   └── backups/              ← 10 backups rotatifs (owned root, read-only)
  │   │   ├── docs/                     ← documents uploadés
  │   │   └── workspace/               ← espace de travail temporaire
  └── tmp/
```

### 3.3 Mécanisme de protection

| Couche | Mécanisme | Ce qu'elle protège |
|---|---|---|
| **OS (user)** | `openjarvis-agents` sans sudo | Système, code source, `/etc/`, `apt` |
| **OS (AppArmor)** | Profil dans l'image | Chemins autorisés, binaires autorisés |
| **OS (backups)** | Owned root, read-only | Intégrité sauvegardes mémoire |
| **Code (ClawbotCore)** | Injection chemin agent actif uniquement | Isolation mémoire inter-agents |

### 3.4 Permissions des employés

**Peuvent :** lire/écrire dans leur workspace, exécuter Python/Bash sandboxé, accéder au web, gérer leurs fichiers.

**Ne peuvent pas :** modifier le code source, accéder à `/etc/`, utiliser `apt`/`dpkg`, `systemctl` sur services protégés, lire la mémoire d'un autre employé, escalader en `pi` ou `root`, lire les backups mémoire.

---

## 4. Expérience Utilisateur — Premier Démarrage et Wizard

### 4.1 Public cible

Monsieur et Madame Tout-le-Monde. Aucune connaissance technique requise. Le mode ClawBot Core existe pour les geeks mais n'est jamais mis en avant.

### 4.2 Premier démarrage — Onboarding = Embauche du premier employé

Au premier démarrage, l'utilisateur est dirigé directement vers l'embauche de son premier employé. Pas de configuration préalable. Pas de mode root visible.

### 4.3 Le Wizard — Choix de durée

```
┌─────────────────────────────────────────────────────┐
│     Embauchons votre premier employé                │
│                                                      │
│  ⚡ 5 minutes    🎯 20 minutes                       │
│  L'IA génère    Questions guidées                    │
│  tout pour vous pour un employé précis               │
└─────────────────────────────────────────────────────┘
```

Pas de jargon. Pas de "mode expert / débutant". Juste du temps.

### 4.4 Interface — Voice-first

Le wizard est conçu pour la **voix en premier**. La frappe clavier est un fallback de qualité égale.

Le module Voice (whisper.cpp) est une feature V2. Le wizard fonctionne parfaitement en clavier seul.

| Surface | Technologie STT | Timeline |
|---|---|---|
| Pi | `whisper.cpp` tiny/small | V2 |
| PC/Mac | Whisper via web | V2 |
| Mobile | STT natif OS | V2 |

### 4.5 Flow 5 minutes (rapide)

```
Wizard : "Décris-moi l'employé que tu veux embaucher."
User : "Un comptable pour mes devis et factures"
Wizard : "Comment tu veux l'appeler ?"
User : "Sophie"
Wizard : [génère : avatar, system_prompt, modules activés]
Wizard : "Voici Sophie — elle peut gérer tes fichiers, lire tes PDFs et envoyer
          des emails. Elle est prête. Tu veux lui parler ?"
→ Sophie est embauchée, première conversation commence
```

Maximum 3-4 questions. L'IA génère tout le reste.

### 4.6 Flow 20 minutes (guidé)

Questions structurées : identité, rôle précis, cas d'usage (3 exemples), modules en langage naturel, documents de référence à uploader, preview conversationnelle avant validation.

L'utilisateur ne voit **jamais** le system_prompt.

### 4.7 Comportement interactif des employés

**Différence fondamentale avec ClawBot Core :** le mode Core est autonome (exécute sans poser de questions). Les employés sont **interactifs par défaut** — ils posent des questions, proposent des choix, demandent confirmation.

Le template de system prompt de chaque employé inclut systématiquement :

```
- Pose des questions quand tu as plusieurs options possibles
- Demande confirmation avant d'envoyer un email ou supprimer un fichier
- Propose des choix clairs quand la demande est ambiguë
- Ne fais jamais une action irréversible sans validation de l'utilisateur
- Explique ce que tu as fait et propose la suite
```

Ce comportement est généré automatiquement par le wizard. L'utilisateur n'a pas à le configurer — c'est le comportement par défaut de tout employé.

### 4.8 Activation automatique des modules

Le wizard détecte les modules depuis la description :

| Description utilisateur | Modules activés |
|---|---|
| "gérer mes factures, devis" | files, documents, email |
| "organiser ma famille" | files, email |
| "développer mes projets" | files, exec, git, system |
| "rechercher des informations" | web (obligatoire), files |

---

## 5. Mémoire Persistante — Système Automatique

### 5.1 Différenciateur vs la concurrence

| | ChatGPT / Claude | OpenJarvis |
|---|---|---|
| Lecture mémoire | L'IA doit y penser | **Automatique** — index master toujours injecté |
| Écriture mémoire | L'IA doit y penser | **Automatique** — extraction post-conversation |
| Index | Maintenu par l'IA (oublis) | **Maintenu par le système** (fiable) |
| Compaction | Manuelle | **Automatique** au seuil |
| Intégrité | Aucune garantie | **Écriture atomique + 10 backups rotatifs** |

### 5.2 Architecture mémoire subdivisée

```
agents/{id}/memory/
  ├── memory-index.md          ← MASTER — toujours injecté (~2k tokens)
  ├── memory-clients.md        ← chargé à la demande via files__read
  ├── memory-factures.md       ← chargé à la demande
  ├── memory-procedures.md     ← chargé à la demande
  └── backups/                 ← 10 rotatifs, owned root, invisibles pour l'agent
```

**Fonctionnement par conversation :**

1. ClawbotCore injecte **toujours** `memory-index.md` dans le system prompt
2. L'employé voit l'index — il sait ce qu'il sait et où chercher
3. Il appelle `files__read("memory-clients.md")` selon la question
4. En fin de conversation, ClawbotCore lance l'extraction automatique
5. Au seuil de taille, le système subdivise les sous-mémoires

### 5.3 Extraction automatique post-conversation

L'employé n'a jamais à "décider" de se souvenir — le système le fait pour lui.

```
Conversation terminée
  └─ ClawbotCore lance un prompt Haiku séparé (extracteur de faits)
       └─ Extrais les faits nouveaux
       └─ Compare avec memory-index.md
       └─ Écris les mises à jour dans les bons fichiers
       └─ Reconstruit l'index si nécessaire
```

**Coût :** ~0.001$ par extraction. Free user 10-15 conv/jour = < 2 centimes/jour.

**Sécurité prompt injection :** le prompt d'extraction est un prompt **système séparé et fixe**. Il reçoit le texte brut comme **données**, pas comme **instructions**.

### 5.4 Écriture atomique et backups

```python
# Écriture atomique — jamais de fichier à moitié écrit
write("memory-clients.md.tmp", new_content)
rename("memory-clients.md.tmp", "memory-clients.md")  # atomique sur ext4
```

**10 backups rotatifs** gérés par ClawbotCore :
- Seul le fichier actif est dans l'index master
- Backups owned root, read-only — invisibles pour l'agent
- Restauration manuelle par l'utilisateur si nécessaire

### 5.5 Base documentaire (RAG V1 sans vectorisation)

L'utilisateur uploade des documents. L'agent liste ses documents au démarrage et décide quoi lire via `files__read` selon la question. Vectorisation RAG reportée en V2.

### 5.6 Compaction de contexte (déjà implémenté)

**Feature existante dans ClawbotCore :** au-delà de 15 000 tokens estimés (`COMPACT_THRESHOLD`), les anciens messages sont résumés via Haiku et remplacés par un résumé. Les 6 derniers messages sont conservés (`COMPACT_KEEP_RECENT`). Économie ~50% de contexte sur les longues conversations.

---

## 6. Architecture Technique — Implémentation

### 6.1 Tool system

Architecture module existante (manifest.json + local HTTP + POST /execute), alignée MCP sans SDK officiel.

- Chaque module expose ses tools via `manifest.json`
- ClawbotCore charge uniquement les tool_definitions des modules activés pour l'employé actif
- Injection dans l'appel API Claude : contexte tight (4-8 tools max par agent)
- Routing : `{module}__{tool}` → POST `http://127.0.0.1:{port}/v1/{module}/execute`

### 6.2 Mapping tools existants → nouvelle convention

Le code actuel utilise le préfixe `system__` pour tous les builtins. La migration vers `{module}__` se fait progressivement :

| Code actuel (`system__*`) | Nouveau (`{module}__*`) | Module |
|---|---|---|
| `system__bash` | `exec__bash` | exec |
| `system__python` | `exec__python` | exec |
| `system__read_file` | `files__read` | files |
| `system__write_file` | `files__write` | files |
| `system__ssh` | `system__ssh` | system (inchangé) |
| `system__web_search` | `web__search` | web |
| `system__get_system_info` | `system__info` | system |
| `system__handoff` | `agents__delegate` | agents |
| `system__spawn_agents` | `agents__spawn` | agents (V2) |
| `system__schedule_task` | `scheduler__create` | scheduler |
| `system__list_tasks` | `scheduler__list` | scheduler |
| `system__cancel_task` | `scheduler__cancel` | scheduler |

### 6.3 Schema agent JSON

**Schema actuel dans le code :**

```json
{
  "id": "sophie-comptable",
  "name": "Sophie",
  "avatar": "💼",
  "color": "#3776ab",
  "system_prompt": "Tu es Sophie, comptable de Marc...",
  "skills": ["files__read", "files__write", "documents__pdf_to_text", "email__send"],
  "keywords": ["facture", "devis", "comptable", "TVA"],
  "enabled": true,
  "twins_partner": false
}
```

**Champs à ajouter pour la V1 :**

```json
{
  "type": "user",
  "team": ["dev-front", "seo-expert"],
  "memory_enabled": true,
  "modules_enabled": ["files", "documents", "email"],
  "created_at": "2026-03-16T10:00:00"
}
```

### 6.4 Quota enforcement

- `agents_included` poussé dans le payload de provisioning cloud → Pi
- Stocké dans `/etc/clawbot/plan.json`
- Quota check au POST `/core/agents` : si `type == "user"` et `count(user_agents) >= agents_included` → refus

---

## 7. Délégation Inter-Agents & Équipes

### 7.1 Délégation séquentielle V1 — s'appuie sur `system__handoff` existant

**Feature déjà implémentée dans ClawbotCore** sous le nom `system__handoff`. La mécanique existe : un agent transfère une tâche à un autre agent, attend le résultat, et l'intègre dans sa réponse.

**Ce qui change :** renommer `system__handoff` → `agents__delegate`, et restreindre l'accès au champ `team` de l'agent (au lieu de pouvoir appeler n'importe quel agent).

```
Employé "Chef de projet" reçoit : "Lance la refonte du site"
  └─ agents__delegate("dev-front", task="Crée la maquette homepage")  → attend
  └─ agents__delegate("dev-back", task="Prépare l'API REST")          → attend
  └─ agents__delegate("seo-expert", task="Mots-clés prioritaires")    → attend
  └─ Synthétise → répond à l'utilisateur
```

**Règles de délégation V1 :**
- **Pas de re-délégation** — un employé contacté fait son travail et renvoie le résultat. Il ne délègue pas à son tour. Seul l'appelant principal a accès au tool `agents__delegate`.
- Un agent ne peut déléguer qu'aux agents définis dans son champ `team`
- Chaque agent délégué tourne avec sa propre mémoire et ses propres modules
- Le résultat est injecté comme contexte dans la conversation principale

### 7.2 Parallélisation — `system__spawn_agents` (existant, V2)

**Feature déjà implémentée dans ClawbotCore** sous le nom `system__spawn_agents`. Lance plusieurs agents en parallèle (ThreadPool), chacun sur une tâche indépendante, fusionne les résultats.

**Décision V1 :** conserver le code mais ne pas l'exposer aux employés. La complexité de coordination (dépendances, erreurs mid-course, debugging parallèle) justifie de rester en séquentiel pour V1. La parallélisation sera exposée en V2 quand le séquentiel sera stable.

### 7.3 Équipes transversales

Les employés collaborent **sans hiérarchie**. N'importe quel employé peut appeler n'importe quel collègue de son équipe. Pas de "chef" prédéfini — l'utilisateur décide à qui il parle.

```
Équipe plate — pas de hiérarchie

  Sophie ←→ Max ←→ Dev Front ←→ SEO Expert
    ↕           ↕           ↕
  Dev Back ←→ Analyste ←→ Rédacteur
```

Exemple d'équipe e-commerce :

| Employé | Spécialité | Modules |
|---|---|---|
| Expert Shopify Thèmes | Liquid, front | files, exec |
| Expert Shopify SEO | Métadonnées, URLs | web, files |
| Expert Shopify Conversion | A/B tests | web, files, network |
| Expert Shopify Analytics | GA4, Klaviyo | network, documents |
| Expert Shopify Email | Flows, campagnes | email, files |

### 7.4 Wizard "Créer une équipe"

```
1. User : "Je veux créer une équipe pour mon e-commerce Shopify"
2. Wizard : Analyse → propose une composition
3. Wizard : [Check quota]
```

**Flow quota insuffisant :**

```
"Cette équipe nécessite 6 employés. Tu en as 2 slots disponibles.

 [Passer au plan Pro — 10 employés inclus — 30$/mois]       ← recommandé
 [Créer une équipe réduite — 2 employés prioritaires]        ← dégradé
 [Ajouter les employés manquants — 4 × 2.90$ = 11.60$/mois] ← à l'unité"
```

L'upgrade se fait depuis le wizard sans quitter l'expérience.

---

## 8. Features existantes à conserver

### 8.1 Routing intelligent Haiku (déjà implémenté)

ClawbotCore route automatiquement les messages vers l'agent le plus pertinent via un appel Haiku. Fallback par keywords si Haiku échoue. Messages ≤ 3 mots → Core directement.

**À adapter :** le routing doit fonctionner avec les employés utilisateur, pas seulement les 4 agents système par défaut. Quand l'utilisateur a 6 employés, Haiku doit choisir parmi les 6.

### 8.2 Skill matching et injection (déjà implémenté)

Le système match les mots-clés du message utilisateur contre les skills disponibles et injecte les instructions pertinentes dans le system prompt. Ce mécanisme reste tel quel — les modules des employés s'intègrent via le même pipeline.

### 8.3 Twins Partner — Revue qualité (déjà implémenté)

Un agent peut activer `twins_partner: true` pour qu'un reviewer Haiku vérifie la qualité de sa réponse avant envoi. Jusqu'à 2 passes de révision.

**Pour les employés :** proposer cette option dans le wizard 20 minutes. "Voulez-vous que Sophie vérifie ses réponses avant de vous les envoyer ?" Augmente la fiabilité au coût d'un appel Haiku supplémentaire par réponse.

### 8.4 Multi-agent streaming SSE (déjà implémenté)

L'endpoint `/v1/chat/agents` supporte déjà le multi-agent streaming : plusieurs agents répondent en parallèle avec des événements SSE distincts (`agent_start`, `content_delta`, `done`, `all_done`). Infrastructure prête pour V2 parallélisation.

---

## 9. Hors Scope V1

| Feature | Raison | Horizon |
|---|---|---|
| Vectorisation RAG (embeddings) | RAM Pi H3 insuffisante | V2 |
| Module Voice (whisper.cpp) | Feature parallèle, wizard fonctionne en clavier | Sprint dédié |
| Application mobile (télécommande) | Projet séparé | V2 |
| Apache/PHP par défaut | Non pertinent grand public | Module opt-in |
| Marketplace d'employés/équipes | Nécessite base utilisateurs | V2 (6-12 mois) |
| Mémoire inter-devices | Sync cloud complexe | V2 |
| Délégation parallèle (`agents__spawn`) | Complexité coordination | V2 (code existe, non exposé) |
| Re-délégation (employé contacté re-délègue) | Pas de besoin identifié | V2 si besoin |
| Jumeau virtuel (Digital Twin) | Méta-agent qui apprend de toutes les interactions, construit un profil complet de l'utilisateur (style, préférences, décisions). Feature premium accumulatrice — plus l'utilisateur l'utilise, plus le jumeau est précis. Nécessite mémoire V1 stable + volume de données. | V2 Premium |

---

## 10. Dépendances

| Dépendance | Status | Impact |
|---|---|---|
| Module agent-manager FR7-FR10 | En cours MVP | Ce PRD le spécifie en détail |
| Quota enforcement `agents_included` | Config fait, non enforced | Enforcement requis |
| User OS `openjarvis-agents` | À créer dans le build image | Sécurité tools exec |
| AppArmor profil | À créer dans le build image | Sandboxing complet |
| Renommage `system__*` → `{module}__*` | Code existant | Migration progressive |
| Module Voice (whisper.cpp) | À développer | Non bloquant V1 |

---

## 11. Success Metrics

| Métrique | Cible |
|---|---|
| Embauche flow 5 min | < 5 min de l'allumage à "employé prêt" |
| Embauche flow 20 min | < 20 min, sans édition manuelle |
| Mémoire active | Employé reconnaît un fait de la session précédente dans 100% des cas |
| Mémoire intégrité | Zéro corruption (écriture atomique + backups) |
| Quota enforcement | Refus correct au dépassement, upsell clair |
| Sandboxing | `rm -rf /` ou `apt remove` bloqués par l'OS |
| Tool auto-activation | Modules corrects dans >80% des cas |
| Délégation | Employé contacté exécute et renvoie sans re-délégation |
| Routing | Haiku sélectionne le bon employé dans >90% des cas |
| Coût free user | < 10 centimes/jour |

---

*Prochaines étapes BMAD : Step 3 — Success Criteria détaillés, puis Architecture technique, puis Epics & Stories*
