# Story 2.4 : Thinking indicator & tool trace simplifie

**Epic :** 2 — Chat IA Unifie — "Tu parles, ca fait"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** ClawbotCore-WebUI (index.html)
**Prerequis :** Story 2.1 (Design System), Story 2.3 (Chat unifie)

---

## User Story

As a **utilisateur**,
I want **voir que l'IA travaille avec des animations et des messages clairs**,
So that **je sache que ma demande est en cours sans voir de jargon technique**.

---

## Acceptance Criteria

**Given** l'IA reflechit avant de repondre
**When** le backend envoie un evenement thinking
**Then** une animation etoile + textes rotatifs s'affiche (rotation 2s)

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

---

## Technical Notes

### Thinking indicator (existant a refondre)
Actuel : etoile animee + 8 textes rotatifs (Thinking/Cooking/Scheming/...)
Nouveau (user-facing) :
- Animation : spinner cyan ou pulsation
- Textes rotatifs (2s) traduits en francais : "Reflexion en cours...", "Analyse de la demande...", "Je cherche...", "Je prepare la reponse..."
- Si backend envoie `event: thinking` avec message → utiliser ce message (overrides rotation)
- Disparait quand `event: done` ou `event: tool_call` recus

### Tool trace simplifie (user-facing)
Mapping outil → texte humain :
```js
const TOOL_LABELS = {
  'system__web_search': 'En train de chercher...',
  'system__python':     'En train de coder...',
  'system__bash':       'En train de verifier...',
  'system__read_file':  'En train de lire...',
  'system__write_file': 'En train d\'ecrire...',
  'system__ssh':        'En train de se connecter...',
};
// Fallback : 'En train de travailler...'
```

### Dots animation
- Dot initial : gris #555, pulsation CSS animate
- Dot succes : vert #22c55e, check icon
- Dot erreur : rouge #ef4444, x icon
- Transition : 200ms ease
- Expandable : click → affiche `args` (simplifie) + `result` (truncate 500 chars)

### Mode Geek (caché par défaut)
- Toggle dans settings : `localStorage` interdit → stocker dans `/core/config` ou session
- Mode Geek ON : affiche noms techniques, args JSON complets, result complet
- Mode Geek OFF : affiche seulement les textes humains + dot

### SSE events (reference)
```js
// tool_call
{ type: "tool_call", round: N, calls: [{id, name, args}] }
// tool_result
{ type: "tool_result", round: N, results: [{name, result}] }
// thinking
{ type: "thinking", message: "..." }
```

### MAX_TOOL_ROUNDS
- ClawbotCore : `MAX_TOOL_ROUNDS = 15`
- L'utilisateur ne voit pas de limite — si ca boucle, c'est invisible
- En cas d'impasse : le LLM l'explicite dans sa reponse finale (pas un message d'erreur UI)
