# Story 3.4 : Systeme de slots & gestion des assistants

**Epic :** 3 — Assistants Specialises — "Ton equipe d'IA"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** ClawbotCore-WebUI (index.html), clawbot-cloud (plans), clawbot-core (agents API)
**Prerequis :** Story 3.1 (Creer assistant), Story 3.3 (Routing LLM)

---

## User Story

As a **utilisateur**,
I want **voir mes slots d'assistants et gerer mon quota**,
So that **je sache combien d'assistants je peux utiliser et comment en avoir plus**.

---

## Acceptance Criteria

**Given** l'utilisateur a un plan avec X slots
**When** il ouvre le panel "Mes assistants"
**Then** l'indicateur affiche "X/Y assistants utilises" (ex: "2/3 assistants")

**Given** l'utilisateur atteint sa limite de slots
**When** il tente de creer un nouvel assistant
**Then** le systeme propose : ajouter un slot (+€3/mois) ou upgrader vers le plan superieur
**And** le message est non-bloquant et non-anxiogene

**Given** l'utilisateur veut supprimer un assistant
**When** il confirme la suppression
**Then** le slot est libere immediatement
**And** l'historique des conversations avec cet assistant est conserve

---

## Technical Notes

### Slots par plan (a definir selon pricing-brainstorm.md)
Valeurs indicatives (a confirmer avec le nouveau modele de pricing) :
```python
PLAN_SLOTS = {
    "free":        3,
    "particulier": 5,    # +slot add-on : +2 pour €3/mois
    "pro":         15,   # +slot add-on : +5 pour €5/mois
    "pro_business": 30,  # illimite en pratique
}
```

### Verification cote backend
- `GET /v1/user/me` retourne `plan` + (a ajouter) `agent_slots_max` + `agent_slots_used`
- `POST /core/agents/{id}` : verifier slots disponibles avant creation
- Retourner HTTP 429 avec message clair si quota atteint

### Indicateur de slots (UI)
- Position : en bas du panel "Mes assistants" ou en header
- Format : barre de progression douce + texte "2/5 assistants"
- Couleur : vert si <80%, orange si >=80%, rouge si 100%
- Non-anxiogene : pas de countdown, pas d'alerte rouge clignotante

### Upsell non-bloquant
- Quand slots pleins ET l'utilisateur tente de creer :
  - Toast ou banner doux (pas de modal bloquante)
  - Message : "Tu as atteint tes 5 assistants. Ajoute un slot (+€3/mois) ou passe au plan superieur."
  - Lien vers la page upgrade (openjarvis.io/upgrade)
- L'utilisateur peut toujours utiliser ses assistants existants

### Suppression d'assistant
- Confirmation via mini-dialog (pas une modale lourde)
- "Supprimer Alice ? Les conversations avec Alice restent accessibles."
- Le slot est libere dans la DB cote cloud
- Les sessions/messages de cet assistant dans les sessions restent (filtre par nom si besoin)

### Add-on slots (Growth)
- A implémenter avec Epic 4 (Abonnement & Tokens)
- Pour MVP : juste afficher le message d'upgrade avec lien
