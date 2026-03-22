# Story 1.3 : Auto-enregistrement device & association MAC

**Epic :** 1 — Onboarding Turnkey — "Brancher, scanner, c'est pret"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** clawbot-cloud (Device model, activation), ClawBot-OS (clawbot-cloud service)

---

## User Story

As a **systeme**,
I want **enregistrer automatiquement le boitier sur le cloud avec son MAC**,
So that **le device soit identifie et pret a etre lie a un compte utilisateur**.

---

## Acceptance Criteria

**Given** le boitier est connecte au WiFi
**When** il contacte le cloud pour la premiere fois
**Then** il s'enregistre avec son MAC (uppercase, sans colons)
**And** le cloud cree une entree Device en attente de liaison (user_id = NULL)

**Given** un utilisateur confirme "Lier cet appareil" sur openjarvis.io/setup
**When** le cloud recoit la confirmation
**Then** le Device est associe au User (user_id renseigne)
**And** le SmartPad detecte la liaison et passe a l'ecran suivant

**Given** le boitier est deja lie a un compte
**When** un autre utilisateur tente de le lier
**Then** le systeme refuse avec un message clair

---

## Technical Notes

### DB schema (cloud)
```sql
Device: id, device_id, mac, id_long, user_id, board, firmware, last_ip, last_seen_at, provisioned, core_status
ActivationToken: id, device_id, token, expires_at, used (TTL 30min)
```

### Endpoints cloud
- `POST /v1/heartbeat` (None) — telemetrie device, auto-cree le Device si nouveau
- `POST /v1/activate` (JWT) — lie le device au user_id du JWT
- `GET /v1/provision` (None) — fetch config pour le device (sub_key, model, base_url)

### clawbot-cloud service (device-side)
- Script `/usr/local/bin/clawbot-cloud`
- A chaque reconnect WebSocket → cloud push la config au device
- MAC normalise : uppercase, sans colons
- SSH paramiko pour deploiement : `look_for_keys=False, allow_agent=False`

### Polling activation (wizard)
- Wizard poll `/tmp/clawbot-activated` toutes les 2s
- `clawbot-cloud.service` ecrit ce fichier quand il recoit la config push du cloud
- Timeout suggestion : 10 min, puis afficher "Pas encore active ? Rescanner le QR"

### Convention MAC
- Toujours uppercase sans colons en DB
- Normaliser a l'entree : `mac.upper().replace(':', '')`
- MAC du Pi : `0281662AA2C9` (hostname: smartpi1)
