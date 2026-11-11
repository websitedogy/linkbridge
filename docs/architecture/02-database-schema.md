# 3. Database schema

PostgreSQL. Laravel migrations are the executable form of this document. Names below are table and column names.

Conventions:

- Domain primary keys: `uuid` UUIDv7, column `id`.
- Timestamps: `created_at`, `updated_at`. Soft deletes (`deleted_at`) on users, companies, listings, messages.
- Money: `bigint` minor units + `char(3)` currency.
- Status columns are PostgreSQL enums or checked strings matching this document exactly (uppercase in the API, lowercase in the database).
- Foreign keys are `ON DELETE RESTRICT` unless noted. User-owned profile rows use `CASCADE`.

## Enumerations

| Name | Values |
| --- | --- |
| `user_status` | `pending`, `active`, `suspended` |
| `verification_status` | `pending`, `under_review`, `verified`, `rejected`, `additional_information_required` |
| `listing_status` | `draft`, `submitted`, `under_review`, `verification_required`, `approved`, `published`, `paused`, `under_offer`, `sold`, `rejected`, `expired` |
| `business_type` | `asset_sale`, `share_sale`, `franchise`, `partnership_interest`, `other` |
| `buyer_type` | `individual`, `company`, `fund`, `family_office`, `strategic` |
| `document_access_level` | `public`, `registered`, `confidential` |
| `scan_status` | `pending`, `clean`, `rejected` |
| `interest_status` | `pending`, `approved`, `rejected`, `withdrawn` |
| `inquiry_status` | `open`, `answered`, `closed` |
| `conversation_status` | `open`, `archived` |
| `nda_status` | `requested`, `seller_review`, `seller_rejected`, `awaiting_buyer_signature`, `awaiting_seller_signature`, `active`, `revoked`, `expired` |
| `meeting_status` | `requested`, `accepted`, `declined`, `cancelled`, `completed` |
| `offer_status` | `draft`, `submitted`, `countered`, `accepted`, `rejected`, `withdrawn`, `expired` |
| `deal_status` | `initiated`, `due_diligence`, `negotiation`, `agreed`, `closed`, `cancelled` |
| `subscription_status` | `trialing`, `active`, `past_due`, `cancelled`, `expired` |
| `payment_status` | `pending`, `succeeded`, `failed`, `refunded` |
| `notification_channel` | `database`, `mail`, `push`, `sms` |

## Identity

### `users`

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid PK | |
| email | citext unique | |
| email_verified_at | timestamptz null | |
| phone_country_code | varchar(8) null | |
| phone | varchar(20) null | unique with country code when present |
| phone_verified_at | timestamptz null | |
| password | varchar | hashed |
| status | user_status | default `pending` until email verified, then `active` |
| two_factor_secret | text null | staff only, encrypted |
| two_factor_confirmed_at | timestamptz null | |
| last_login_at | timestamptz null | |
| created_at / updated_at / deleted_at | | |

Indexes: unique email; unique `(phone_country_code, phone)`.

### `roles`, `permissions`, `model_has_roles`, `role_has_permissions`

Spatie permission tables. Roles: `buyer`, `seller`, `admin`, `super_admin`.

### `refresh_tokens`

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid PK | |
| user_id | uuid FK users | cascade delete |
| token_hash | char(64) unique | SHA-256 of the secret |
| device_name | varchar(120) | |
| expires_at | timestamptz | |
| revoked_at | timestamptz null | |
| replaced_by_id | uuid null | rotation chain |
| created_at | | |

### `otp_challenges`

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid PK | |
| user_id | uuid null | null for pre-registration phone checks |
| channel | varchar | `email` or `sms` |
| purpose | varchar | `email_verify`, `phone_verify`, `password_reset`, `login` |
| destination | varchar | email or E.164 |
| code_hash | char(64) | |
| attempts | smallint | default 0 |
| expires_at | timestamptz | |
| consumed_at | timestamptz null | |
| created_at | | |

Index: `(destination, purpose, created_at)`.

### `profiles`

One row per user. `user_id` PK/FK. `first_name`, `last_name`, `display_name`, `avatar_path` null, `locale`, `timezone`.

### `buyer_profiles`

`user_id` PK/FK. `buyer_type`, `budget_min_minor`, `budget_max_minor`, `currency`, `verification_status`, `bio`.

### `buyer_industry_preferences`

`buyer_user_id`, `industry_id`. Composite PK.

### `buyer_location_preferences`

`buyer_user_id`, `country_code`, `state` null, `city` null.

### `buyer_business_type_preferences`

`buyer_user_id`, `business_type`. Composite PK.

### `seller_profiles`

`user_id` PK/FK. `verification_status`, `bio`.

### `device_tokens`

`id` uuid, `user_id`, `token` unique, `platform` (`android`, `ios`, `web`), `last_seen_at`.

## Taxonomy

### `industries`

`id` uuid, `parent_id` null self-FK, `name`, `slug` unique, `is_active`. Index: `parent_id`, `slug`.

### `categories`

`id` uuid, `industry_id` FK null, `name`, `slug` unique, `is_active`.

### `locations` (reference, optional seed)

Not required for MVP filtering. Listings store location columns directly. A reference table can be added without changing listing FKs if we later normalize.

## Companies and listings

### `companies`

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid PK | |
| seller_user_id | uuid FK | |
| legal_name | varchar | confidential |
| registration_number | varchar null | confidential |
| year_founded | smallint null | |
| verification_status | verification_status | |
| created_at / updated_at / deleted_at | | |

Index: `seller_user_id`.

### `company_locations`

| Column | Type | Visibility |
| --- | --- | --- |
| id | uuid PK | |
| company_id | uuid FK | |
| country_code | char(2) | public |
| state | varchar | public |
| city | varchar | public |
| postal_code | varchar null | confidential |
| address_line | varchar null | confidential |
| is_primary | boolean | |

Index: `(country_code, state, city)`.

### `listings`

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid PK | |
| company_id | uuid FK | |
| seller_user_id | uuid FK | denormalized owner for policy checks |
| slug | varchar unique | SEO, public, non-identifying |
| title | varchar | public headline, no legal name |
| status | listing_status | default `draft` |
| business_type | business_type | |
| industry_id | uuid FK | |
| asking_price_minor | bigint | public |
| currency | char(3) | |
| revenue_min_minor / revenue_max_minor | bigint null | public range |
| profit_min_minor / profit_max_minor | bigint null | public range |
| ebitda_min_minor / ebitda_max_minor | bigint null | public range |
| years_in_business | smallint null | public |
| employees_min / employees_max | int null | public |
| country_code / state / city | | copied from primary location for filter indexes |
| published_at / submitted_at / expires_at | timestamptz null | |
| reviewed_at | timestamptz null | |
| reviewed_by | uuid null FK users | |
| rejection_reason | text null | seller-visible, not public |
| search_vector | tsvector | public fields only |
| created_at / updated_at / deleted_at | | |

Indexes:

- `(status, published_at desc)`
- `(industry_id, status)`
- `(country_code, state, city, status)`
- `(asking_price_minor)` where published
- `(revenue_max_minor)`, `(profit_max_minor)`, `(ebitda_max_minor)`
- `(business_type, status)`
- GIN `search_vector`
- Partial unique: one row per `company_id` where status not in (`sold`, `rejected`, `expired`) and `deleted_at` is null

`search_vector` is generated from `title` and the public summary only.

### `listing_categories`

`listing_id`, `category_id`. Composite PK.

### `listing_public_profiles`

`listing_id` PK/FK. `summary` text, `highlights` jsonb (array of short strings). Public.

### `listing_registered_profiles`

`listing_id` PK/FK. `detailed_summary` text, `history` text, `operations` text, `revenue_exact_minor` null, `profit_exact_minor` null. Registered buyers, owner, staff.

Exact figures here are still not legal documents. If a seller wants a number to stay confidential, it belongs in `listing_confidential_profiles` or a document, not here.

### `listing_confidential_profiles`

`listing_id` PK/FK. `legal_name_override` null, `notes` text, `customer_overview` text, `supplier_overview` text. NDA-active buyers, owner, staff.

### `listing_media`

`id` uuid, `listing_id`, `s3_key`, `mime`, `size_bytes`, `sort_order`, `alt_text`, `scan_status`. Public images only. Index: `(listing_id, sort_order)`.

### `listing_documents`

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid PK | |
| listing_id | uuid FK | |
| uploaded_by | uuid FK | |
| category | varchar | `financial`, `tax`, `legal`, `license`, `asset`, `other` |
| access_level | document_access_level | |
| original_filename | varchar | hidden when access denied |
| s3_key | varchar | never sent to clients |
| mime | varchar | |
| size_bytes | bigint | |
| scan_status | scan_status | default `pending` |
| created_at | | |

Index: `(listing_id, access_level)`.

## Engagement

### `favorites`

`user_id`, `listing_id`, `created_at`. Composite PK. Index: `user_id`.

### `listing_views`

Bigint PK. `listing_id`, `viewer_user_id` null, `viewed_on` date, `created_at`. Unique `(listing_id, viewer_user_id, viewed_on)` where viewer is not null, to cap counted views. Index: `(listing_id, viewed_on)`.

### `buyer_interests`

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid PK | |
| listing_id | uuid FK | |
| buyer_user_id | uuid FK | |
| status | interest_status | |
| message | text null | |
| decided_at | timestamptz null | |
| decided_by | uuid null | seller |
| created_at / updated_at | | |

Unique `(listing_id, buyer_user_id)`. Index: `(listing_id, status)`, `(buyer_user_id, status)`.

### `inquiries`

`id` uuid, `listing_id`, `buyer_user_id`, `status`, `subject`, `created_at`, `updated_at`. Index: `(listing_id)`, `(buyer_user_id)`.

Inquiry bodies live as the first message in the linked conversation so there is one transcript.

### `conversations`

`id` uuid, `listing_id`, `buyer_user_id`, `seller_user_id`, `inquiry_id` null, `status`, `last_message_at`. Unique `(listing_id, buyer_user_id)`.

### `conversation_participants`

`conversation_id`, `user_id`, `last_read_at`. Composite PK.

### `messages`

`id` uuid, `conversation_id`, `sender_user_id`, `body` text, `created_at`, `deleted_at`. Index: `(conversation_id, created_at)`.

### `message_attachments`

`id` uuid, `message_id`, `s3_key`, `mime`, `size_bytes`, `scan_status`, `original_filename`. Same scan rule as documents. Attachments are visible only to conversation participants.

## Verification and NDA

### `verification_requests`

`id` uuid, `subject_user_id`, `subject_type` (`seller`, `buyer`, `company`), `company_id` null, `status` verification_status, `reviewer_id` null, `decision_notes` text null, `created_at`, `updated_at`. Index: `(status, created_at)`.

### `verification_documents`

`id` uuid, `verification_request_id`, `s3_key`, `mime`, `size_bytes`, `scan_status`, `original_filename`, `category`. Always confidential. Staff and the owning user only.

### `nda_templates`

`id` uuid, `name`, `version`, `body` text, `is_active`, `created_at`. One active template in the MVP.

### `nda_requests`

| Column | Type | Notes |
| --- | --- | --- |
| id | uuid PK | |
| listing_id | uuid FK | |
| buyer_user_id | uuid FK | |
| seller_user_id | uuid FK | |
| template_id | uuid FK | |
| interest_id | uuid null FK | |
| status | nda_status | |
| expires_at | timestamptz null | set when activated |
| created_at / updated_at | | |

Unique open request: one row per `(listing_id, buyer_user_id)` where status not in (`seller_rejected`, `revoked`, `expired`). Index: `(seller_user_id, status)`, `(buyer_user_id, status)`.

### `nda_signatures`

`id` uuid, `nda_request_id`, `signer_user_id`, `signer_role` (`buyer`, `seller`), `method` (`in_app`, `external`), `signed_at`, `ip_address`, `user_agent`, `consent_text_hash`, `external_envelope_id` null. Unique `(nda_request_id, signer_role)`.

### `meeting_requests` (phase 8, table created with later migration)

`id`, `listing_id`, `nda_request_id`, `requested_by`, `status`, `proposed_at`, `notes`. Confidential. Not in the MVP migration set.

## Deals (phase 8)

### `offers`

`id`, `listing_id`, `buyer_user_id`, `amount_minor`, `currency`, `status`, `message`, `created_at`.

### `negotiations`

`id`, `offer_id`, `author_user_id`, `amount_minor`, `message`, `created_at`.

### `deals`

`id`, `listing_id`, `offer_id` null, `buyer_user_id`, `seller_user_id`, `status`, `created_at`, `updated_at`.

These three tables are specified so phase 8 is additive. They are not part of the phase 1 migration.

## Commerce (phase 7)

### `subscription_plans`

`id` uuid, `code` unique, `name`, `audience` (`seller`, `buyer`), `price_minor`, `currency`, `interval` (`month`, `year`), `is_active`.

### `subscriptions`

`id` uuid, `user_id`, `plan_id`, `status`, `provider`, `provider_customer_id`, `provider_subscription_id`, `current_period_ends_at`.

### `payments`

`id` uuid, `user_id`, `subscription_id` null, `amount_minor`, `currency`, `status`, `provider`, `provider_payment_id` unique, `purpose` (`listing_plan`, `featured`, `buyer_subscription`, `other`), `created_at`.

No card numbers, CVV, or full track data.

## Operations

### `notifications`

Laravel notifications table: `id` uuid, `type`, `notifiable`, `data` jsonb, `read_at`, `created_at`. Index: `(notifiable_type, notifiable_id, read_at)`.

### `audit_logs`

Bigint PK. `actor_user_id` null, `action`, `subject_type`, `subject_id` uuid null, `ip_address`, `properties` jsonb, `created_at`. Index: `(subject_type, subject_id)`, `(actor_user_id, created_at)`, `(created_at)`.

`properties` must not contain document file bytes, passwords, OTPs, or raw tokens.

### `document_access_logs`

Bigint PK. `document_type` (`listing_document`, `verification_document`, `message_attachment`), `document_id`, `accessor_user_id`, `listing_id` null, `ip_address`, `created_at`. Written when a signed URL is issued.

## What is public in a listing row

Safe to render on SEO pages and in `/api/v1/listings`: industry, city/state/country, years, revenue range, profit range, EBITDA range, asking price, public summary, highlights, employee range, business type, clean public images, slug, status only if `published` or `under_offer`.

Never selected for those responses: legal name, registration number, postal code, street address, confidential profile, registered profile, document rows above the caller's level, seller email, seller phone, rejection reason.
