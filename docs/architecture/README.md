# LinksBridge architecture index

These documents are the implementation contract. If code and a document disagree during Phase 1, stop and update the document first.

## Locked decisions

| ID | Decision |
| --- | --- |
| D1 | Three deployables (web, mobile, API). One REST API at `/api/v1`. No duplicated business rules. |
| D2 | Laravel Sanctum bearer tokens for web and mobile. Access token 15 minutes. Rotating refresh token 30 days, stored hashed. Next.js keeps tokens in httpOnly cookies via route handlers. Flutter uses Flutter Secure Storage. No tokens in localStorage. |
| D3 | UUIDv7 primary keys on domain entities exposed to clients. Bigint identity keys only on append-only logs (`listing_views`, `audit_logs`, `document_access_logs`). |
| D4 | Money is a bigint in minor units plus an ISO 4217 currency code. No floats. |
| D5 | Public listings are anonymized. Legal name, registration number, exact address, owner identity, and customer or supplier data are confidential. |
| D6 | Three visibility levels: `public`, `registered`, `confidential`. API Resources drop fields the caller cannot see. Policies are the authority. Frontend role checks are only for navigation. |
| D7 | A company may have only one listing that is not in a terminal status (`sold`, `rejected`, `expired`). |
| D8 | A marketplace account may hold `buyer` and `seller` together. `admin` and `super_admin` are staff accounts and are not combined with marketplace roles. |
| D9 | `spatie/laravel-permission` for roles. Laravel Policies for resource authorization. |
| D10 | Search goes through a `ListingSearch` interface. The first implementation is PostgreSQL (`tsvector` plus filters). OpenSearch can replace the implementation without changing controllers. |
| D11 | Files live in a private S3 bucket. Downloads use short-lived signed URLs issued only after authorization. Objects stay unavailable until a malware scan marks them clean. |
| D12 | NDA signing goes through a `SignatureProvider` interface. MVP uses an in-app acknowledgment with stored consent, IP, and timestamp. An e-sign vendor plugs in later. |
| D13 | Payments go through a `PaymentGateway` interface (Razorpay and Stripe adapters). The database never stores PAN or CVV. |
| D14 | Admin is Laravel Filament on the API application, with required TOTP 2FA. It is not a third client of the public JSON API. Policies are shared. |
| D15 | Messaging is persisted through REST. Domain events are the hook for later WebSocket broadcasting. MVP clients refresh conversations; they do not open a socket. |
| D16 | Notification channels: database, email (SES), push (FCM). SMS is limited to phone OTP in the MVP. |
| D17 | AI features, when added, sit behind service interfaces and never approve listings, release documents, sign NDAs, or accept payments without a human. |
| D18 | Currency and payment provider are configuration, not hardcoded geography. |

## Build order

Phases 1 through 6 are the production MVP. Phases 7 through 9 are later products on the same schema. See [milestones](10-development-milestones.md).

## Non-goals for the first release

Deal room, offers, negotiation, e-sign vendor, OpenSearch, AI matching, valuation, video meetings, analytics warehouse, and a professional-services marketplace. Tables for offers, deals, meetings, and subscriptions are specified now so those phases do not require a rewrite, and they stay unused until their phase.
