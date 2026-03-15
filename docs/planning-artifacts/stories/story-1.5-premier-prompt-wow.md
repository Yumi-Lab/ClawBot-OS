# Story 1.5 : Premier prompt guide — effet wow

**Epic :** 1 — Onboarding Turnkey — "Brancher, scanner, c'est pret"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** ClawbotCore-WebUI (dashboard index.html)

---

## User Story

As a **nouvel utilisateur**,
I want **recevoir une suggestion de premiere demande adaptee a mon profil**,
So that **j'obtienne un resultat spectaculaire qui me donne envie de continuer**.

---

## Acceptance Criteria

**Given** le dashboard s'ouvre pour la premiere fois apres l'essai gratuit
**When** la zone de chat est vide
**Then** 3 suggestions de prompts sont affichees, adaptees au profil :
- Pro : "Genere-moi un modele de devis pour..."
- Famille : "Planifie les repas de la semaine avec..."
- Maker : acces direct, pas de suggestion

**Given** l'utilisateur clique sur une suggestion ou tape sa propre demande
**When** la reponse arrive en streaming
**Then** le resultat est concret et spectaculaire (document, plan, action)
**And** le tool trace simplifie montre l'IA au travail
**And** le temps total est <30s pour la premiere reponse

---

## Technical Notes

### Detection first-time
- Variable `isFirstSession` ou `sessionCount === 0` dans le dashboard
- Session stockee cote serveur → verifier si `sessions` est vide pour ce compte
- Apres le premier prompt envoye : masquer les suggestions definitivement

### Guided prompts par profil
- Profil stocke dans le JWT ou GET /v1/user/me (champ `profile`)
- Suggestions hardcodees par profil dans le dashboard (pas d'appel API)

### Performance cible
- Premier token en <5s via tunnel cloud (NFR1)
- Streaming token par token visible immediatement
- Tool trace anime pendant l'execution (Story 2.4)

### UX
- Suggestions : cartes cliquables avec icone + texte court
- Fond de carte : #1a1a1a, border #333, hover : border cyan #00ffe0
- Disparaissent en fade-out (300ms) quand l'utilisateur commence a taper
- Apres le premier prompt : suggestions ne reviennent jamais

### Prerequis
- Story 2.3 (zone de chat unifiee) doit etre implementee
- Story 2.4 (tool trace simplifie) doit etre implementee
