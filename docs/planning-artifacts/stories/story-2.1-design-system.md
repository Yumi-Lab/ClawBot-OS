# Story 2.1 : Design System Foundation

**Epic :** 2 — Chat IA Unifie — "Tu parles, ca fait"
**Status :** [x] Done
**Priority :** MVP — SOCLE de toutes les autres stories
**Repos :** ClawbotCore-WebUI (dashboard), clawbot-cloud (pages statiques openjarvis.io)

---

## User Story

As a **developpeur**,
I want **un design system avec tokens CSS, composants de base et dual theme**,
So that **toutes les surfaces partagent une identite visuelle coherente et premium**.

---

## Acceptance Criteria

**Given** le fichier tokens.css est cree
**When** un composant l'importe
**Then** il a acces a la palette Tesla dark, la palette light, la typo Inter/JetBrains Mono, les espacements et les animations

**Given** le composant Spinner est implemente
**When** une action async est en cours
**Then** un cercle cyan anime s'affiche

**Given** le composant Panel est implemente
**When** un panel est rendu dans le dashboard
**Then** il a un titre, un contenu, et peut etre collapse

**Given** le composant Notification (toast) est implemente
**When** un evenement se produit
**Then** un toast apparait (succes/erreur/warning/info), stackable, auto-dismiss

**Given** html[data-theme] est bascule
**When** l'utilisateur change de theme
**Then** tous les composants s'adaptent (dark ou light) via les tokens CSS
**And** le light theme utilise --accent-light (#008b7a) au lieu de --accent (#00ffe0)

---

## Technical Notes

### Tokens CSS — Tesla Design Direction

```css
:root {
  /* Couleurs dark (defaut) */
  --bg-primary:    #0a0a0a;
  --bg-secondary:  #111111;
  --bg-card:       #1a1a1a;
  --bg-elevated:   #222222;
  --border:        #2a2a2a;
  --border-hover:  #444444;
  --accent:        #00ffe0;   /* cyan principal */
  --accent-dim:    #00ffe020; /* accent transparent */
  --text-primary:  #f5f5f5;
  --text-secondary: #888888;
  --text-muted:    #555555;
  --success:       #22c55e;
  --error:         #ef4444;
  --warning:       #f59e0b;
  --info:          #3b82f6;

  /* Typographie */
  --font-sans:  'Inter', system-ui, sans-serif;
  --font-mono:  'JetBrains Mono', 'Fira Code', monospace;
  --text-xs:    0.75rem;
  --text-sm:    0.875rem;
  --text-base:  1rem;
  --text-lg:    1.125rem;
  --text-xl:    1.25rem;

  /* Espacements */
  --space-1: 4px;  --space-2: 8px;  --space-3: 12px;
  --space-4: 16px; --space-6: 24px; --space-8: 32px;

  /* Radius */
  --radius-sm: 6px; --radius-md: 12px; --radius-lg: 16px; --radius-full: 9999px;

  /* Animations */
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
  --duration-fast: 150ms; --duration-normal: 250ms; --duration-slow: 400ms;

  /* Sidebar */
  --sidebar-open: 250px; --sidebar-collapsed: 50px;
}

/* Light theme */
[data-theme="light"] {
  --bg-primary:    #f5f5f5;
  --bg-secondary:  #ebebeb;
  --bg-card:       #ffffff;
  --bg-elevated:   #f0f0f0;
  --border:        #d4d4d4;
  --accent:        #008b7a;   /* accent-light */
  --text-primary:  #0a0a0a;
  --text-secondary: #555555;
  --text-muted:    #888888;
}
```

### Composants a creer (vanilla JS + CSS — pas de framework)

| Composant | Description |
|-----------|-------------|
| `Spinner` | Cercle cyan anime, 3 tailles (sm/md/lg) |
| `Panel` | Carte collapsible avec titre + contenu |
| `Toast` | Notification stackable, 4 types, auto-dismiss 4s |
| `Button` | Primary / Secondary / Ghost / Danger |
| `Input` | Text / Textarea avec focus ring cyan |
| `Badge` | Micro-pastille coloree (14px) |
| `Tooltip` | Apparait sur hover, 300ms delay |
| `Sidebar` | Repliable 250px → 50px icon rail, animation ease-out |
| `Modal` | Overlay avec focus trap |
| `Skeleton` | Placeholder anime pour les chargements |

### Convention fichiers
- `tokens.css` — variables uniquement, pas de classes
- `components.css` — classes des composants
- `animations.css` — keyframes
- Import dans index.html : `<link rel="stylesheet" href="/css/tokens.css">`

### Existant a preserver
- Dashboard actuel : `index.html` dans `/home/pi/clawbot-dashboard/`
- Colors actuelles : `#00ffe0` (cyan) → a garder comme accent
- Fonts actuelles : Outfit + JetBrains Mono → migrer vers Inter + JetBrains Mono
- Migration : remplacer progressivement, pas de cassure complete

### IMPORTANT
Cette story est le socle de tout l'Epic 2. Les stories 2.2 a 2.6 dependent des tokens CSS et composants definis ici. A implementer en premier.
