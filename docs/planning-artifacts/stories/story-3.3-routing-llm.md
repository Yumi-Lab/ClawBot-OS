# Story 3.3 : Routing LLM intelligent par plan

**Epic :** 3 — Assistants Specialises — "Ton equipe d'IA"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** clawbot-cloud (llm_proxy.py, config.py), clawbot-core (orchestrator.py)

---

## User Story

As a **systeme**,
I want **router invisiblement les requetes vers le bon modele LLM selon le plan et la complexite**,
So that **l'utilisateur obtienne la meilleure reponse possible sans choisir un modele**.

---

## Acceptance Criteria

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

---

## Technical Notes

### Modele de routing actuel (a enrichir)
```python
PLAN_LIMITS = {
    "free":        {"tokens_per_day": 10_000,    "model_ceiling": "claude-haiku-4-5-20251001"},
    "particulier": {"tokens_per_day": 200_000,   "model_ceiling": "claude-sonnet-4-6"},
    "pro":         {"tokens_per_day": 2_000_000, "model_ceiling": "claude-opus-4-6"},
}
MODEL_HIERARCHY = ["claude-haiku-4-5-20251001", "claude-sonnet-4-6", "claude-opus-4-6"]
```

### Logique model_ceiling
- `model_ceiling` = modele max autorise pour le plan
- Si le client demande un modele superieur → fallback sur ceiling
- Modele inconnu → fallback sur ceiling du plan
- TPM 429 (rate limit Anthropic) → backoff 60s + retry automatique

### Routing intelligent (a implementer)
Haiku (claude-haiku-4-5-20251001) pour :
- Questions simples (<100 mots, pas d'outils)
- Context compaction
- Routing/classification des agents

Sonnet (claude-sonnet-4-6) pour :
- Demandes avec outils (bash, python, ssh)
- Generation de documents
- Code complexe

Opus (claude-opus-4-6) pour :
- Raisonnement complexe (si plan le permet)
- Taches multi-etapes critiques

### Implementation recommandee
1. Pre-classification avec Haiku (max_tokens=30, timeout=15s) : "simple" | "complex"
2. Route vers le modele optimal selon classification + plan ceiling
3. Si Haiku echec → fallback sur ceiling du plan directement

### Mode Geek
- Model bar : affiche `"clawbot-core · haiku"` ou `"clawbot-core · sonnet"`
- 3 boutons model : Haiku / Sonnet / Opus (disabled si au-dessus du ceiling)
- Forcing model : le frontend envoie `"model": "claude-opus-4-6"` → cloud verifie ceiling

### Nouveaux plans (a migrer — voir pricing-brainstorm.md)
Le modele de plans va evoluer. Le champ `model_ceiling` dans config.py
doit rester la source de verite — ne jamais hardcoder les modeles dans le frontend.
