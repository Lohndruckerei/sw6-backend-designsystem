#!/usr/bin/env bash
# Überträgt die Vorlage (vorlage/) mit Präfix je Plugin in die Plugins.
#
#   ./sync.sh --list                 Plugins und Stand anzeigen
#   ./sync.sh <name>|all             übertragen (all = nur angebundene Plugins)
#   ./sync.sh <name>|all --check     nur prüfen, ob das Plugin aktuell ist (Exit 1 bei Abweichung)
#   ./sync.sh <name> --to <ordner>   in einen beliebigen Ordner rendern (Test)
#   ... --build                      danach Admin-Build, assets:install, cache:clear im Container
#
# Ziel im Plugin: src/Resources/app/administration/src/ld-admin-design/
# Einbinden im Plugin (main.js):  import './ld-admin-design';
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
CONF="$ROOT/plugins.conf"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
COMMIT="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo '-')"
TARGET_SUB="src/Resources/app/administration/src/ld-admin-design"
CONTAINER="${LD_CONTAINER:-shopware}"

die() { echo "Fehler: $*" >&2; exit 2; }

entries() { grep -vE '^\s*(#|$)' "$CONF"; }

field() { echo "$1" | cut -d'|' -f"$2" | sed 's/^ *//;s/ *$//'; }

expand_path() { local p="$1"; echo "${p/#\~/$HOME}"; }

render() { # render <prefix> <plugin> <key> <ziel>
    local prefix="$1" plugin="$2" key="$3" out="$4"
    [[ "$prefix" =~ ^[a-z]{2}$ ]] || die "Präfix '$prefix' muss aus 2 Kleinbuchstaben bestehen."
    rm -rf "$out"
    mkdir -p "$out"
    cp -r "$ROOT/vorlage/." "$out/"
    local header="GENERIERT aus ld-admin-design ${VERSION} (${COMMIT}) – nicht hier ändern, sondern in ~/projekte/ld-admin-design/vorlage und ./sync.sh ausführen."
    while IFS= read -r -d '' f; do
        sed -i -e "s/__PLUGIN__/${plugin}/g" -e "s/__KEY__/${key}/g" -e "s/__P__/${prefix}/g" "$f"
        case "$f" in
            *.js) sed -i "1i /* ${header} */" "$f" ;;
            *.scss) sed -i "1i // ${header}" "$f" ;;
        esac
    done < <(find "$out" -type f -print0)
    cat > "$out/README.md" <<EOF
# ld-admin-design (generiert)

${header}

Version: ${VERSION} · Stand: ${COMMIT} · Präfix: \`${prefix}-\` · Plugin: ${plugin}

Regeln und Bausteine: ~/projekte/ld-admin-design/DESIGN.md
EOF
    if grep -rq "__P__\|__PLUGIN__\|__KEY__" "$out"; then
        die "Platzhalter nicht vollständig ersetzt in $out"
    fi
}

collision_check() { # Store-ID darf im Plugin nur einmal registriert werden
    local src="$1" prefix="$2" target="$3"
    local hits
    hits="$(grep -rlE "id: *'${prefix}Design'|Store\.register\(\{[^}]*${prefix}Design" "$src" 2>/dev/null | grep -v "^${target}/" || true)"
    if [[ -n "$hits" ]]; then
        echo "Abbruch: Store '${prefix}Design' wird im Plugin bereits außerhalb von ld-admin-design registriert:" >&2
        echo "$hits" >&2
        echo "Erst den alten design/-Ordner entfernen (Umstellung), dann erneut ausführen." >&2
        exit 3
    fi
}

sync_one() { # sync_one <entry> <check> <to>
    local entry="$1" check="$2" to="$3"
    local name dir prefix plugin key
    name="$(field "$entry" 1)"; dir="$(expand_path "$(field "$entry" 2)")"
    prefix="$(field "$entry" 3)"; plugin="$(field "$entry" 4)"; key="$(field "$entry" 5)"

    local tmp; tmp="$(mktemp -d)"
    render "$prefix" "$plugin" "$key" "$tmp/out"

    if [[ -n "$to" ]]; then
        rm -rf "$to"; mkdir -p "$(dirname "$to")"; cp -r "$tmp/out" "$to"
        echo "$name: gerendert nach $to"
        rm -rf "$tmp"; return 0
    fi

    [[ -d "$dir/src" ]] || die "$name: Projektordner $dir nicht gefunden."
    local target="$dir/$TARGET_SUB"

    if [[ "$check" == 1 ]]; then
        # Kopfzeilen (Stand) beim Vergleich ignorieren
        if diff -r -q -I 'GENERIERT aus ld-admin-design' -I '^Version: ' "$tmp/out" "$target" >/dev/null 2>&1; then
            echo "$name: aktuell"
        else
            echo "$name: VERALTET (oder nicht angebunden)"; rm -rf "$tmp"; return 1
        fi
        rm -rf "$tmp"; return 0
    fi

    collision_check "$dir/src/Resources/app" "$prefix" "$target"
    rm -rf "$target"
    cp -r "$tmp/out" "$target"
    rm -rf "$tmp"
    echo "$name: übertragen nach $target (Version $VERSION, $COMMIT)"
}

build() {
    echo "Admin-Build im Container '$CONTAINER' …"
    docker exec "$CONTAINER" bash -c 'cd /var/www/html && ./bin/build-administration.sh && bin/console assets:install && bin/console cache:clear'
}

# ---------- Aufruf ----------
[[ $# -ge 1 ]] || { sed -n '2,12p' "$0"; exit 2; }

if [[ "$1" == "--list" ]]; then
    printf '%-14s %-6s %-16s %-10s %s\n' NAME PRÄFIX PLUGIN ANGEBUNDEN ORDNER
    while IFS= read -r e; do
        printf '%-14s %-6s %-16s %-10s %s\n' "$(field "$e" 1)" "$(field "$e" 3)-" "$(field "$e" 4)" "$(field "$e" 6)" "$(field "$e" 2)"
    done < <(entries)
    exit 0
fi

WHO="$1"; shift
CHECK=0; TO=""; BUILD=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --check) CHECK=1 ;;
        --to) TO="$2"; shift ;;
        --build) BUILD=1 ;;
        *) die "Unbekannte Option $1" ;;
    esac
    shift
done

RC=0
FOUND=0
while IFS= read -r e; do
    n="$(field "$e" 1)"
    if [[ "$WHO" == "all" ]]; then
        [[ "$(field "$e" 6)" == "ja" ]] || continue
    elif [[ "$WHO" != "$n" ]]; then
        continue
    fi
    FOUND=1
    sync_one "$e" "$CHECK" "$TO" || RC=1
done < <(entries)

[[ "$FOUND" == 1 ]] || { [[ "$WHO" == "all" ]] && echo "Noch kein Plugin angebunden (plugins.conf)." || die "Plugin '$WHO' nicht in plugins.conf."; }

if [[ "$BUILD" == 1 && "$CHECK" == 0 && -z "$TO" && "$FOUND" == 1 ]]; then
    build
fi

exit $RC
