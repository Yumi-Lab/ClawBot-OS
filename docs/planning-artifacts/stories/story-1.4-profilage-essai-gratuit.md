# Story 1.4 : Profilage rapide & activation essai gratuit

**Epic :** 1 — Onboarding Turnkey — "Brancher, scanner, c'est pret"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** clawbot-cloud (plans, User model), openjarvis.io (page /setup)

---

## User Story

As a **nouvel utilisateur**,
I want **repondre a 3 questions simples sur mon usage et recevoir un essai gratuit genereux**,
So that **je puisse commencer immediatement sans payer ni choisir un plan**.

---

## Acceptance Criteria

**Given** le device est lie au compte
**When** la page de profilage s'affiche
**Then** 3 questions courtes sont posees : "Pourquoi ClawBot ?" (pro / famille / pro+perso / perso / maker)
**And** les reponses identifient le profil utilisateur (stocke en DB)

**Given** le profilage est termine
**When** l'utilisateur valide
**Then** un essai gratuit d'1 mois minimum est active avec acces complet
**And** le routing LLM intelligent optimise les couts (Haiku pour le simple, Sonnet/Opus si necessaire)
**And** le message affiche est : "Decouvrez votre essai gratuit d'1 mois. Amusez-vous."
**And** aucun paiement n'est demande

---

## Technical Notes

### Modele de plans (a implementer — voir pricing-brainstorm.md)
Plans actuels en DB (legacy) : Free / Particulier / Pro
Nouveau modele acte (a migrer) : voir `docs/planning-artifacts/pricing-brainstorm.md`

- Essai gratuit = plan "trial" avec acces complet pendant 30j
- Profile utilisateur : colonne `profile` sur User (pro / famille / maker / perso)
- Routing LLM : `model_ceiling` dans config.py (pas `model`)

### config.py actuel
```python
PLAN_LIMITS = {
    "free":        {"tokens_per_day": 10_000,    "model_ceiling": "claude-haiku-4-5-20251001"},
    "particulier": {"tokens_per_day": 200_000,   "model_ceiling": "claude-sonnet-4-6"},
    "pro":         {"tokens_per_day": 2_000_000, "model_ceiling": "claude-opus-4-6"},
}
```

### Trial plan a ajouter
- `"trial"` : `tokens_per_day: 200_000`, `model_ceiling: "claude-sonnet-4-6"`, expire 30j
- Champ DB : `trial_expires_at` sur User, ou `plan_expires_at`

### Profilage UX
- 3 questions maximum, visual picker (icones, pas de listes)
- Profils : Pro (mallette), Famille (maison), Maker (outils)
- Zero jargon technique dans les questions
- La selection du profil adapte les guided prompts de la Story 1.5

### Routing post-profil
- Pro → dashboard avec suggestion "Genere un devis"
- Famille → dashboard avec suggestion "Planifie les repas"
- Maker → dashboard direct, pas de suggestion
