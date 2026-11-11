# 5. API specification

Base path: `/api/v1`. JSON only. Authentication: `Authorization: Bearer {access_token}` except routes marked public.

## Envelope

Success of one object:

```json
{ "data": { } }
```

Success of a list:

```json
{
  "data": [],
  "meta": { "current_page": 1, "per_page": 20, "total": 0, "last_page": 1 },
  "links": { "next": null, "prev": null }
}
```

`per_page` maximum is 50. Default is 20.

Error:

```json
{
  "message": "Human-readable summary",
  "code": "VALIDATION_ERROR",
  "errors": { "email": ["The email has already been taken."] }
}
```

| HTTP | code |
| --- | --- |
| 401 | `UNAUTHENTICATED` |
| 403 | `FORBIDDEN` or `CONFIDENTIAL_LOCKED` or `EMAIL_UNVERIFIED` |
| 404 | `NOT_FOUND` |
| 409 | `CONFLICT` |
| 422 | `VALIDATION_ERROR` |
| 429 | `RATE_LIMITED` |

`CONFIDENTIAL_LOCKED` has an empty `errors` object and does not name locked files.

Ids in paths and payloads are UUIDs. Money fields are integers in minor units plus `currency`.

Phase tags: **MVP** ships in phases 1–6. **Later** is specified so clients do not invent ad hoc URLs.

## Auth — MVP

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| POST | `/auth/register` | public | Create user. Body: `account_type` `buyer` or `seller`, `first_name`, `last_name`, `email`, `password`, `phone_country_code`, `phone`. Sends email OTP. |
| POST | `/auth/email/verify` | public | Body: `email`, `code`. Activates user. |
| POST | `/auth/email/resend` | public | Body: `email`. |
| POST | `/auth/phone/verify` | bearer | Body: `code`. |
| POST | `/auth/phone/resend` | bearer | Sends SMS OTP. |
| POST | `/auth/login` | public | Body: `email`, `password`, `device_name`. Returns tokens and user. |
| POST | `/auth/refresh` | public | Body: `refresh_token`. Rotates refresh token. |
| POST | `/auth/logout` | bearer | Revokes current access and refresh token. |
| POST | `/auth/password/forgot` | public | Body: `email`. Always 200. |
| POST | `/auth/password/reset` | public | Body: `email`, `code`, `password`. |
| GET | `/auth/me` | bearer | Current user, roles, verification flags. |

Login response `data`:

```json
{
  "access_token": "string",
  "refresh_token": "string",
  "expires_in": 900,
  "token_type": "Bearer",
  "user": {
    "id": "uuid",
    "email": "string",
    "roles": ["buyer"],
    "email_verified": true,
    "phone_verified": false,
    "status": "active"
  }
}
```

Rate limits: register 5/hour/IP, login 5/minute/IP+email, OTP send 3/10 minutes/destination, OTP verify 5 attempts then the challenge is burned.

## Reference data — MVP, public

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/industries` | Active industries. |
| GET | `/categories` | Query `industry_id` optional. |

## Buyer and seller profiles — MVP

| Method | Path | Auth |
| --- | --- | --- |
| GET | `/buyer/profile` | buyer |
| PUT | `/buyer/profile` | buyer. Budget, type, bio, industry ids, locations, business types. |
| GET | `/seller/profile` | seller |
| PUT | `/seller/profile` | seller |

## Companies — MVP

| Method | Path | Auth |
| --- | --- | --- |
| POST | `/seller/companies` | seller. Legal name and primary location. |
| GET | `/seller/companies` | seller. Own companies. |
| GET | `/seller/companies/{id}` | seller owner or staff via admin, not this route for staff. |
| PUT | `/seller/companies/{id}` | seller owner, while no published listing locks legal identity without re-verification. |

There is no public `GET /companies/{id}`. Companies are reached through listings.

## Listings — MVP

| Method | Path | Auth | Notes |
| --- | --- | --- | --- |
| GET | `/listings` | public | Published and under-offer only. Public resource. |
| GET | `/listings/{id}` | public | Same visibility. 404 if not publicly visible. |
| GET | `/listings/slug/{slug}` | public | SEO detail. |
| GET | `/seller/listings` | seller | All own statuses. Includes rejection reason. |
| POST | `/seller/listings` | seller | Creates `draft`. |
| GET | `/seller/listings/{id}` | seller owner | Full fields the seller owns. |
| PUT | `/seller/listings/{id}` | seller owner | Allowed in `draft`, `rejected`, `verification_required`. |
| POST | `/seller/listings/{id}/submit` | seller | Moves to `submitted`. Requires phone verified, public summary, price, industry, location, at least one clean image. |
| POST | `/seller/listings/{id}/pause` | seller | `published` → `paused`. |
| POST | `/seller/listings/{id}/resume` | seller | `paused` → `published` if review still valid. |
| POST | `/seller/listings/{id}/media` | seller | Multipart image. |
| DELETE | `/seller/listings/{id}/media/{mediaId}` | seller | Draft-like statuses only. |

Public listing `data` fields: `id`, `slug`, `title`, `status` (`published` or `under_offer`), `business_type`, `industry`, `categories`, `asking_price_minor`, `currency`, `revenue_min_minor`, `revenue_max_minor`, `profit_min_minor`, `profit_max_minor`, `ebitda_min_minor`, `ebitda_max_minor`, `years_in_business`, `employees_min`, `employees_max`, `country_code`, `state`, `city`, `summary`, `highlights`, `media` (signed image URLs, short TTL), `published_at`.

`GET /listings/{id}` with a buyer token adds `registered` when the buyer is allowed: `detailed_summary`, `history`, `operations`, and any exact figures stored at registered level. It adds `confidential` only when the NDA is active. Otherwise those keys are absent.

## Search — MVP, public

`GET /search/listings`

Query: `q`, `industry_id`, `category_id`, `country_code`, `state`, `city`, `price_min`, `price_max`, `revenue_min`, `revenue_max`, `profit_min`, `profit_max`, `ebitda_min`, `ebitda_max`, `years_min`, `employees_min`, `business_type`, `sort` (`newest`, `price_asc`, `price_desc`, `revenue_desc`), `page`, `per_page`.

Same public resource as the listing list. `q` matches the public search vector only.

## Favorites — MVP

| Method | Path | Auth |
| --- | --- | --- |
| GET | `/favorites` | bearer |
| POST | `/favorites` | Body: `listing_id`. 409 if own listing. |
| DELETE | `/favorites/{listingId}` | bearer |

## Interests and inquiries — MVP

| Method | Path | Auth |
| --- | --- | --- |
| POST | `/listings/{id}/interests` | buyer. Body: `message` optional. |
| GET | `/buyer/interests` | buyer |
| GET | `/seller/interests` | seller. Query `listing_id`, `status`. |
| POST | `/seller/interests/{id}/approve` | seller owner |
| POST | `/seller/interests/{id}/reject` | seller owner. Body: `reason` optional. |
| POST | `/listings/{id}/inquiries` | buyer. Body: `subject`, `body`. Creates conversation. |
| GET | `/buyer/inquiries` | buyer |
| GET | `/seller/inquiries` | seller |

Buyer cannot open an interest twice. Second call returns the existing row with 200.

## Messaging — MVP

| Method | Path | Auth |
| --- | --- | --- |
| GET | `/conversations` | participant |
| GET | `/conversations/{id}` | participant. Messages paginated, newest page first. |
| POST | `/conversations/{id}/messages` | participant. Body: `body`, optional multipart attachments. |
| POST | `/conversations/{id}/read` | participant. Sets `last_read_at`. |

Message payload: `id`, `sender_role` (`buyer` or `seller`, not email), `body`, `created_at`, `attachments` (id and filename only if scan is clean). No phone numbers. The server rejects bodies that contain an email address or a phone number pattern in the MVP, with `VALIDATION_ERROR`, so users stay on-platform. This filter is a heuristic, not a security boundary.

## Documents — MVP

| Method | Path | Auth |
| --- | --- | --- |
| POST | `/seller/listings/{id}/documents` | seller. Multipart: file, `category`, `access_level`. |
| GET | `/seller/listings/{id}/documents` | seller owner. All levels, plus scan status. |
| GET | `/listings/{id}/documents` | buyer. Only rows the policy allows, metadata only. |
| POST | `/documents/{id}/download` | authorized. Body empty. Returns `{ "url", "expires_in": 300 }`. Writes access log. 403 `CONFIDENTIAL_LOCKED` or 409 if scan is not `clean`. |

Clients upload to the API. The API streams to S3. Browsers do not receive AWS credentials.

## NDA — MVP

| Method | Path | Auth |
| --- | --- | --- |
| GET | `/nda/template` | bearer. Active template body for display. |
| POST | `/listings/{id}/nda` | buyer. Creates `requested` then immediately `seller_review`. Requires an approved interest. |
| GET | `/buyer/nda` | buyer |
| GET | `/seller/nda` | seller |
| POST | `/seller/nda/{id}/approve` | seller. Status → `awaiting_buyer_signature`. |
| POST | `/seller/nda/{id}/reject` | seller. Status → `seller_rejected`. |
| POST | `/nda/{id}/sign` | buyer or seller party. Body: `accept: true`. Records signature. Buyer signature moves status to `awaiting_seller_signature`. Seller signature moves status to `active` and sets `expires_at` to 180 days. |

## Verification — MVP

| Method | Path | Auth |
| --- | --- | --- |
| POST | `/verification/requests` | buyer or seller. Body: `subject_type`, optional `company_id`. |
| POST | `/verification/requests/{id}/documents` | owner. Multipart. |
| GET | `/verification/requests` | own requests, status only plus reviewer notes on rejection. |

Decisions are admin-only inside Filament, not public API routes, in the MVP.

## Notifications — MVP

| Method | Path | Auth |
| --- | --- | --- |
| GET | `/notifications` | bearer |
| POST | `/notifications/{id}/read` | bearer |
| POST | `/notifications/read-all` | bearer |
| POST | `/devices` | Body: `token`, `platform`. |
| DELETE | `/devices` | Body: `token`. |

## Account — MVP

| Method | Path | Auth |
| --- | --- | --- |
| PUT | `/account/password` | bearer |
| PUT | `/account/profile` | bearer. Name and avatar. |

## Health — MVP, public

`GET /health` returns `{ "data": { "status": "ok" } }`. No dependency details.

## Later endpoints (do not implement in the MVP)

| Phase | Method | Path |
| --- | --- | --- |
| 7 | GET | `/plans` |
| 7 | POST | `/subscriptions` |
| 7 | POST | `/payments/webhook/{provider}` |
| 8 | POST | `/listings/{id}/offers` |
| 8 | GET | `/deals` |
| 8 | POST | `/listings/{id}/meetings` |
| 9 | GET | `/recommendations` |

Webhook routes verify provider signatures and are unauthenticated aside from that signature.
