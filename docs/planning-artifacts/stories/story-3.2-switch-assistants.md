# Story 3.2 : Selection et switch entre assistants

**Epic :** 3 — Assistants Specialises — "Ton equipe d'IA"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** ClawbotCore-WebUI (index.html), clawbot-core (agents API)
**Prerequis :** Story 3.1 (Creer assistant)

---

## User Story

As a **utilisateur**,
I want **basculer entre mes assistants dans une meme session**,
So that **je puisse utiliser le bon expert selon ma demande**.

---

## Acceptance Criteria

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

---

## Technical Notes

### AgentPicker UI
- Grille de cartes : nom + emoji/avatar + couleur + courte description
- Carte active : border cyan 2px
- Clic → switch immediat, pas de confirmation
- Acces : bouton discret dans la zone de chat (icone @ ou icone robot)
- En mode icon rail (sidebar collapsed) : accessible via icone

### Injection system_prompt
- Le system_prompt est envoye dans le body request : `"system": agent.system_prompt`
- Si switch en cours de session : le nouveau system_prompt s'applique au prochain message
- Le contexte existant (messages) est conserve dans `chatHistory`
- Note : changer d'assistant en cours de conversation peut casser la coherence → acceptable pour MVP

### Request body avec assistant
```js
{
  "model": "claude-sonnet-4-6",  // optionnel si routing auto
  "messages": chatHistory,
  "system": currentAgent.system_prompt,
  "session_id": currentSessionId,
  "stream": true
}
```

### Assistant generaliste (defaut)
- `id: "default"`, pas de system_prompt specifique
- Routing automatique → ClawbotCore injecte son propre system prompt
- "You are ClawbotOS Core, running on Raspberry Pi (AllWinner H3)..."

### Routing LLM (lien avec Story 3.3)
- Le routing vers Haiku/Sonnet/Opus est independant de la selection d'assistant
- L'assistant definit le PERSONA, pas le modele
- Le modele est determine par : plan ceiling + complexite

### UX
- Label "Assistant actif : Alice" discret dans le header de la zone chat
- Pas de modal lourde — picker leger type "pill selector" ou drawer
- Mode Geek : affiche le nom du modele utilise en plus de l'assistant
