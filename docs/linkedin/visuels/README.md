# Kit de visuels LinkedIn — Tolkee

Quatre gabarits HTML rendus en PNG, à la direction artistique exacte du produit.
Objectif : produire le visuel du mardi en **dix minutes**, pas en deux heures, et sans
que la DA dérive d'une semaine à l'autre.

DA de référence : `app/globals.css` et `refero/DESIGN.md`. Extrait utile dans
`docs/linkedin/voice-profile.md` §6.

---

## Fabriquer un visuel

1. Ouvre le gabarit qui correspond au format du post (tableau ci-dessous).
2. Modifie **uniquement** le bloc `const DATA = { … }`, encadré par
   `▼▼▼ LA SEULE ZONE À MODIFIER ▼▼▼`. Ne touche à rien d'autre.
3. Rends l'image :

```bash
bash docs/linkedin/visuels/render.sh              # les quatre gabarits
bash docs/linkedin/visuels/render.sh tableau      # un seul
```

4. Le PNG sort dans `exports/`. Il est prêt à téléverser sur LinkedIn.

Pour prévisualiser sans rendre : ouvre le `.html` dans Chrome, il s'affiche tel quel.

**Aucune installation.** Le script utilise le Chrome déjà présent sur le Mac.

---

## Quel gabarit pour quel format

| Gabarit | Formats concernés | Ce qu'il fait |
|---|---|---|
| `carte-chiffre` | **V5** l'ordre de grandeur · **V6** le chiffre retourné | Un chiffre géant, sa source, la phrase qui le retourne |
| `tableau` | **V2** comparatif de frameworks · **V4** anti-glossaire · **V10** le reformulateur | Deux colonnes, 5 à 7 lignes, une ligne mise en avant |
| `timeline` | **V1** teardown de process · **V8** teardown d'appel | 4 à 6 étapes minutées, reliées par un filet |
| `carte-citation` | **D8** synthèse d'enquête · **V9** | 1 à 3 citations réelles avec leur attribution |

Les formats V1-V10 sont décrits dans `docs/linkedin/angles-design-partners.md` §3 bis.

---

## Les règles à ne pas casser

- **La ligne `source` n'est jamais vide.** Pas de source publique → pas de chiffre →
  pas de visuel. C'est la règle de sourcing du `voice-profile.md` §3, et c'est celle qui
  protège la crédibilité de tout le compte.
- **Un seul accent de couleur par visuel.** Une ligne en menthe, ou un mot en jaune.
  Jamais les deux, jamais deux fois. La DA tient parce que la couleur est rare.
- **Le wordmark reste « Nizar Zekri » jusqu'au 17 septembre 2026.** Le nom Tolkee
  n'apparaît sur aucun visuel avant sa révélation (cf. §4 de la bibliothèque d'angles).
- **Aucune ombre, aucun dégradé, aucune icône décorative.** La hiérarchie se fait par la
  taille du texte et la pile de tons. Si un visuel a besoin d'une décoration pour tenir,
  c'est son contenu qui est faible.
- **Le mardi est illustré, le jeudi ne l'est pas.** Un post d'opinion illustré comme un
  carrousel déplace la lecture vers l'image et perd des commentaires.

---

## Format de sortie

**2400 × 3000 px**, soit le 4:5 recommandé par LinkedIn (1200 × 1500) rendu en double
densité — le texte reste net après la recompression de LinkedIn. Le 4:5 est le ratio qui
occupe le plus de hauteur dans le fil, donc celui qui s'arrête le plus.

Le compteur en haut à droite (`01 / 03`) situe le post dans la semaine : `01` mardi,
`02` jeudi, `03` vendredi. Il donne au fil une régularité reconnaissable — un lecteur
qui voit passer `03 / 03` sait qu'il a manqué les deux autres.

---

## Si ça casse

| Symptôme | Cause | Correctif |
|---|---|---|
| Le texte sort dans une police générique | Les Google Fonts n'ont pas eu le temps d'arriver | Relancer ; au besoin monter `--virtual-time-budget` dans `render.sh` |
| Le contenu déborde en bas | Trop de lignes ou de texte | Couper. 7 lignes de tableau, 6 étapes de timeline, 3 citations — ce sont des maximums, pas des cibles |
| `Chrome introuvable` | Chrome n'est pas dans `/Applications` | Ouvrir le `.html` dans un navigateur et faire une capture manuelle |
