# Story 1.2 : Affichage QR Code & page d'inscription

**Epic :** 1 — Onboarding Turnkey — "Brancher, scanner, c'est pret"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** ClawBot-OS (wizard), clawbot-cloud (API provision/activate), openjarvis.io (page /setup)

---

## User Story

As a **nouvel utilisateur**,
I want **scanner un QR code avec mon telephone pour creer mon compte ou lier mon appareil**,
So that **je puisse commencer a utiliser ClawBot sans configuration manuelle**.

---

## Acceptance Criteria

**Given** le WiFi est connecte
**When** le SmartPad affiche le QR code
**Then** le QR encode l'URL `openjarvis.io/setup?mac=XXX` (MAC du boitier sans colons, uppercase)
**And** l'URL est affichee en texte sous le QR (fallback si scan echoue)

**Given** l'utilisateur scanne le QR avec son telephone
**When** la page openjarvis.io/setup s'ouvre
**Then** le MAC du boitier est conserve cote serveur pendant la session d'inscription

**Given** l'utilisateur a deja un compte
**When** il se connecte sur la page
**Then** le systeme propose "Voulez-vous lier cet appareil a votre compte ?"
**And** un clic sur "Oui" associe le MAC au compte

**Given** l'utilisateur n'a pas de compte
**When** il remplit le formulaire (email + mot de passe)
**Then** le compte est cree et le systeme propose "Voulez-vous lier cet appareil ?"
**And** le MAC est associe automatiquement apres confirmation

---

## Technical Notes

### MAC computation
- MAC propre : uppercase, sans colons → ex `0281662AA2C9`
- `id_long = HMAC-SHA256(key="YUMI", msg=mac_clean)` → 64 hex uppercase
- `device_code = id_long[:4]-id_long[4:8]-id_long[8:12]` (XXXX-XXXX-XXXX)

### URL d'activation
- Format : `https://openjarvis.io/activate?mac={MAC_CLEAN}`
- Afficher le device_code en texte lisible sous le QR

### Endpoints cloud
- `POST /v1/auth/register` — creer compte
- `POST /v1/auth/login` — login JWT (72h)
- `POST /v1/activate` (JWT) — lier device au compte
- `GET /v1/provision` — fetch config device

### Polling device
- Le SmartPad doit poller `/tmp/clawbot-activated` apres affichage QR
- quand `clawbot-cloud.service` recoit la config push → ecrit `/tmp/clawbot-activated`
- Wizard detecte le fichier → passe a l'ecran suivant

### Page openjarvis.io/setup
- Page separee de `/activate` existante
- Doit gerer les deux cas : nouveau compte + liaison, compte existant + liaison
- Mobile-first (l'utilisateur est sur son telephone)
- Design : dark theme, responsive
