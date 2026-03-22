# Story 2.3 : Zone de chat unifiee & streaming

**Epic :** 2 — Chat IA Unifie — "Tu parles, ca fait"
**Status :** [x] Done
**Priority :** MVP
**Repos :** ClawbotCore-WebUI (index.html), clawbot-core (orchestrator.py, main.py)
**Prerequis :** Story 2.1 (Design System)

---

## User Story

As a **utilisateur**,
I want **une seule zone de texte ou je tape ma demande et l'IA repond en streaming**,
So that **je n'ai aucun choix technique a faire — je parle, ca fait**.

---

## Acceptance Criteria

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
**When** le message est envoye
**Then** le premier token s'affiche en <5s via le tunnel cloud (NFR1)

**Given** l'utilisateur navigue avec ArrowUp/Down dans la zone de saisie
**When** il a un historique de prompts
**Then** les prompts precedents sont rappeles (prompt history)

---

## Technical Notes

### Fusion des 3 modes (CRITIQUE)
- AVANT : 3 boutons (Core / Agent / Core-Agent) visibles
- APRES : zero bouton de mode — routing automatique
- Backend route intelligemment selon la demande
- Mode Geek (settings) : affiche la model bar technique + mode actif

### Endpoints existants
- Core : `POST /v1/chat/completions` → `chat_with_tools_stream()`
- Agent : `POST /v1/chat/agents` → Haiku routing

### Routing automatique (a implementer)
- Simple question → Core (plus rapide, moins de ressources)
- Demande complexe avec outils → Core
- Demande "specialiste" → Core-Agent avec l'assistant selectionne

### Streaming SSE events
```
event: thinking    → afficher thinking indicator (Story 2.4)
event: tool_call   → afficher tool trace (Story 2.4)
event: tool_result → mettre a jour tool trace
event: done        → contenu final
event: error       → message d'erreur
```

### Prompt history
- Extraire depuis `chatHistory` en remontant les messages `role: "user"`
- ArrowUp : message precedent (index -1), ArrowDown : message suivant (+1) ou draft
- Sauvegarder le draft si l'utilisateur a tape avant d'appuyer sur ArrowUp
- Max 50 entrees en memoire (pas de persistance entre sessions)

### session_id
- Genere : `sess_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`
- Envoye dans tous les request bodies
- `GET /core/sessions` → lister, `POST /core/sessions/{id}` → sauvegarder

### UX zone de chat
- Textarea auto-resize (pas de scroll interne, grandit avec le texte)
- Cmd+Enter (Mac) / Ctrl+Enter (Windows) → envoyer
- Enter seul → newline (pas d'envoi)
- Bouton envoyer : icone fleche, disabled pendant le streaming
- Placeholder : "Just ask it..." (toujours en anglais per UX spec)

### Markdown rendering
- `marked.js` + `highlight.js` : deja present dans le dashboard
- Copy buttons sur les code blocks : a conserver
- Sanitize : DOMPurify (a ajouter si absent — securite XSS)
