# Story 2.5 : Historique conversations & persistence

**Epic :** 2 — Chat IA Unifie — "Tu parles, ca fait"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** ClawbotCore-WebUI (index.html), clawbot-core (main.py sessions API)
**Prerequis :** Story 2.2 (Dashboard refonte — sidebar)

---

## User Story

As a **utilisateur**,
I want **retrouver mes conversations precedentes et reprendre ou j'en etais**,
So that **rien ne soit perdu entre les sessions**.

---

## Acceptance Criteria

**Given** l'utilisateur a des conversations precedentes
**When** il ouvre la sidebar
**Then** les conversations sont listees par date (Aujourd'hui, Hier, Cette semaine, Ce mois)

**Given** l'utilisateur cherche un message
**When** il tape dans la barre de recherche
**Then** la recherche full-text filtre les conversations en temps reel (debounce 300ms)

**Given** l'utilisateur ferme le dashboard et revient plus tard
**When** il rouvre le dashboard
**Then** sa derniere session est restauree exactement ou il l'avait laissee
**And** les sessions sont persistees cote serveur (PAS localStorage)

**Given** le contexte depasse le seuil de compaction
**When** la compaction automatique se declenche
**Then** le contexte est reduit sans perdre les informations essentielles
**And** l'operation est invisible pour l'utilisateur

---

## Technical Notes

### Sessions API (existant)
```
GET  /core/sessions        → liste toutes les sessions
GET  /core/sessions/{id}   → charge une session
POST /core/sessions/{id}   → sauvegarde une session
DEL  /core/sessions/{id}   → supprime une session
```

### Format session JSON
```json
{
  "id": "sess_1234_abcde",
  "name": "First user message (40 chars)",
  "mode": "core",
  "messages": [{"role": "user"|"assistant", "content": "..."}],
  "createdAt": 1704067200000,
  "updatedAt": 1704067299000
}
```

### Regroupement par date (frontend)
```js
function groupByDate(sessions) {
  const now = Date.now();
  const today = isToday(s.updatedAt);
  const yesterday = isYesterday(s.updatedAt);
  // Groupes : "Aujourd'hui", "Hier", "Cette semaine", "Ce mois", "Plus ancien"
}
```

### Recherche full-text
- Debounce 300ms sur l'input
- Recherche dans `session.name` + `session.messages[].content`
- Highlight les termes trouves dans les resultats (classe CSS `.highlight`)
- Pas d'API backend pour la recherche — tout en memoire JS (sessions deja chargees)

### Persistence & sessSave()
- `sessSave()` appele IMMEDIATEMENT apres push du message user (avant reponse)
- `session_id` envoye dans tous les request bodies
- `checkPendingResponse()` : si dernier message user apres refresh → poll 3s pendant 5 min
- `_save_assistant_to_session()` : backend save en background apres `done`
- `BrokenPipeError` catch → thread daemon draine le generateur SSE → save

### Compaction auto (ClawbotCore)
- Seuil : `COMPACT_THRESHOLD = 15000` tokens
- Garde : `COMPACT_KEEP_RECENT = 6` messages recents
- Resume : appel Haiku avec tags `<passation>`
- Frontend : invisible — juste une interruption de streaming transparente

### IMPORTANT : pas de localStorage
- Stocker `currentSessionId` en variable JS (memoire runtime seulement)
- Toutes les donnees cote serveur via `/core/sessions`
- Exception autorisee : preferences UI sans donnees (ex: sidebar etat ouvert/ferme)
