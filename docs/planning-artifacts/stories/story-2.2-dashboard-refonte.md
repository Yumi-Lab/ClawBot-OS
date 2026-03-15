# Story 2.2 : Refonte visuelle du dashboard

**Epic :** 2 — Chat IA Unifie — "Tu parles, ca fait"
**Status :** [x] Done
**Priority :** MVP
**Repos :** ClawbotCore-WebUI (index.html)
**Prerequis :** Story 2.1 (Design System Foundation)

---

## User Story

As a **utilisateur**,
I want **un dashboard premium, moderne et lisible**,
So that **l'experience soit agreable et inspire confiance**.

---

## Acceptance Criteria

**Given** le dashboard existant est refonde
**When** l'utilisateur ouvre le dashboard
**Then** le layout affiche une sidebar repliable (250px ouverte, 50px icon rail) + zone chat centrale
**And** la direction visuelle est Tesla : fond #0a0a0a, cards #1a1a1a, radius 12px, Inter font

**Given** la sidebar est en mode icon rail
**When** l'utilisateur survole un icone
**Then** un tooltip affiche le label
**And** les badges deviennent des micro-pastilles cyan (14px)
**And** l'animation de collapse est cubic-bezier fluide 250ms

**Given** le dashboard est charge
**When** le temps de chargement est mesure en LAN
**Then** il est <3s (NFR3)

**Given** prefers-reduced-motion est actif
**When** le dashboard s'affiche
**Then** toutes les animations decoratives sont desactivees

---

## Technical Notes

### Structure layout
```
+--sidebar (250px / 50px icon rail)--+--zone chat centrale--+
| Logo + user info                    | Zone chat (Story 2.3)|
| Nav items (icones + labels)         |                      |
| [collapse icon]                     |                      |
| Plan badge (bas de sidebar)         |                      |
+------------------------------------+----------------------+
```

### Sidebar items (9 panels existants)
- Chat (icone: message), Files (folder), Workspace (grid), Agents (robot)
- Logs (terminal), Monitor (activity), Services (server), Config (settings), Setup (wrench)

### Sidebar collapsed (icon rail)
- Largeur : 50px
- Icone centree, pas de label
- Tooltip sur hover (300ms delay, position right)
- Badge : micro-pastille 14px en haut a droite de l'icone (ex: notif count)
- Animation transition : `width var(--duration-normal) var(--ease-out)`

### Dashboard actuel (brownfield — ne pas casser)
- `index.html` : SPA ~2500 lignes, vanilla JS
- 9 panels existants : chat, files, workspace, agents, logs, monitor, services, config, setup
- Ne pas supprimer les fonctionnalites — refonte VISUELLE uniquement
- Sessions : GET /core/sessions (ne pas changer l'API)

### Performance
- Fonts : preload Inter depuis Google Fonts ou embarque
- CSS : un seul fichier tokens.css + components.css (pas de CSS-in-JS)
- Pas de build step : vanilla JS/CSS only (le Pi compile pas)

### Responsive (breakpoint 768px)
- Mobile : sidebar disparait → menu burger bottom nav
- Tablette : sidebar icon rail par defaut
- Desktop : sidebar ouverte par defaut

### Accessibilite
- `prefers-reduced-motion` : desactiver `transition`, `animation` dans un media query
- Focus visible sur tous les elements interactifs (outline cyan 2px)
- `aria-label` sur les icones quand pas de label visible
