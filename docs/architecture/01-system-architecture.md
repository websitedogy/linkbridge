# 1. System architecture

## Topology

```text
Visitors, buyers, sellers                Buyers and sellers
        |                                        |
   Next.js web                              Flutter
   (SEO public pages +                      Android + iOS
    authenticated app)
        |                                        |
        +-------------------+--------------------+
                            |
                     Laravel REST /api/v1
                     Controllers → Form Requests
                               → Policies
                               → Services
                               → Repositories (only where queries are shared)
                               → Models
                            |
        +---------+---------+---------+----------+
        |         |         |         |          |
   PostgreSQL   Redis    S3 private  SES/FCM   PaymentGateway
                          (documents,           (Razorpay | Stripe)
                           images via
                           CloudFront later)
```

Filament admin runs inside the Laravel process at `/admin`. It uses the same models, policies, and services. It does not call `/api/v1`.

## Repository layout (when implementation starts)

```text
linksbridge/
├── docs/architecture/          # this foundation
├── backend/                    # Laravel
├── web/                        # Next.js
├── mobile/                     # Flutter
└── .github/workflows/          # lint, test, build per app
```

Each app has its own dependency manifest. Shared behavior is HTTP, not a shared language library.

## Backend feature modules and layers

Backend code is grouped by feature under `backend/app/Features`. Each feature owns
its related API routes, controllers, requests, resources, models, policies,
services, enums, and testing factories. Shared infrastructure stays outside
feature modules.

```text
backend/app/Features/
├── Admin/
├── Assistant/
├── Auth/
├── Buyer/
├── Companies/
├── Core/        # shared audit logging and audit model
├── Directory/   # industries, categories, and locations
├── Listings/
├── Registry/
└── Seller/
```

For example, the listing model belongs at
`backend/app/Features/Listings/Models/Listing.php`, while its API controller,
request validation, resource, policy, service, enums, and route definitions
stay in the same `Listings` feature. `backend/routes/api.php` only loads those
feature route files inside the `/api/v1` prefix. The Laravel `App\` PSR-4 mapping
continues to load feature classes from `app/`.

The web App Router remains the URL boundary in `web/app`; feature-owned UI lives
in `web/features/<feature>`. Shared shells and generic UI remain in
`web/components`. The Flutter app already groups product screens under
`mobile/lib/features`.

### Backend layers

| Layer | Responsibility |
| --- | --- |
| Routes | URL, middleware (auth, throttle, verified email, role). No business rules. |
| Form Requests | Input shape and validation. |
| Controllers | Call one service method. Return an API Resource. |
| Policies | Authorization. Every confidential or owner-scoped action has a policy method. |
| Services | Use cases: create listing, approve interest, issue signed URL, activate NDA. Transactions live here. |
| Repositories | Reused queries (listing search, conversation inbox). Skip a repository when a model scope is enough. |
| Models | Relations, casts, scopes. No multi-step workflows. |
| Jobs | Mail, FCM, malware scan, search index refresh, signed-URL audit side effects. |
| Events / Listeners | `ListingPublished`, `InterestReceived`, `NdaActivated`, `MessageSent`. Listeners queue notifications. |
| API Resources | Visibility filtering. A guest resource and a confidential resource are different classes. |

## Visibility pipeline

```text
Request
  → auth middleware (guest allowed only on public routes)
  → policy (can this user touch this listing?)
  → service loads models
  → Resource selects Public | Registered | Confidential
  → JSON
```

Confidential document names, storage keys, legal names, and exact addresses are omitted from the JSON when the caller is not allowed. The API does not return them as `null` placeholders.

## Client rules

| Concern | Web | Mobile |
| --- | --- | --- |
| Public listing pages | Server-rendered for SEO. Calls public list/detail endpoints. | In-app lists. Same endpoints. |
| Authenticated data | TanStack Query. Zod parses responses. | Riverpod + Dio. Freezed models where payloads are stable. |
| Forms | React Hook Form + Zod | Flutter forms; server validation is authoritative |
| Tokens | httpOnly cookies on the Next.js origin. Route handlers attach `Authorization: Bearer` when proxying, or the browser calls the API only if the deployment uses a first-party API host that can read the cookie via the BFF. | Flutter Secure Storage |
| Business rules | Display and navigation only | Display and navigation only |

Public SEO routes never receive confidential payloads. Authenticated app routes send `X-Robots-Tag: noindex` and are disallowed in `robots.txt`.

## Cross-cutting services

| Concern | MVP mechanism | Later swap |
| --- | --- | --- |
| Search | `ListingSearch` → PostgreSQL | OpenSearch adapter |
| Files | `DocumentStorage` → S3 private, 5-minute signed GET | CloudFront signed URLs |
| Malware scan | `FileScanner` job; download blocked until `clean` | Lambda / dedicated scanner |
| Signatures | `SignatureProvider` → recorded in-app consent | DocuSign / similar |
| Payments | `PaymentGateway` | Razorpay, Stripe |
| Push | `PushNotifier` → FCM | — |
| Mail | Laravel mail → SES | — |
| SMS OTP | `SmsSender` | MSG91, Twilio, or SNS |
| Realtime | Domain events, client refetch | Laravel Reverb on the same events |
| Errors | Sentry | — |
| Logs | Laravel log channels → CloudWatch in production | — |
| Cache | Redis: OTP attempt counters, listing list cache keys, rate-limit store | — |

## Environments

`local`, `staging`, `production`. Separate databases, buckets, Redis, Firebase apps, and payment keys. Staging uses payment provider test mode. Nobody points a laptop at the production database.

## CI/CD

GitHub Actions, path-filtered:

- `apps/api/**` → Pint, PHPUnit (unit, feature, authorization)
- `apps/web/**` → typecheck, unit/component, Playwright on critical paths once those tests exist
- `apps/mobile/**` → analyze, unit, widget

Merge to `main` deploys staging. Production deploy is a manual approval. Schema changes are Laravel migrations, run as a release step, never by editing production by hand.

## AWS shape

| Stage | Shape |
| --- | --- |
| First production | Single ECS service or EC2 for Laravel + queue worker + scheduler, RDS PostgreSQL, ElastiCache Redis, S3, SES, ACM, Route 53, CloudWatch. Next.js on a separate service. |
| Growth | Queue workers scaled independently, read replica, CloudFront for public images, WAF, OpenSearch. |

Secrets come from the environment or a secrets manager. `APP_KEY`, database URLs, AWS keys, Firebase credentials, and payment secrets are never committed.

## Security controls (platform)

HTTPS only. Argon2id or bcrypt via Laravel hashing. OTP and reset tokens stored hashed, short TTL, attempt caps. API rate limits. Eloquent parameter binding. Validation on every write. Staff 2FA. Audit log on auth, admin actions, listing status changes, and document URL issuance. CSP and escaped rendering on the web app. Upload allow-list: extension, MIME, size, and scanner result.

Allowed upload types in the MVP:

| Kind | Types | Max size |
| --- | --- | --- |
| Listing images | jpeg, png, webp | 8 MB |
| Documents | pdf, jpeg, png | 25 MB |

Executables, archives, and SVG are rejected.

## AI readiness

Future AI calls are jobs that write suggestions onto a listing or match row with status `suggested`. A human publishes, approves, or discards. Models do not receive confidential documents unless the acting user already has confidential access and the job is explicitly requested by that user.
