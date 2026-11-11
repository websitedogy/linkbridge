# LinksBridge API v1

Base URL: `http://localhost:8000/api/v1`

All responses use this envelope.

Success:

```json
{ "success": true, "message": "…", "data": {}, "meta": { "current_page": 1, "per_page": 20, "total": 1, "last_page": 1 } }
```

`meta` is present on paginated lists.

Validation:

```json
{ "success": false, "message": "Validation failed.", "errors": { "email": ["…"] } }
```

Unauthorized and forbidden:

```json
{ "success": false, "message": "Unauthorized." }
```

```json
{ "success": false, "message": "Forbidden." }
```

Money fields are integer minor units (INR paise). Public listing responses never include the legal company name, website, or exact financials unless the caller owns the listing or is an admin.

Authentication is a Sanctum bearer token: `Authorization: Bearer {token}`. Tokens expire after seven days. Public registration accepts only `buyer` and `seller`.

## Auth

| Method | Path | Auth | Body | Success |
| --- | --- | --- | --- | --- |
| POST | `/auth/register` | No | `name`, `email`, `password`, `password_confirmation`, `role` (`buyer` or `seller`), optional `mobile` | 201, token and user |
| POST | `/auth/login` | No | `email`, `password` | 200, token and user |
| POST | `/auth/logout` | Bearer | — | 200 |
| GET | `/auth/me` | Bearer | — | 200, current user |

Login and register are limited to 5 requests per minute per email and IP. Invalid credentials return 422. `admin` and `super_admin` cannot self-register (422). A missing or invalid token returns 401.

## Reference data

No authentication.

| Method | Path | Query | Success |
| --- | --- | --- | --- |
| GET | `/industries` | — | Active industries |
| GET | `/categories` | optional `industry` slug | Active categories |
| GET | `/locations` | optional `type` (`country`, `state`, `city`) and `parent_id` | Active locations |

## Public listings

Optional bearer token. A valid token can reveal `registered_users` listings. A verified buyer can also see `verified_buyers` listings. `confidential` listings are omitted. Draft and under-review listings are omitted. An unknown or hidden slug returns 404.

| Method | Path | Query |
| --- | --- | --- |
| GET | `/listings` | `keyword`, `industry`, `category`, `country`, `state`, `city`, `min_price`, `max_price`, `min_revenue`, `max_revenue`, `business_type`, `sort` (`newest`, `price_asc`, `price_desc`), `page`, `per_page` (max 50) |
| GET | `/listings/{slug}` | — |

Example: `GET /listings?industry=technology&city=Hyderabad&min_price=10000000`

## Seller

Requires bearer token and the `seller` role. Buyers receive 403. A seller can change only companies and listings they own. Another seller's record returns 403.

| Method | Path | Body | Notes |
| --- | --- | --- | --- |
| GET | `/seller/companies` | — | Own companies, including the private legal name |
| POST | `/seller/companies` | `company_name`, `public_name`, `industry_id`, `category_id`, `business_type`, optional `location_id`, `description`, `employee_count`, `financials` | 201 |
| PUT | `/seller/companies/{company}` | Any company field | Owner only |
| GET | `/seller/listings` | — | Paginated own listings |
| POST | `/seller/listings` | `company_id`, `title`, `short_description`, optional price ranges, `visibility`, `listing_type` | Creates a `DRAFT` |
| GET | `/seller/listings/{id}` | — | Owner only |
| PUT | `/seller/listings/{id}` | Listing fields except `company_id` | Draft or rejected only |
| DELETE | `/seller/listings/{id}` | — | Draft or rejected only |
| POST | `/seller/listings/{id}/submit` | — | Moves draft or rejected to `UNDER_REVIEW` when title, summary, and asking price exist |
| POST | `/seller/listings/{id}/media` | multipart `file` | jpg, jpeg, png, or webp, max 8 MB. Stored on the configured media disk |
| GET | `/seller/interests` | — | Interests on own listings |
| PATCH | `/seller/interests/{id}` | `status`: `viewed`, `accepted`, or `rejected` | Own listing only |
| GET | `/seller/inquiries` | — | Inquiries on own listings. Does not expose the buyer's email or phone |

`financials.value_mode` is `exact`, `range`, or `private`. Exact figures stay off the public listing resource.

## Buyer

Requires bearer token and the `buyer` role. Sellers receive 403. A buyer can favorite or contact only a listing that is visible to them. Saving or expressing interest twice returns 409.

| Method | Path | Body | Success |
| --- | --- | --- | --- |
| GET | `/buyer/favorites` | — | Saved listings |
| POST | `/buyer/favorites/{listing}` | — | 201 |
| DELETE | `/buyer/favorites/{listing}` | — | 200 |
| GET | `/buyer/interests` | — | Own interests and status |
| POST | `/buyer/listings/{listing}/interest` | optional `message` | 201, status `PENDING` |
| PATCH | `/buyer/interests/{interest}/withdraw` | — | Status `WITHDRAWN` |
| POST | `/buyer/listings/{listing}/inquiry` | `subject`, `message` | 201 |

## Admin

Requires bearer token and `admin` or `super_admin`. Other roles receive 403. Unauthenticated requests receive 401.

| Method | Path | Query |
| --- | --- | --- |
| GET | `/admin/listings` | optional `status`, for example `under_review` |

This phase does not publish listings from the seller API. A submitted listing stays `UNDER_REVIEW` until a later approval step. Development seed data includes one published demo listing so the public marketplace can be browsed.
