# Lohndruckerei Admin-Designsystem

Gemeinsame Gestaltungsregeln für die **Administration (Backend)** aller Shopware-6.7-Plugins der
Lohndruckerei: LieferLotse, Mensura, Auftragsverteilung, Druckdaten-Freigabe, Connectoren und alle
weiteren.

Zweck: Mitarbeiter finden in jedem Plugin dasselbe Aussehen und dieselbe Bedienung vor.

- **Mockup der drei Richtungen (klickbar):** https://claude.ai/artifact/6j95Mxyy6QteW1cdHAixT9
- **Referenz-Umsetzungen:** `sw6-lieferlotse` (Präfix `ld-`), `sw6-mensura` (Präfix `lm-`)

> **Stand der Designentscheidung:** offen. Drei Richtungen sind im Praxistest umschaltbar:
> **A · Hafen** (nah am Shopware-Standard), **B · Druckbogen** (Petrol + CMYK, *empfohlen,
> Standard*), **C · Kompass** (Kennzahlen, Kacheln, Seitennavigation). Bis zur Entscheidung baut
> jedes Plugin alle drei Varianten und den Schalter „Design A | B | C“ ein. Nach der Entscheidung
> fallen die beiden anderen Varianten und der Schalter weg; dieses Dokument wird dann auf eine
> Richtung reduziert.

---

## 1. Bereitstellung: zentrale Vorlage, Kopie je Plugin

Entschieden am 07.11.2026: **Kein Basis-Plugin.** Dieses Projekt ist die zentrale Quelle für das
„Lohndruckerei“-Backend-Design: Regeln (diese Datei) und gemeinsame Admin-Bausteine (`vorlage/`).
Jedes Plugin bekommt eine **generierte Kopie** und läuft ohne die anderen Plugins.

```
ld-admin-design/
├── DESIGN.md        Regeln (diese Datei)
├── VERSION          Version der Vorlage
├── plugins.conf     Plugins, Präfix, Plugin-Name, angebunden ja/nein
├── sync.sh          überträgt die Vorlage in die Plugins
└── vorlage/         index.js (Store, Mixin, Registrierung), constants.js, design.scss,
                     component/{design-switch,status,chip,transport-chip,tabs}, snippet/
```

- **Ziel im Plugin:** `src/Resources/app/administration/src/ld-admin-design/` – generiert, jede
  Datei trägt den Kopf „GENERIERT … nicht hier ändern“. Einbinden in `main.js`:
  `import './ld-admin-design';` (bringt auch die eigenen Snippets mit).
- **Änderungen nur hier:** in `vorlage/` ändern, `VERSION` erhöhen, committen, dann
  `./sync.sh all --build` (alle angebundenen Plugins + Admin-Build), in jedem Plugin im Shop prüfen
  und dort committen. `./sync.sh all --check` zeigt, welches Plugin veraltet ist.
- **Platzhalter in der Vorlage:** `__P__` = Präfix (`ld`, `lm` …), `__PLUGIN__` = technischer
  Plugin-Name, `__KEY__` = Schlüssel für `user_config`.
- **Fachliches bleibt im Plugin:** Lieferantenstatus, Seitenlayouts (`ld-supplier-list__content`,
  `lm-areas` …) und plugin-eigene Bausteine gehören in das Plugin, nicht in die Vorlage. Was zwei
  Plugins brauchen, wandert in die Vorlage.
- **Anbinden eines Plugins (einmalig, je Plugin abstimmen):** eigenen `design/`-Ordner entfernen,
  `import './ld-admin-design'` statt `import './design'`, Komponenten auf die Vorlage umstellen
  (z. B. `ld-transport-chip` jetzt über Kategorie-Farben), plugin-spezifische Styles ins Plugin
  verschieben, in `plugins.conf` auf `ja` setzen, `./sync.sh <name> --build`, testen. `sync.sh`
  bricht ab, solange der alte Store noch registriert ist.
- In der `CLAUDE.md` jedes angebundenen Plugins steht: „Admin-Design kommt aus
  ~/projekte/sw6-entwicklung-lohndruckerei/ld-admin-design – dort ändern, nicht lokal.“

Damit sich Plugins im Admin nicht gegenseitig überschreiben (Komponenten, Stores, Mixins und Styles
sind in Shopware global), gilt:

| Was | Regel | LieferLotse | Mensura |
|---|---|---|---|
| Präfix (Komponenten, CSS-Klassen, CSS-Variablen) | eigenes Kürzel je Plugin, 2 Buchstaben | `ld-` *(historisch)* | `lm-` |
| Design-Store | `<präfix>Design` | `ldDesign` | `lmDesign` |
| Mixin | `<präfix>-design` → `<präfix>Design`, `<präfix>DesignClass` | `ld-design` | `lm-design` |
| Standard für alle | Plugin-Konfiguration `<Plugin>.config.adminDesign` (`a`/`b`/`c`, Standard `b`) | `LdLieferLotse.config.adminDesign` | `LdMensura.config.adminDesign` |
| Wahl je Benutzer | `user_config`-Schlüssel `ld-<plugin>.admin-design`, Wert `{ design }` | `ld-lieferlotse.admin-design` | `ld-mensura.admin-design` |
| Snippets | `<präfix>-design.*` | `ld-design.*` | `lm-design.*` |

- **Neue Plugins wählen ein freies Kürzel** und tragen es hier ein. Das Kürzel `ld-` ist von
  LieferLotse belegt, obwohl es eigentlich die ganze Familie meint. Eine Umbenennung auf `ll-` ist
  möglich, aber nur in Absprache mit der LieferLotse-Entwicklung.
- Belegte Kürzel: `ld-` LieferLotse, `lm-` Mensura, `lv-` Vectura (Versand, Arbeitsname). Vorschläge: `la-` Auftragsverteilung,
  `lf-` Druckdaten-Freigabe, `lc-` Connectoren.
- Alle Regeln hängen an `.<präfix>-design` bzw. `.<präfix>-design--{a|b|c}` am Wurzelelement der
  eigenen Seite oder Karte. **Shopware-Klassen (`sw-*`, `mt-*`) werden nicht global überschrieben**,
  sondern nur innerhalb des eigenen Wurzelelements (z. B. leere Zustände in Design B).
- Neues Plugin: Zeile in `plugins.conf` ergänzen und `./sync.sh <name>` ausführen – nicht von
  Hand kopieren.

## 2. Grundsätze

1. **Shopware zuerst.** Buttons, Links, Formularfelder, Fokus, Modals, Smart-Bar und Datenraster
   bleiben Meteor-Standard (`mt-*`, `sw-*`), Primäraktionen blau
   (`--color-interaction-primary-default`). Eigene Farben zeigen nur Zugehörigkeit und Bedeutung.
2. **Markenfarbe = Lohndruckerei.** Modulfarbe, Kopfkarte, aktiver Reiter, Icon-Kacheln.
3. **Kategorie-Farben sind fest.** Eine Kategorie (z. B. Übertragungsweg) hat in allen Plugins
   dieselbe Farbe.
4. **Status nie nur über Farbe.** Immer Wort + Icon (A, B) bzw. Wort + Farbpunkt (C).
5. **Jeder leere Bereich erklärt sich selbst.** Icon, ein Satz, ein Button.
6. **Jedes Feld hat Hilfe.** Hilfetext mit Praxisbeispiel; Erklärkarten bei komplexen Bereichen.
7. **Rechte sichtbar machen.** Was der Benutzer nicht darf, wird ausgeblendet oder deaktiviert mit
   Tooltip „Keine Berechtigung …“ – nie eine Fehlermeldung nach dem Klick.

## 3. Farb-Tokens

Alle Tokens als CSS-Variablen am Wurzelelement, Namen mit Plugin-Präfix (hier `--p-` geschrieben;
in Mensura `--lm-`, in LieferLotse `--ld-`).

### Marke und Akzent je Richtung

| Token | A · Hafen | B · Druckbogen | C · Kompass | Verwendung |
|---|---|---|---|---|
| `--p-brand` | `#57D9A3` | `#0B6E79` Petrol | `#243758` Marine | Flächen, Balken, aktiver Reiter (Linie), Schalter |
| `--p-brand-ink` | `#0E7A52` | `#0B6E79` | `#243758` | Text und Icons in Markenfarbe (lesbar auf Weiß) |
| `--p-accent` | `#0870FF` | `#E5007E` Magenta | `#FF8A00` | sparsam: aktive Kennzahl, Hover auf Kacheln, vertikale Navigation |
| Modulfarbe (`color` in `Module.register`) | `#0B6E79` | `#0B6E79` | `#0B6E79` | fest, unabhängig vom Schalter |

Getönte Flächen werden aus der Markenfarbe gemischt, nicht als eigener Wert gepflegt:
`color-mix(in srgb, var(--p-brand) 14%, transparent)`.

### Kategorie-Farben (c1–c4)

Vier Farben für Kategorien wie Übertragungswege, Bereiche oder Produktgruppen. In B sind es die
Druckfarben (CMYK).

| Token | A | B | C |
|---|---|---|---|
| `--p-c1` | `#0870FF` | `#009FE3` Cyan | `#2F80ED` |
| `--p-c2` | `#633BC6` | `#E5007E` Magenta | `#8E44AD` |
| `--p-c3` | `#0F9D8F` | `#E0A800` Gelb | `#16A085` |
| `--p-c4` | `#D97706` | `#2B2B33` Key | `#E67E22` |

Feste Zuordnung **Übertragungswege** (in allen Plugins gleich):

| Übertragungsweg | Farbe | Icon |
|---|---|---|
| E-Mail | c1 (Cyan) | `regular-envelope` |
| FTP, SFTP | c2 (Magenta) | `regular-server`, `regular-lock` |
| B2B-Portal / manuell | c3 (Gelb) | `regular-globe` |
| REST-API, SOAP, Webhook | c4 (Key) | `regular-code`, `regular-code`, `regular-plug` |

> Hinweis: In LieferLotse sind die Übertragungswege heute als `--ld-t-<transport>` hinterlegt, in A
> und C liegt „Portal“ dort auf der 4. und API auf der 3. Farbe. Bei der Vereinheitlichung gilt die
> Tabelle oben.

Gelb (`#E0A800`) nie als Textfarbe auf Weiß: Text in getönten Chips wird mit Dunkel gemischt
(`color-mix(in srgb, var(--p-c3) 72%, #1c1c1c)`).

### Status

| Status | Schlüssel | Text | Hintergrund | Punkt (C) | Icon |
|---|---|---|---|---|---|
| Aktiv / OK / Verbunden | `ok` | `#14802E` | `#E1FFE0` | `#36D046` | `regular-checkmark-s` |
| Warnung / Prüfen / Unvollständig | `warn` | `#975A00` | `#FFF3E3` | `#FBAF18` | `regular-exclamation-triangle` |
| Fehler | `err` | `#C20017` | `#FFF2F0` | `#E2262A` | `regular-times-circle` |
| Inaktiv / Aus | `off` | `#696A6E` | `#EEF0F4` | Grau (`text-tertiary`) | `regular-ban` |

Als Tokens `--p-ok`, `--p-ok-bg`, `--p-warn`, … am Wurzelelement `.p-design`. Sie entsprechen den
Meteor-Statusfarben; wer Meteor-Tokens direkt nutzen möchte, nimmt
`--color-text-positive-default` / `--color-background-positive-default` usw. (`attention`,
`critical`).

### Neutrale Farben: nur Meteor-Tokens

| Zweck | Meteor-Token | Rückfallwert |
|---|---|---|
| Text | `--color-text-primary-default` | `#1C1C1C` |
| Text schwächer | `--color-text-secondary-default` | `#52667A` |
| Text Hinweis | `--color-text-tertiary-default` | `#8A97A6` |
| Rahmen | `--color-border-primary-default` | `#D1D9E0` |
| Fläche (Karte) | `--color-elevation-surface-raised` | `#FFFFFF` |
| Fläche vertieft | `--color-background-tertiary-default` | `#F0F2F5` |

`--color-elevation-surface-sunken` gibt es in Shopware 6.7.2 **nicht**; LieferLotse nutzt es mit
Rückfallwert. Neue Plugins nehmen `--color-background-tertiary-default`.

## 4. Typografie

Schrift ist die Admin-Schrift (Inter, über Meteor). Keine eigenen Schriften.

| Element | Größe | Gewicht | Hinweis |
|---|---|---|---|
| Titel der Kopfkarte | 18 px | 600 | |
| Kartentitel | Meteor-Standard (`mt-card` `title`) | | |
| Fließtext, Reiter | 14 px | 400 / 500, aktiv 600 | |
| Meta-Zeile (Nummer, Ort …) | 13 px | 400 | `text-secondary` |
| Chips, Status, Hinweise | 12 px | 600 | |
| Gruppenüberschrift (vertikale Navigation) | 11 px | 600 | Großbuchstaben, Sperrung `.08em`, `text-tertiary` |
| Kennzahl | 22 px (Kachel) / 16 px (Kopfkarte) | 700 / 600 | `font-variant-numeric: tabular-nums` |

Zahlen in Tabellen und Kennzahlen immer mit `tabular-nums`. Beträge netto, mit Währung, rechtsbündig.

## 5. Abstände, Radien, Rahmen

- **Raster 4 px.** Übliche Werte: 4, 8, 12, 16, 20, 24.
- Seiteninhalt: 24 px Rand links/rechts für eigene Elemente (Filter, Kennzahlen, Kacheln) über
  randlosen Listen.
- Karten- und Kachel-Innenabstand 16 px (Kopfkarte 16 × 20 px); Abstand zwischen Karten 24 px,
  zwischen Kacheln 12–14 px.
- Radien: Karten/Kacheln 8 px, Icon-Kachel 8 px (groß 10 px), Schalter 6 px, Chips 3–5 px,
  Status-Pill und Filter 99 px.
- Rahmen 1 px `border-primary`; Hervorhebung über Markenfarbe, nicht über Schatten
  (Ausnahme: aktive Kennzahl, 2 px Akzent-Schein).

## 6. Icons (Meteor Icon Kit)

Nur Icons aus dem Meteor Icon Kit: `<mt-icon name="regular-…" size="16px" />`. Alle unten
genannten Namen sind in Shopware 6.7.2 vorhanden (geprüft am 07.11.2026).

**Größen:** 16 px in Reitern und Kartentiteln · 12 px in Chips · 11 px in Status · 18–24 px in
Icon-Kacheln · 32 px in leeren Zuständen.

| Begriff | Icon | Begriff | Icon |
|---|---|---|---|
| Lieferant | `regular-truck` | Schnittstellen | `regular-plug` |
| Stammdaten | `regular-file-text` | E-Mail | `regular-envelope` |
| Adresse | `regular-map-marker` | FTP | `regular-server` |
| Abholadresse / Lager | `regular-warehouse` | SFTP | `regular-lock` |
| Ansprechpartner | `regular-user` / `regular-users` | REST-API / SOAP | `regular-code` |
| Website | `regular-globe` | Webhook | `regular-plug` |
| B2B-Portal / Shop | `regular-storefront` | Austausch (REST) | `regular-exchange-s` |
| Produkte | `regular-products` | Bestellung senden | `regular-paper-plane` |
| Sendungsverfolgung | `regular-history` | Versandbestätigung empfangen | `regular-cloud-download` |
| Ordner / Austausch | `regular-folder-open` | Druckdaten senden | `regular-file-export` |
| Eingang / Ausgang | `regular-inbox` / `regular-upload` | Archiv | `regular-archive` |
| Zugangsdaten | `regular-key` | Verschlüsselt | `regular-shield` |
| Verbindung testen | `regular-play` | Läuft / Abrufen | `regular-sync` |
| Übersicht / Dashboard | `regular-dashboard` | Kennzahlen | `regular-chart-line` |
| Kalkulation / Preise | `regular-euro` | Druck | `regular-printer` |
| Bereiche, Ebenen | `regular-layer-group` | Format / Zuschnitt | `regular-crop` |
| Kacheln / Liste | `regular-view-grid` / `regular-list` | Filter / Suche | `regular-filter` / `regular-search` |
| Hilfe | `regular-question-circle` | Tipp | `regular-lightbulb` |
| Info | `regular-info-circle` | Einstellungen | `regular-cog` |
| Aktionsmenü | `regular-ellipsis-h-s` | Hinzufügen | `regular-plus-circle` |

Nicht vorhanden (nicht verwenden): `regular-calculator`, `regular-euro-sign`, `regular-print`,
`regular-palette`, `regular-grid`. Vor neuen Icons im Container prüfen:
`ls vendor/shopware/administration/Resources/app/administration/node_modules/@shopware-ag/meteor-icon-kit/icons/regular`.

## 7. Bausteine

Jeder Baustein: Zweck, Aufbau, Aussehen je Richtung. Komponentennamen mit Plugin-Präfix (`p-`).

### 7.1 Design-Schalter `p-design-switch`
In der Smart-Bar (`#smart-bar-actions`, vor „Speichern“). Segmentschalter „Design | A | B | C“,
Tooltip mit Namen der Richtung und „(Standard)“. Speichert je Benutzer in `user_config`; ohne
Speicherrecht bleibt die Umschaltung für die Sitzung bestehen. Entfällt nach der Entscheidung.

### 7.2 Status `p-status`
Props `state` (`ok`/`warn`/`err`/`off`) und `label` (Snippet, nie fest verdrahtet).
- **A:** eckiges Label (Radius 4 px), ohne Icon.
- **B:** Pill mit Icon und Wort.
- **C:** Farbpunkt 8 px + Wort, ohne Hintergrund.

### 7.3 Chip `p-chip` (Kategorie) und `p-transport-chip` (Übertragungsweg)
`<p-chip label="…" color="c1|c2|c3|c4" icon="regular-…" />` setzt `--p-t` auf die
Kategorie-Farbe; Icon 12 px + Bezeichnung. Mehrere Chips mit 4 px Abstand.
`<p-transport-chip transport="email" />` nimmt Farbe, Icon und Bezeichnung fest aus der Vorlage.
- **A:** grau hinterlegt, Icon in Kategorie-Farbe.
- **B:** getönt (13 %), 3 px Farbbalken links, Text dunkel gemischt.
- **C:** 8-px-Quadrat in Kategorie-Farbe + Text, ohne Icon.

### 7.4 Reiter / Navigation `p-tabs`
`items: [{ name, label, icon, count?, warn?, warnText?, group? }]`, Event `select`.
- **A:** Shopware-Standard `sw-tabs` (keine eigenen Reiter).
- **B:** horizontale Reiter mit Icon, Zähler-Pill und Warn-Icon; brechen um statt zu scrollen;
  aktiv = Linie in `--p-brand`, Text `--p-brand-ink`.
- **C:** vertikale Seitennavigation (230 px, sticky) mit Gruppenüberschriften, aktiv = getönter
  Akzent-Hintergrund; unter 1000 px Breite horizontal.

Reiter mit eigenen Routen (`ld.supplier.detail.base`, `.addresses`, …), damit Links direkt auf
einen Reiter zeigen. Zähler zeigen die Anzahl der Einträge; Warnung, wenn etwas Pflichtiges fehlt
(z. B. „Kein Bestellweg“).

**Admin-Menü:** Große Plugins erhalten einen eigenen Hauptmenüpunkt (`type: 'core'`, siehe
Mensura) mit Unterpunkten je Bereich; kleine Plugins hängen sich unter den passenden
Shopware-Bereich (LieferLotse unter Kataloge). Modulfarbe immer `#0B6E79`.

### 7.5 Kopfkarte `p-header` (Detailseiten)
Oben auf jeder Detailseite, unter der Smart-Bar:
Icon-Kachel 48 px · Titel (18 px) + Status · Meta-Zeile (Nummer, Ort, Kundennummer …) ·
rechts Chips oder Kennzahlen (`__stats`, Warnwert in `--p-warn`).
- **A:** keine Kopfkarte, Shopware-Standard (Titel in der Smart-Bar, Daten in Karten).
- **B:** Kopfkarte mit 4 px Markenbalken oben.
- **C:** Kopfkarte ohne Balken, mit Kennzahlen rechts; darunter Seitennavigation + Inhalt
  (`p-split`).

### 7.6 Icon-Kachel `p-sicon`
34 × 34 px (groß 48 px), Radius 8 px, getönte Markenfarbe, Icon in `--p-brand-ink`.
Inaktiv: `--p-off-bg`, Icon grau. Am Namen in Listen (`p-namecell`: Kachel + fetter Link + kleine
zweite Zeile), in Kacheln und in der Kopfkarte.

### 7.7 Listen, Filter, Kennzahlen, Kacheln
Die Liste selbst ist `sw-entity-listing` (randlos, Shopware-Standard). Darüber je Richtung:
- **A:** nur Liste, Suche in der Suchleiste.
- **B:** Filterchips (`p-filters` / `p-filter`): Pill mit Zahl, aktiv getönt in Markenfarbe.
  Typisch: „Alle 24 · Aktiv 20 · Ohne Bestellweg 3 · Inaktiv 1“.
- **C:** Kennzahl-Kacheln (`p-kpis`, 4 Spalten, unter 1000 px 2) als Filter; darunter Werkzeugleiste
  (`p-toolbar`) mit Umschalter Liste/Kacheln (`p-seg`, Icons `regular-list` / `regular-view-grid`)
  und Kachelansicht (`p-tiles`, min. 260 px je Kachel).

Spalten: Name (mit Icon-Kachel) zuerst, Status als Baustein, Kategorien als Chips, Zahlen rechts.
Inaktive Einträge bleiben sichtbar, Kacheln mit 65 % Deckkraft.

### 7.8 Leere Zustände
`sw-empty-state` (bzw. `mt-empty-state`) mit Icon 32 px, Titel „Noch keine …“, **ein** Satz, was
hierher gehört, und **ein** Button für die erste Aktion. In B ist das Icon in Markenfarbe
(nur innerhalb des eigenen Wurzelelements überschrieben). Optional Schrittfolge (gestrichelte
Kästchen 1 → 2 → 3, `p-empty-steps` / `p-empty-step`) für Bereiche, die eine Einrichtung brauchen.

Beispiel: „Noch keine Schnittstelle · Lege fest, wie Bestellungen zu diesem Lieferanten kommen,
z. B. per E-Mail oder SFTP. · [Schnittstelle hinzufügen]“.

### 7.9 Hilfetexte und Erklärungen
- **Jedes Feld:** `help-text` (Fragezeichen) mit einem Satz Erklärung **und Praxisbeispiel**
  („z. B. bestellung@lieferant.de“). Pflichtangaben über `required`, nicht im Text.
- **Unter dem Feld (`hint`):** Format- oder Folgehinweise („Wird an jede Bestellung angehängt“).
- **Ganze Bereiche:** `mt-banner variant="info"` oben im Reiter, schließbar, mit Icon
  `regular-lightbulb` oder `regular-info-circle`.
- **Warnung beim Speichern:** `mt-banner variant="attention"` bzw. Benachrichtigung, die sagt,
  was fehlt und wo („Kein aktiver Bestellweg – Reiter Schnittstellen“).
- **Fehlertexte** sagen, was los ist und was zu tun ist:
  „HTTP 401: API-Schlüssel abgelaufen. Neuen Schlüssel im Portal erzeugen und hier eintragen.“
- Buttons sagen, was passiert: „Verbindung testen“, „Schnittstelle hinzufügen“ – nicht „OK“.
- Assistenten (Wizard) für mehrstufige Einrichtungen in `sw-modal` mit Schrittanzeige.

### 7.10 Aktionsmenü
`sw-context-button` mit `sw-context-menu-item`: Bearbeiten zuerst, dann typische Aktionen,
Trennlinie, „Löschen“ (`variant="danger"`) zuletzt; Löschen fragt per `sw-modal` nach und nennt,
was mitgelöscht wird.

## 8. CSS- und Code-Regeln

- BEM mit Präfix: `p-<block>__<element>--<modifier>`; Zustände als `is--active`, `is--warn`,
  `is--inactive`, `is--off`.
- Gemeinsame Bausteine ohne Entitätsnamen (`p-status`, `p-chip`, `p-tabs`, `p-header`); Seiten
  und Karten mit Entitätsnamen (`ld-supplier-detail`, `lm-overview`).
- Komponenten setzen `<präfix>DesignClass` aus dem Mixin an ihr Wurzelelement.
- Varianten nur über `.p-design--a|b|c`-Selektoren und Tokens, nicht über `v-if` je Richtung –
  außer der Aufbau unterscheidet sich (Kopfkarte, Seitennavigation, Kacheln).
- Farben nie als Hex in Komponenten-SCSS, sondern als Token; neue Farben zuerst hier eintragen.
- Barrierefreiheit: Schalter mit `aria-pressed`, Reiter mit `aria-current`, Navigation mit
  `aria-label`; Tooltips ergänzen, ersetzen aber keinen sichtbaren Text.
- Texte immer als Snippet in **de-DE und en-GB**.

## 9. Checkliste für ein neues Plugin

1. Freies Präfix wählen, in Abschnitt 1 und in `plugins.conf` eintragen (angebunden `ja`).
2. `./sync.sh <name>` ausführen, in `main.js` `import './ld-admin-design';`, Konfigurationsfeld
   `adminDesign` anlegen (`config.xml`, Auswahl A/B/C, Standard B), in die `CLAUDE.md` des Plugins
   den Hinweis „Admin-Design kommt aus ~/projekte/sw6-entwicklung-lohndruckerei/ld-admin-design – dort ändern, nicht lokal“.
3. Modul mit Farbe `#0B6E79` und passendem Icon registrieren; Menüplatz nach 7.4.
4. Listenseite nach 7.7, Detailseite mit Kopfkarte und Reitern nach 7.4/7.5.
5. Leere Zustände, Hilfetexte und Fehlertexte nach 7.8/7.9 – für jedes Feld.
6. Rechte je Bereich (Shopware-Rollen); nicht erlaubte Aktionen ausblenden oder deaktivieren.
7. Im Shop in **allen drei Richtungen** prüfen, auch bei schmalem Fenster (unter 1000 px).

## 10. Frontend (Storefront) – nicht Teil dieses Systems

Dieses Designsystem gilt **nur für die Administration**. Anzeigen der Plugins im Frontend
(z. B. Konfigurator, Kalkulation, Druckdaten-Upload, Lieferhinweise) richten sich nach dem
Shopware-System-Design und nach dem **gesonderten Storefront-Theme der Lohndruckerei**, das
eigenständig entwickelt wird. Admin-Tokens und `p-`-Klassen werden im Frontend nicht verwendet.
Gemeinsam bleiben nur Begriffe, Icons (soweit im Theme verfügbar) und die Zuordnung
Kategorie → Farbe, sofern das Theme sie übernimmt.
