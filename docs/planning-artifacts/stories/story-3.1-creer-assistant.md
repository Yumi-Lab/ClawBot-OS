# Story 3.1 : Creer un assistant avec nom et description naturelle

**Epic :** 3 — Assistants Specialises — "Ton equipe d'IA"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** ClawbotCore-WebUI (index.html panel agents), clawbot-core (agents API)

---

## User Story

As a **utilisateur**,
I want **creer un assistant specialise en lui donnant un nom et une description en langage naturel**,
So that **j'aie un expert dedie a mes besoins sans ecrire de prompt technique**.

---

## Acceptance Criteria

**Given** l'utilisateur ouvre le panel "Mes assistants"
**When** il clique sur "Creer un assistant"
**Then** un formulaire s'affiche : nom (ex: "Alice"), description naturelle, avatar optionnel

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

---

## Technical Notes

### IMPORTANT : terminologie
- UI : "assistant", "Mes assistants", "Creer un assistant"
- Interne / API / code : "agent", `agent_id`, fichiers JSON
- L'utilisateur ne voit JAMAIS le mot "agent" — sauf en mode Geek

### Agents API (existant)
```
GET    /core/agents         → liste tous les agents
GET    /core/agents/{id}    → charge un agent
POST   /core/agents/{id}    → cree/sauvegarde un agent
DELETE /core/agents/{id}    → supprime un agent
```

### Format agent JSON
```json
{
  "id": "alice-comptable",
  "name": "Alice",
  "system_prompt": "[genere depuis la description]",
  "skills": ["system__bash", "system__python"],
  "keywords": ["devis", "facture", "TVA", "compta"],
  "avatar": "💼",
  "color": "#00ffe0"
}
```

### Generation du system prompt
- Appel LLM (Haiku) avec la description naturelle de l'utilisateur
- Prompt de generation : "Transforme cette description en system prompt professionnel..."
- Le system_prompt genere est stocke en JSON
- L'utilisateur ne voit jamais le system_prompt brut (sauf mode Geek)

### Description naturelle → system prompt
Exemple :
- Input : "Alice, ma comptable. Elle fait mes devis et ma TVA."
- Output system_prompt : "Tu es Alice, une assistante comptable experte. Tu aides Marc..."

### Agents par defaut (existants, a renommer)
4 agents default : python-dev, sysadmin, web-researcher, file-manager
→ Renommer avec des noms humains en mode user : "Le Developpeur", "L'Admin Systeme", etc.

### Storage
- Agents stockes : `/home/pi/.clawbot/agents/*.json`
- Un fichier JSON par agent
- id = slug du nom (ex: "Alice Comptable" → "alice-comptable")
