#!/usr/bin/env bash
# Branche la configuration LinkedIn de Nizar (voice profile + angles design partners)
# dans le cache du plugin `linkedin-skills`.
#
# Le plugin s'installe dans un dossier VERSIONNÉ : une mise à jour crée un nouveau
# dossier et perd toute modification locale. Ce script est donc à relancer après
# chaque `claude plugin update`. Il est idempotent.
#
#   bash docs/linkedin/link-into-plugin.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$HOME/.claude/plugins/cache/linkedin-skills/linkedin-skills"

if [[ ! -d "$PLUGIN_ROOT" ]]; then
  echo "✗ Plugin linkedin-skills introuvable dans $PLUGIN_ROOT" >&2
  exit 1
fi

# Dernière version installée (tri par version, pas alphabétique : 1.0.9 < 1.0.24)
VERSION_DIR="$(find "$PLUGIN_ROOT" -mindepth 1 -maxdepth 1 -type d \
  | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)"
echo "→ Plugin détecté : $VERSION_DIR"

REFS="$VERSION_DIR/references"
PLANNER="$VERSION_DIR/skills/linkedin-content-planner/SKILL.md"

link() {
  local src="$1" dest="$2"
  # Sauvegarde le fichier d'origine une seule fois (jamais un lien déjà posé)
  if [[ -f "$dest" && ! -L "$dest" && ! -f "$dest.orig" ]]; then
    cp "$dest" "$dest.orig"
    echo "  · original sauvegardé → $(basename "$dest").orig"
  fi
  ln -sfn "$src" "$dest"
  echo "  ✓ $(basename "$dest") → $src"
}

link "$REPO_DIR/voice-profile.md"            "$REFS/voice-profile.md"
link "$REPO_DIR/angles-design-partners.md"   "$REFS/design-partner-topics.md"

# Clés API (Publora, Apify). Le vrai fichier vit hors du plugin et hors du repo :
# il survit aux mises à jour et n'est jamais committé.
ENV_SRC="$HOME/.claude/linkedin-skills.env"
if [[ -f "$ENV_SRC" ]]; then
  ln -sfn "$ENV_SRC" "$VERSION_DIR/.env"
  echo "  ✓ .env → $ENV_SRC"
else
  echo "  · pas de $ENV_SRC (mode brouillon, sans publication auto)"
fi

# Ajoute la section « édition design partners » au content planner, une seule fois.
MARKER="## Design-partner edition"
if grep -qF "$MARKER" "$PLANNER"; then
  echo "  · section design-partner déjà présente dans le content planner"
else
  cat >> "$PLANNER" <<EOF

---

$MARKER (Nizar — phase pré-lancement, rentrée 2026)

**Default for this user.** When the plan is for Nizar, do NOT use the general
pillar mix or the founders edition. Use the design-partner edition in
\`../../references/design-partner-topics.md\` (symlinked from
\`$REPO_DIR/angles-design-partners.md\`).

It replaces the pillar set, the angle library (D1-D11 instead of A1-A10), the
comment-target split, and the weekly checklist. Four things it adds that the
default plan does not have and that must be honoured:

1. **The ask escalates over 6 weeks.** Friday's post is an advice-ask in weeks
   1-4 and only becomes an explicit design-partner call (D9) in weeks 5-6.
   Never plan D9 before week 5.
2. **Two different week templates.** Weeks 1-2 run three pillars over four posts
   (2 Terrain + 1 Toi + 1 Consultation). The Chantier pillar (build-in-public,
   D5) opens on the Wednesday of week 3, alongside the Tolkee name reveal.
   Never schedule Chantier before week 3.
3. **Effort is 70% comments / 30% posts.** The funnel in that file (300 comments
   → 60 replied threads → 30 DMs → 12 calls → 3-5 design partners) is the target
   to plan against, not post count.
4. **Solo-founder is the narrator, never the subject.** Build-in-public posts are
   about a commercial decision that happened to be built with AI, not about
   building with AI. Competitors may be named to credit, never to attack (D10).

Voice, banned vocabulary, and hard rules come from \`../../references/voice-profile.md\`.
Output language: **French**.
EOF
  echo "  ✓ section design-partner ajoutée au content planner"
fi

echo "✓ Terminé."
