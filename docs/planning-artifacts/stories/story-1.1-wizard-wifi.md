# Story 1.1 : Wizard WiFi sur SmartPad

**Epic :** 1 — Onboarding Turnkey — "Brancher, scanner, c'est pret"
**Status :** [ ] To Do
**Priority :** MVP
**Repos :** ClawBot-OS (firstboot wizard), clawbot-core (status-api)

---

## User Story

As a **nouvel utilisateur**,
I want **connecter mon boitier au WiFi au premier demarrage**,
So that **le boitier puisse acceder au cloud et afficher le QR code**.

---

## Acceptance Criteria

**Given** le boitier est branche pour la premiere fois
**When** le firstboot demarre sur le SmartPad
**Then** la liste des reseaux WiFi disponibles s'affiche avec la force du signal
**And** l'utilisateur peut saisir le mot de passe et se connecter

**Given** la connexion WiFi echoue
**When** l'utilisateur voit le message d'erreur
**Then** il peut reessayer avec un autre mot de passe ou choisir un autre reseau
**And** un fallback Ethernet est propose si disponible

**Given** la connexion WiFi reussit
**When** le boitier obtient une IP
**Then** le SmartPad passe automatiquement a l'ecran QR code

---

## Technical Notes

### Contexte existant
- Le wizard firstboot tourne sous `clawbot-firstboot.service` (systemd oneshot)
- Condition de lancement : `ConditionPathExists=/.firstboot_clawbot`
- Le wizard utilise cage + Chromium -> wizard :8099
- Fichier de config reseau : `/boot/network_config.txt` (parse par `network-configurator.service`)
- WiFi watchdog : `wifi-watchdog.timer` + `wifi-watchdog.sh` (ping 8.8.8.8, nmcli reconnect)

### Wizard firstboot path
- `/src/modules/clawbot_wizard/` dans ClawBot-OS
- Service : `clawbot-firstboot.service`
- Apres activation : `rm /.firstboot_clawbot` -> start `clawbot-kiosk.service`

### Display SmartPad
- Plymouth rotation 180° au build (mogrify)
- `fbcon=rotate:2 video=DSI-1:rotate=180` dans armbianEnv.txt

### Reseaux disponibles
- `nmcli dev wifi list` pour scanner les reseaux
- `nmcli dev wifi connect <SSID> password <PWD>` pour se connecter

### UX
- Design direction Tesla : fond #0a0a0a, Inter font
- Pas de jargon technique — "Connexion au reseau" pas "SSID"
- Feedback immediat : spinner pendant la connexion, check vert si OK
