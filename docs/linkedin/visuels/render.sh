#!/usr/bin/env bash
# ==========================================================================
# Rend les gabarits HTML en PNG prêts à poster sur LinkedIn.
#
#   bash render.sh                 → rend les quatre gabarits
#   bash render.sh carte-chiffre   → rend un seul gabarit
#
# Sortie : docs/linkedin/visuels/exports/<gabarit>.png
# Format : 2400 × 3000 px (le 1200 × 1500 du 4:5 LinkedIn, rendu en x2 pour
#          que le texte reste net après la recompression de LinkedIn).
#
# Aucune dépendance à installer : on utilise le Chrome déjà présent sur le Mac.
# ==========================================================================
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$DIR/exports"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

if [[ ! -x "$CHROME" ]]; then
  echo "Chrome introuvable : $CHROME" >&2
  echo "Installe Google Chrome, ou ouvre le .html à la main et fais une capture." >&2
  exit 1
fi

mkdir -p "$OUT"
GABARITS=("${@:-}")
if [[ -z "${GABARITS[0]:-}" ]]; then
  GABARITS=(carte-chiffre tableau timeline carte-citation)
fi

for g in "${GABARITS[@]}"; do
  src="$DIR/$g.html"
  if [[ ! -f "$src" ]]; then
    echo "Gabarit inconnu : $g" >&2
    exit 1
  fi
  # --virtual-time-budget laisse le temps aux Google Fonts d'arriver : sans lui,
  # le rendu part en police de repli et la DA est fausse.
  "$CHROME" \
    --headless=new \
    --disable-gpu \
    --hide-scrollbars \
    --force-device-scale-factor=2 \
    --window-size=1200,1500 \
    --virtual-time-budget=4000 \
    --screenshot="$OUT/$g.png" \
    "file://$src" >/dev/null 2>&1
  echo "✓ $g → exports/$g.png ($(du -h "$OUT/$g.png" | cut -f1))"
done
