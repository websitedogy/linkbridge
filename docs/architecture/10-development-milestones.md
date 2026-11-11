# 15. Development milestones

Each phase ends with the tests listed for that phase in CI. Do not start a phase by scaffolding screens that have no API.

The MVP is Phases 1–6. Phases 7–9 ship later on this schema and these extension points.

## Phase 1 — Foundation

Architecture is this folder. Then:

- Laravel app, PostgreSQL, Redis, Sanctum, permission package, API envelope, health route
- Migrations for users, profiles, roles, refresh tokens, OTP challenges, audit logs
- Register, verify email, verify phone, login, refresh, logout, password reset
- Policies for suspended users and staff separation
- Next.js shell: public home placeholder, login, register, token cookie route handlers
- Flutter shell: login, register, secure storage, Dio refresh interceptor

Tests: auth feature tests, token rotation, OTP attempt limits, suspended user denied, role assignment rules.

## Phase 2 — Catalog

- Migrations: industries, categories, companies, locations, listings, profiles, media
- Seller company and draft listing APIs
- Public list and slug detail with public resources only
- Seed industries
- Web: `/businesses`, `/businesses/[slug]`, metadata, sitemap, robots
- Flutter: search results and public detail

Tests: guest payload has no legal name, address line, or document keys. Slug is unique. One non-terminal listing per company.

## Phase 3 — Buyer, seller, search, favorites

- Buyer and seller profile APIs and preference tables
- `ListingSearch` PostgreSQL implementation and indexes
- Favorites
- Web filters and saved list
- Flutter filters, preferences, favorites

Tests: search does not match confidential notes. Price and industry filters use indexes (assert the query plan in one database test). Users cannot favorite their own listing.

## Phase 4 — Admin and verification

- Filament, staff 2FA, modules in the admin map through verification
- Listing status transitions and seller resubmit
- Verification requests and documents
- Scheduler hook for expiry (wired, expiry date asserted)

Tests: guest 404 on draft and submitted. Seller cannot self-publish. Admin approve publishes. Second admin cannot be created by `admin`.

## Phase 5 — Interest, inquiry, messaging, notifications

- Interests, inquiries, conversations, messages
- Database notifications, mail, FCM sender behind an interface
- Device tokens
- Web and Flutter inboxes

Tests: buyer cannot message without an inquiry. Seller email is absent from message JSON. Interest unique constraint. Notification listener runs on interest created.

## Phase 6 — Documents and NDA

- Private bucket integration in staging
- Upload validation, scan job with a fake scanner in tests
- Signed download and access logs
- NDA template, request, sign, activate
- Confidential resource unlocked only when status is `active`

Tests: confidential download 403 without NDA, 200 metadata and URL after both signatures, 403 again after expiry. Public HTML fixture contains no confidential filename. Rejected scan cannot be downloaded.

**MVP release candidate** is the end of Phase 6.

## Phase 7 — Payments

- Plans, subscriptions, payments tables
- `PaymentGateway` with one provider
- Webhook signature tests
- Filament payment module

No card fields in migrations.

## Phase 8 — Deals

- Offers, negotiations, deals, meetings
- Listing `under_offer` and `sold`
- Still no automatic legal close. Status changes are human actions.

## Phase 9 — Search scale and AI

- OpenSearch adapter behind `ListingSearch` if PostgreSQL is no longer enough
- Recommendation and assistive writing as suggestion records
- Human accept or discard on every suggestion

## Critical regression set (kept from Phase 6 onward)

Authentication, listing create, listing approve, buyer interest, seller decision, NDA access, document permissions, messaging participation, role permissions. Payment tests join in Phase 7.

## Explicitly deferred

Electronic signature vendor, WebSockets, SMS beyond OTP, deal room, valuation, video, analytics warehouse, AI decisions, professional services marketplace.
