# Projekt: ld-admin-design (Admin-Designrichtlinien der Lohndruckerei)

Dieses Projekt enthält **nur Regeln, keinen Plugin-Code**: die verbindlichen Gestaltungs- und
Bedienrichtlinien für die Shopware-Administration aller Lohndruckerei-Plugins.
Ziel: Die Mitarbeiter finden in jedem Plugin dasselbe Aussehen und dieselbe Bedienung vor, und die
Bedienung bleibt intuitiv.

- Maßgeblich ist [DESIGN.md](DESIGN.md).
- Gilt nur für das Backend. Das Frontend bekommt ein gesondertes Storefront-Theme (eigenes Projekt).
- Es gibt bewusst kein Basis-Plugin und kein gemeinsames Code-Paket. Jedes Plugin setzt die Regeln
  eigenständig um, mit eigenem Präfix (siehe DESIGN.md, Abschnitt 1).
- Änderungen an den Richtlinien hier pflegen und kurz begründen. Die Plugins werden danach in ihren
  eigenen Projekten nachgezogen, nicht von hier aus.
- Offene Entscheidung: Designrichtung A, B oder C (Praxistest in LieferLotse und Mensura). Ist sie
  gefallen, DESIGN.md auf eine Richtung reduzieren.
- Texte auf Deutsch; Snippet-Beispiele in de-DE und en-GB.
