# ClawBot — Brainstorm Pricing (2026-03-09)

## Vision

ClawBot est au-dessus de Claude Code en termes de valeur : plug & play, zero setup, agregation + management d'agents. Le prix reflete ca. L'axe de valeur c'est "une vie plus simple", pas des tokens ou des modeles.

## Principes actes

### Modele telecom "illimite degrade"
- TOUT est illimite — on ne coupe JAMAIS
- Au-dela du quota : on throttle la VITESSE (latence ajoutee), JAMAIS la qualite
- "Ca marche mais c'est trop long" → l'utilisateur monte de plan naturellement
- Comme la 4G qui passe en 2G apres le quota data

### Escalier naturel
- L'utilisateur monte tout seul s'il le produit est bon
- Exemple reel (Claude Code) : gratuit → 20 → 80 → 200 en 2 semaines
- Chaque palier debloque de la vitesse + des agents + des outils
- On deduit le prorata au jour lors d'un upgrade

### Add-on agent : 2.90€/mois
- Levier d'upsell naturel
- Le pricing est calibre pour que le plan superieur soit TOUJOURS plus interessant que l'achat d'agents a l'unite
- Exemples :
  - Free + 3 agents = 3 × 2.90 = 8.70€ → Starter a 7.99€ est mieux
  - Starter + 7 agents = 7 × 2.90 = 20.30€ + 7.99 = 28.29€ → Plus a 29.99€ est mieux

### Hardware = porte d'entree
- Boitier a 29€ (prix public)
- 30€ de credit abo inclus = premier mois gratuit minimum
- Offres promo possibles a 15€ → on offre quand meme 30€ de credit
- Le hardware est DECOUPLE de l'abo : autant de boitiers que tu veux, un seul abo
- Deux versions : SmartPi (sans ecran, acrylique) / SmartPad (ecran tactile capacitif)

### Un utilisateur = un boitier
- Chaque adulte a son boitier physique
- Les enfants partagent le boitier parent (mode Safe, session protegee)
- Nombre de boitiers illimite par compte — on ne facture pas au nombre de boitiers

## Deux gammes

### Onglet "Perso" (individus, familles)
- Vision : "Ca simplifie ma vie"
- Cible : mere de famille (consomme quasi rien, requetes Haiku legeres), utilisateur quotidien, geek

| Plan | Prix | Agents inclus | Vitesse | Modeles | Outils |
|------|------|--------------|---------|---------|--------|
| Free | 0€ | 1 | Lent (throttle fort) | Haiku | Base (chat, fichiers) |
| Starter | ~7.99€ | 3 | Normal | Haiku + Sonnet | Base |
| Plus | ~29.99€ | 10 | Rapide | Haiku + Sonnet | Base + web search |
| Geek | ~80€ | 15 | Rapide+ | Tous | Tous + mode Geek |

### Onglet "Pro" (entreprises)
- Vision : "Ca securise et accelere mon business"
- Differenciateurs Pro :
  - Credential vault garanti (securite des donnees)
  - Options RGPD / modeles francais (cas par cas)
  - Outils avances : SSH, API, MCP, multi-boitiers orchestres
  - Support et SLA sur paliers hauts

| Plan | Prix | Agents inclus | Vitesse | Modeles | Outils |
|------|------|--------------|---------|---------|--------|
| Pro Starter | ~29-39€ | 5 | Rapide | Tous | Pro tools (SSH, API, MCP) |
| Pro | ~189€ | 15 | Prioritaire | Tous | Tous + support |
| Pro+ | ~300€ | 30 | Prioritaire+ | Tous | Tous + multi-user |
| Business | 500€+ | Illimite | Max | Tous | Tous + team + SLA |

### Le Pro qui "triche"
- Un Pro peut commencer sur Perso a 7.99€ pour tester
- Il consomme vite → throttle → pousse vers 30€
- A 30€, l'onglet Pro montre plus d'outils pour le meme prix
- Le switch Perso 30€ → Pro 30€ est lateral : meme prix, plus de fonctions

## Mecaniques

### Throttle progressif
- 80% quota : routing vers modeles legers meme si plan autorise plus
- 95% quota : delai progressif entre reponses + bandeau UpsellBanner
- 100% quota : service continue, mode degrade (Haiku, latence augmentee)
- JAMAIS de coupure

### Upgrade prorata
- Upgrade en cours de mois → deduction prorata jours deja payes
- Prelevement mensuel au jour anniversaire
- Transparent pour l'utilisateur

### Credit hardware
- Prix boitier deduit sous forme de mois gratuits
- Exemple : boitier 29€ → ~1 mois de Starter offert (ou ~4 mois de Free equivalent)
- Calcul transparent affiche a l'utilisateur

## Points ouverts (post-MVP / a brainstormer)

- [ ] Prix exacts definitifs (7.99 vs 8.99, 189 vs 199 — tuning go-to-market)
- [ ] Nombre de sieges Business et pricing Team
- [ ] Modele collaborateur : plan perso + pool tokens patron
- [ ] Options RGPD / modeles francais specifiques
- [ ] Hardware upgrades (cles USB 512Go, RAID, stockage) — pricing decouple
- [ ] Interconnexion boitiers Pro <-> Perso collaborateurs
- [ ] Gap de prix entre Perso Plus (29.99€) et Pro Starter (29-39€) — eviter confusion
- [ ] Quotas tokens exacts par palier
- [ ] Store agents : agents gratuits vs agents payants dans le marketplace

## Impact sur Epic 4 (Abonnement & Tokens)

Les stories Epic 4 doivent implementer les MECANIQUES, pas les prix exacts :
1. Schema DB avec plans configurables (table Plan avec prix, slots, quotas, gamme)
2. Migration PostgreSQL (prerequis scaling)
3. Throttle progressif vitesse (pas qualite)
4. Add-on agents avec logique coherence prix
5. Credit hardware en mois d'abo
6. Upgrade prorata au jour
7. Deux gammes Perso/Pro en frontend (onglets)
8. Jauge douce "ce mois" (pas compteur tokens)
