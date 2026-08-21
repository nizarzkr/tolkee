<!-- BEGIN:nextjs-agent-rules -->
# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->

---

# Projet Aloalo

## Pitch
SaaS d'intelligence commerciale qui se branche via API sur la téléphonie d'entreprise (Ringover, Aircall). Transcrit les appels, les analyse via IA, génère scores de performance et conseils de coaching automatique.

## Cible
Startups et PME françaises (5–50 commerciaux) utilisant Ringover ou Aircall.

## Founder
Nizar — sans compétences techniques. Apprend à piloter une IA qui code en construisant ce SaaS. Toujours expliquer pédagogiquement les concepts, sans jargon non défini, et demander avant de deviner sur les choix structurants.

---

## Stack technique (figée)

- **Frontend** : Next.js 16.2.4 (App Router) + React 19.2 + TypeScript + Tailwind v4 + shadcn/ui
- **Backend** : Next.js API Routes / Server Actions
- **Auth + DB** : Supabase, région **West EU (Paris)**, projet `kynqancfanvekodbhukd`
- **Transcription** : AssemblyAI (région EU, modèle Universal-2, diarisation native)
- **Analyse IA** : Claude Haiku 4.5 (`claude-haiku-4-5-20251001`)
- **Paiement** : Stripe (test pour le MVP)
- **Email** : Resend
- **Hosting** : Vercel (Hobby)
- **Téléphonie** : Ringover (Aircall en alt) — accès API en validation

---

## Conventions du repo (à respecter)

- **Pas de `src/`** — convention plate. `app/`, `lib/`, `components/` à la racine.
- **Alias `@/*` pointe sur `./*`** (cf. `tsconfig.json`). Ex : `@/lib/supabase/server`.
- **Migrations SQL** dans `supabase/migrations/NNNN_description.sql` (numérotées).
  - **Jamais de changement de schéma `public.*` dans la console Supabase sans migration numérotée correspondante.** Les migrations sont l'unique source de vérité du schéma et doivent pouvoir reconstruire la prod à l'identique. Un edit console hors migration crée une dérive silencieuse (cf. issue #6 : `callee_number`/`provider_call_id` ajoutés à la main → DB reconstruite depuis les migrations incapable de faire tourner le pipeline).
- **Composants UI** : shadcn dans `components/ui/`. Ajouter via `npx shadcn@latest add <component>`.
- **Code en anglais**, **libellés UI en français**.
- **Server Actions privilégiées** sur les API Routes pour les formulaires.
- **`shadcn` reste dans `dependencies`** (et non `devDependencies`) : `app/globals.css` fait `@import "shadcn/tailwind.css"` au build. Le déplacer en dev casse `next build`.
- **CI installe avec `npm ci`** (respecte `package-lock.json` pour des builds reproductibles), pas `npm install`.
- **Client Stripe via `getStripe()`** (`lib/stripe.ts`) — jamais `new Stripe(...)` en direct : la factory épingle l'`apiVersion` pour qu'un `npm update` de `stripe` ne change pas silencieusement le comportement de l'API (cf. issue #32).

---

## Sécurité (non négociable)

- **`.env.local` JAMAIS committé** (`.gitignore` ligne `.env*` couvre ça).
- Clés `NEXT_PUBLIC_*` ou `*_PUBLISHABLE_KEY` → safe côté navigateur.
- Toutes les autres (`*_SECRET_KEY`, `ANTHROPIC_API_KEY`, etc.) → **uniquement côté serveur** (Server Components, Server Actions, Route Handlers).
- **RLS activée sur toutes les tables `public.*`**. Les users LISENT (clé publishable + JWT). Le serveur ÉCRIT (secret key bypass RLS).
- Données utilisateurs en Europe (Supabase Paris, AssemblyAI EU).

---

## Plafonds de dépense API (backstop financier)

Caps mensuels HARD configurés directement dans les dashboards fournisseurs
(seule garantie qui stoppe réellement la dépense) :
- Anthropic : 50 €/mois — Console Anthropic → Billing → Spend limit.
- AssemblyAI : 50 €/mois — Dashboard AssemblyAI → Billing → Usage cap.

À revoir avant chaque montée de trafic. Le code ne peut PAS garantir le plafond
(les coûts en DB sont des ESTIMATIONS, cf. `lib/claude.ts` / `lib/assemblyai.ts`).
Alerte précoce in-app : Edge Function `spend-alert` (issue #20) — somme la dépense
quotidienne (`usage_logs.cost_eur`) et envoie un email Resend au-delà d'un seuil
(`SPEND_ALERT_DAILY_EUR`, défaut 10 €/jour).

---

## Variables d'env (`.env.local`)

Détail complet (rôle de chaque clé, criticité, où la récupérer) : **[`docs/env-vars.md`](./docs/env-vars.md)**.
Noms attendus, par domaine :

- **Supabase** — `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`
- **IA** — `ASSEMBLYAI_API_KEY`, `ANTHROPIC_API_KEY`
- **App** — `NEXT_PUBLIC_APP_URL`, `STRIPE_SECRET_KEY`, `RESEND_API_KEY`
- **CRM / visio (OAuth)** — `HUBSPOT_CLIENT_ID/SECRET`, `HUBSPOT_APP_CLIENT_SECRET`, `GOOGLE_CLIENT_ID/SECRET`, `PIPEDRIVE_CLIENT_ID/SECRET` (+ les `*_REDIRECT_BASE_URL` en local uniquement)
- **Secrets internes — fail-closed, cassent le pipeline si absents** — `ORG_SECRETS_ENC_KEY`, `INTERNAL_PIPELINE_SECRET`, `ASSEMBLYAI_WEBHOOK_SECRET`, `CRON_SECRET`
- **Optionnels** — `AUDIO_URL_ALLOWED_HOSTS`, `ALLOW_DEV_SIMULATE`, `SPEND_ALERT_DAILY_EUR`, `SPEND_ALERT_TO`, `UPSTASH_REDIS_REST_URL/TOKEN`, `NEXT_PUBLIC_SENTRY_DSN`, `SENTRY_AUTH_TOKEN/ORG/PROJECT`

Ajouts prévus : `STRIPE_WEBHOOK_SECRET`, `RINGOVER_WEBHOOK_SECRET`.

---

## Modèle de données (cf. `supabase/migrations/`)

10 tables dans `public` :
- `organizations` — racine du tenant (1 org = 1 compte client Aloalo)
- `profiles` — `id = auth.users.id`, lié à une org, role `owner`/`manager`/`sales`
- `calls` — appels Ringover/Aircall/Google Meet/simulés, pipeline `pending → transcribing → analyzed`
- `analyses` — résultat IA d'un appel (1-to-1 avec `calls`), dimensions + conseils
- `usage_logs` — coûts API par org (AssemblyAI, Anthropic, Resend)
- `coaching_sessions` — briefings « Préparer un 1:1 » générés par manager
- `deal_hygiene` / `deal_pushed_actions` — signaux de risque sur le pipe et actions déjà poussées
- `task_completions` — file « À faire » cochée par le commercial
- `invitations` — liens magiques pour rejoindre une org
  - `token text` (et non `uuid`) — hex 32 chars sans tirets, généré par DB
  - À l'invitation, `role` ∈ `{'manager', 'sales'}` (un owner ne s'auto-réplique pas)

Trigger `on_auth_user_created` (fonction `public.handle_new_user`) : à chaque signup `auth.users`, crée auto une org + un profile owner. Les valeurs `full_name` et `organization_name` viennent de `raw_user_meta_data` envoyé par le formulaire signup côté Next.js.

Helper RLS : `public.user_organization_id()` (SECURITY DEFINER) — renvoie l'org_id du user JWT, à utiliser dans les policies pour éviter la récursion.

---

## État d'avancement

Produit construit et déployé (J1 → J46) : auth, invitations et rôles, pipeline
appel → transcription → analyse, coaching et briefing 1:1, hygiène du pipe,
intégrations Ringover / Aircall / Google Meet / HubSpot / Pipedrive, facturation
Stripe, site vitrine.

**`ISSUES_TRACKER.md` fait foi** pour ce qui reste (29/34 issues fermées, 5 reportées
à l'ouverture commerciale). Ne jamais dupliquer cet état ici : deux sources de
vérité qui divergent, c'est pire que pas de source du tout.

---

## Workflow attendu

1. **Avant de proposer une grosse modif structurelle** (changer un dossier, renommer un fichier qui touche plusieurs imports, modifier la stack), demander confirmation.
2. **Lire les conventions** (ce fichier) avant d'écrire du code.
3. **Toujours préférer** `Edit` sur des fichiers existants plutôt que créer des doublons.
4. **Commenter en français** les décisions non-évidentes.
5. **Ne jamais committer `.env.local`** ni n'importe quel secret.

---

## Commande « ship la prochaine issue »

Quand Nizar dit **« ship la prochaine issue »** (ou une formulation équivalente, sans donner de numéro), appliquer cette procédure exacte :

1. **Identifier l'issue.** Ouvrir `ISSUES_TRACKER.md` à la racine et prendre la **première case non cochée** (`- [ ]`) dans l'ordre du fichier — c'est l'issue à traiter. Confirmer le numéro à Nizar en une ligne. Ne jamais sauter de ligne ni changer l'ordre.
2. **Lire l'issue** sur GitHub avec `gh issue view <N>` pour avoir le détail complet (fichiers, fix, critères d'acceptation).
3. **Mode plan.** Proposer un plan à Nizar et le débriefer avec lui. Ne rien modifier tant qu'il n'a pas validé le plan.
4. **Exécuter** une fois le plan validé : coder, tester.
5. **Commit directement sur `main`** (workflow choisi par Nizar : pas de Pull Request). Message de commit en français, terminé par la ligne `Co-Authored-By`. Référencer l'issue dans le message (ex. `Closes #N`).
6. **Avant de terminer**, cocher la case correspondante dans `ISSUES_TRACKER.md` (`- [ ]` → `- [x]`), mettre à jour le compteur de progression et le pointeur « prochaine issue » en bas du fichier, puis cocher la case dans l'EPIC **#35** sur GitHub (`gh issue edit`/`gh api`) et, si pertinent, fermer l'issue (`gh issue close <N>`).
7. **Une seule issue par session.** Ne pas enchaîner sur la suivante automatiquement.
