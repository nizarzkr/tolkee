# Variables d'environnement — Aloalo

> Détail complet des variables de `.env.local`, extrait d'`AGENTS.md` le 21/08/2026
> pour alléger le contexte chargé à chaque session. **Rien n'a été perdu** : ce
> fichier est la référence, `AGENTS.md` n'en garde que la liste des noms.
>
> Règle inchangée : `.env.local` n'est **jamais** committé. Les clés `NEXT_PUBLIC_*`
> et `*_PUBLISHABLE_KEY` sont safe côté navigateur ; toutes les autres sont
> server-only (Server Components, Server Actions, Route Handlers).

```
NEXT_PUBLIC_SUPABASE_URL=https://kynqancfanvekodbhukd.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
SUPABASE_SECRET_KEY=sb_secret_...
ASSEMBLYAI_API_KEY=...
ANTHROPIC_API_KEY=sk-ant-...
STRIPE_SECRET_KEY=sk_test_...
RESEND_API_KEY=re_...
NEXT_PUBLIC_APP_URL=https://...   # base URL utilisée pour les liens d'invitation (J8)
UPSTASH_REDIS_REST_URL=https://...upstash.io   # rate limiting (J13)
UPSTASH_REDIS_REST_TOKEN=...                    # rate limiting (J13)
NEXT_PUBLIC_SENTRY_DSN=https://...@sentry.io/...   # observability (J13) — public par design
SENTRY_AUTH_TOKEN=sntrys_...                       # upload source maps au build (Vercel uniquement)
SENTRY_ORG=aloalo                                   # slug de l'organisation Sentry
SENTRY_PROJECT=aloalo-slug                          # slug du projet Sentry
HUBSPOT_APP_CLIENT_SECRET=...                       # client secret de l'App Card HubSpot (UI Extension) — vérifie la signature X-HubSpot-Signature-v3 des requêtes hubspot.fetch() vers /api/hubspot/card-data. Récupérable dans les réglages d'auth de l'app HubSpot. (Remplace l'ancien HUBSPOT_CARD_SECRET, abandonné avec la fonction serverless.)
HUBSPOT_CLIENT_ID=...                                # (J38) Client ID de l'app HubSpot passée en Public App OAuth. Onglet « Auth » de l'app (après `hs project upload`). Sert à construire l'URL d'autorisation + l'échange de jetons (lib/hubspot-oauth.ts). PAS un secret en soi mais à poser sur Vercel (Prod+Preview) + .env.local. Sans lui, le bouton « Connecter HubSpot » échoue.
HUBSPOT_CLIENT_SECRET=...                            # (J38) Client SECRET de la même app HubSpot OAuth (onglet « Auth »). Aussi sensible qu'un mot de passe → SERVER-ONLY / Vercel + .env.local, jamais committé. Sert à l'échange code→jetons et au rafraîchissement (POST api.hubapi.com/oauth/v1/token). ✅ Confirmé 18/06 : c'est la MÊME valeur que HUBSPOT_APP_CLIENT_SECRET (signature de carte). FAIL : si absent, getHubspotToken ne peut pas rafraîchir → repli legacy seul.
HUBSPOT_REDIRECT_BASE_URL=http://localhost:3000      # (J38, OPTIONNEL) Base d'URL du redirect_uri OAuth. À définir UNIQUEMENT en local pour forcer http://localhost:3000 (le redirect_uri doit matcher à l'identique un des redirectUrls de l'app — cf. app-hsmeta.json — et NEXT_PUBLIC_APP_URL pointe la prod). NE PAS définir sur Vercel : getRedirectUri() retombe alors sur NEXT_PUBLIC_APP_URL. SERVER-ONLY.
GOOGLE_CLIENT_ID=...                                 # (J42) Client ID de l'app OAuth Google Cloud (Meet). Console Google Cloud → API et services → Identifiants → ID client OAuth (type Application Web). Sert à construire l'URL d'autorisation + l'échange de jetons (lib/google-oauth.ts). PAS un secret mais à poser sur Vercel (Prod+Preview) + .env.local. Sans lui, « Connecter Google Meet » échoue.
GOOGLE_CLIENT_SECRET=...                             # (J42) Client SECRET de la même app OAuth Google. Aussi sensible qu'un mot de passe → SERVER-ONLY / Vercel + .env.local, jamais committé. Sert à l'échange code→jetons et au rafraîchissement (POST oauth2.googleapis.com/token). ⚠️ Google ne renvoie le refresh_token QU'à la 1re autorisation (access_type=offline&prompt=consent), et son refresh ne renvoie PAS de nouveau refresh_token (storeTokens conserve l'ancien).
GOOGLE_REDIRECT_BASE_URL=http://localhost:3000       # (J42, OPTIONNEL) Base d'URL du redirect_uri OAuth Google. À définir UNIQUEMENT en local pour forcer http://localhost:3000 (le redirect_uri doit matcher à l'identique un des « URI de redirection autorisés » de l'ID client OAuth, et NEXT_PUBLIC_APP_URL pointe la prod). NE PAS définir sur Vercel : getGoogleRedirectUri() retombe alors sur NEXT_PUBLIC_APP_URL. SERVER-ONLY.
PIPEDRIVE_CLIENT_ID=...                              # (J46) Client ID de l'app OAuth Pipedrive (Developer Hub → onglet OAuth & access scopes). Sert à construire l'URL d'autorisation + l'échange de jetons (lib/pipedrive-oauth.ts). PAS un secret mais à poser sur Vercel (Prod+Preview) + .env.local. Sans lui, « Connecter Pipedrive » échoue.
PIPEDRIVE_CLIENT_SECRET=...                          # (J46) Client SECRET de la même app Pipedrive. Aussi sensible qu'un mot de passe → SERVER-ONLY / Vercel + .env.local, jamais committé. Sert à l'échange code→jetons et au rafraîchissement (POST oauth.pipedrive.com/oauth/token, en HTTP Basic Auth). ⚠️ Pipedrive RENVOIE un nouveau refresh_token à chaque refresh (rotation) → storeTokens le réécrit. La réponse /token contient aussi `api_domain` (base d'URL propre à la société) stockée en DB.
PIPEDRIVE_REDIRECT_BASE_URL=http://localhost:3000    # (J46, OPTIONNEL) Base d'URL du redirect_uri OAuth Pipedrive. À définir UNIQUEMENT en local pour forcer http://localhost:3000 (le redirect_uri doit matcher à l'identique une des « Callback URL » de l'app Pipedrive ; NEXT_PUBLIC_APP_URL pointe la prod). NE PAS définir sur Vercel : getRedirectUri() (lib/pipedrive-oauth.ts) retombe alors sur NEXT_PUBLIC_APP_URL. SERVER-ONLY.
ORG_SECRETS_ENC_KEY=base64(32 octets)               # chiffre au repos les credentials tiers (ringover_api_key, hubspot_token) via AES-256-GCM — cf. lib/crypto/org-secrets.ts (issue #5). SERVER-ONLY / Vercel-only (tous environnements). Générer avec `openssl rand -base64 32`. Si absente, toute (dé)chiffrement échoue → pipeline cassé : à régler AVANT de déployer la migration 0017.
INTERNAL_PIPELINE_SECRET=hex(32 octets)             # secret partagé interne qui protège /api/transcribe et /api/analyze (routes service key, bypass RLS, appelées QUE par nos webhooks). Vérifie l'en-tête x-aloalo-internal en temps constant — cf. lib/internal-auth.ts (issue #2). FAIL-CLOSED : si absente, les deux routes renvoient 401 → pipeline cassé. SERVER-ONLY / Vercel (Production + Preview + Development). Générer avec `openssl rand -hex 32`.
AUDIO_URL_ALLOWED_HOSTS=ringover.com                # (optionnel) allowlist anti-SSRF des hôtes autorisés pour calls.audio_url avant envoi à AssemblyAI (issue #2). CSV de suffixes d'hôte, défaut `ringover.com`. À ÉTENDRE avec le vrai domaine d'hébergement des enregistrements Ringover dès qu'on le voit (souvent un CDN/stockage distinct) — sinon la transcription réelle échoue en 422. (J44) MÊME chose pour Aircall : le MP3 du webhook `call.ended` (champ `recording`, valide 1h) est sur un hôte Aircall/CDN à ajouter ici au 1er vrai appel Aircall, sinon transcription 422.
ASSEMBLYAI_WEBHOOK_SECRET=hex(32 octets)            # secret partagé envoyé à AssemblyAI à la création de la transcription (lib/assemblyai.ts), qu'il renvoie sur le webhook /api/webhooks/assemblyai via le header x-assemblyai-webhook-secret (issue #4). Le handler le vérifie en temps constant. FAIL-CLOSED : si absent, requestTranscription throw ET le webhook renvoie 401 → pipeline cassé. SERVER-ONLY / Vercel (même valeur sur tous les environnements pointant vers ce compte AssemblyAI). Générer avec `openssl rand -hex 32`.
CRON_SECRET=hex(32 octets)                          # secret des jobs planifiés. (1) Vercel Cron : envoyé en `Authorization: Bearer <CRON_SECRET>` à /api/cron/sweep-stuck-calls (filet de sécurité des appels coincés en transcribing, issue #12). FAIL-CLOSED : si absent, la route renvoie 401 → le sweeper ne tourne pas. (2) Edge functions Supabase delete-old-audio (purge audio RGPD) ET spend-alert (alerte de dépense IA, issue #20) qui l'emploient déjà. SERVER-ONLY. À configurer sur Vercel (tous environnements) ET côté Supabase ; idéalement la même valeur. Générer avec `openssl rand -hex 32`.
ALLOW_DEV_SIMULATE=1                                 # (optionnel) flag d'échappement du simulateur d'appels DEV (issue #17). Le simulateur (/dev/test + /api/dev/simulate-call) est actif en local et sur les preview Vercel, mais DÉSACTIVÉ en production (gate sur VERCEL_ENV, cf. lib/dev/is-simulator-enabled.ts). Mettre cette variable à `1` réactive l'outil même en prod, le temps d'une démo ponctuelle. NE JAMAIS l'activer par défaut en production. SERVER-ONLY.
SPEND_ALERT_DAILY_EUR=10                             # (optionnel) seuil quotidien en € de l'Edge Function spend-alert (issue #20). Au-delà de ce cumul de usage_logs.cost_eur sur le jour UTC, un email d'alerte part via Resend. Défaut 10 si absent/non-numérique. SECRET de la fonction SUPABASE (Edge Functions → Secrets), PAS Vercel.
SPEND_ALERT_TO=ops@exemple.fr                        # adresse ops qui reçoit l'email d'alerte de dépense (Edge Function spend-alert, issue #20). Si absente, l'alerte est seulement loggée (pas d'email). SECRET de la fonction SUPABASE, PAS Vercel.
```

Ajouts prévus : `STRIPE_WEBHOOK_SECRET` (J9), `RINGOVER_WEBHOOK_SECRET` (J3).
