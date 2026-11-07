# Projekt: ld-admin-design („Lohndruckerei“-Backend-Design)

Zentrale Quelle für das Aussehen und die Bedienung der **Shopware-Administration** aller
Lohndruckerei-Plugins (LieferLotse, Mensura und alle weiteren). Ziel: Die Mitarbeiter finden in
jedem Plugin dasselbe Look-and-Feel vor, und die Bedienung bleibt intuitiv.

- Regeln: [DESIGN.md](DESIGN.md). Gemeinsame Admin-Bausteine: `vorlage/`.
- Es gibt kein Basis-Plugin. `./sync.sh` kopiert die Vorlage mit dem Präfix des jeweiligen Plugins
  nach `src/Resources/app/administration/src/ld-admin-design/` in jedes Plugin aus `plugins.conf`.
- Änderung am Design: `vorlage/` und DESIGN.md anpassen, `VERSION` erhöhen, committen,
  `./sync.sh all --build`, in jedem Plugin im Shop prüfen und im Plugin-Repo committen.
- Ein Plugin anbinden oder umstellen (eigenen `design/`-Ordner ablösen) nur nach Abstimmung mit
  dem Benutzer; in LieferLotse und Mensura wird parallel entwickelt.
- Gilt nur für das Backend. Das Frontend bekommt ein gesondertes Storefront-Theme (eigenes Projekt).
- Offene Entscheidung: Designrichtung A, B oder C. Ist sie gefallen, Vorlage und DESIGN.md auf eine
  Richtung reduzieren und den Schalter entfernen.
- Shell-Befehle in WSL über Skriptdateien ausführen (`wsl -d ubuntu -e bash …`). Nach Änderungen
  an `sync.sh` per Windows-Pfad das Ausführungsrecht prüfen (`chmod +x`).
- Texte auf Deutsch; Snippets in de-DE und en-GB.

## Git
- Repository: git@github.com:Lohndruckerei/sw6-backend-designsystem.git (Branch `main`)
- Zugriff über Deploy-Key `~/.ssh/backend_designsystem_deploy` (in `core.sshCommand` hinterlegt, ohne Passphrase)
- Nach jeder getesteten Änderung committen und pushen; nie force-pushen.
