# Focus Pebbles

A field-book style to-do app: tasks with deadlines and importance, a monthly calendar,
weekly revision goals per module, a focus timer, badges with your own rewards, and a climber game.

It is a single-page web app that installs to your phone or desktop home screen and works offline.
Your data stays on each device; use **Backup → Export / Import** to move it between devices.

## Files
- `index.html` — the whole app
- `manifest.webmanifest`, `icons/` — what makes it installable
- `sw.js` — offline support (bump `VERSION` in it after changing `index.html`)
- `tools/serve.ps1` — run it on this computer at http://localhost:8765
- `tools/make-icons.ps1` — redraws the PNG icons
