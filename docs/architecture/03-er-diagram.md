# 2. Database ER diagram

UUIDs mark entities clients can address. Crow's-foot is shown in Mermaid. Log tables (`listing_views`, `audit_logs`, `document_access_logs`) are append-only and omitted from the diagrams for readability. Phase 8 deal tables are in the last diagram.

## Identity and profiles

```mermaid
erDiagram
  users ||--o| profiles : has
  users ||--o| buyer_profiles : has
  users ||--o| seller_profiles : has
  users ||--o{ refresh_tokens : has
  users ||--o{ device_tokens : has
  users }o--o{ roles : assigned
  buyer_profiles ||--o{ buyer_industry_preferences : prefers
  buyer_profiles ||--o{ buyer_location_preferences : prefers
  buyer_profiles ||--o{ buyer_business_type_preferences : prefers
  industries ||--o{ buyer_industry_preferences : targeted_by

  users {
    uuid id PK
    string email UK
    string status
  }
  roles {
    string name UK
  }
  buyer_profiles {
    uuid user_id PK
    string buyer_type
    string verification_status
  }
  seller_profiles {
    uuid user_id PK
    string verification_status
  }
```

## Companies and listings

```mermaid
erDiagram
  users ||--o{ companies : owns
  companies ||--o{ company_locations : located
  companies ||--o{ listings : listed_as
  users ||--o{ listings : sells
  industries ||--o{ listings : classifies
  listings }o--o{ categories : tagged
  listings ||--|| listing_public_profiles : shows
  listings ||--o| listing_registered_profiles : expands
  listings ||--o| listing_confidential_profiles : protects
  listings ||--o{ listing_media : images
  listings ||--o{ listing_documents : files
  industries ||--o{ categories : contains

  listings {
    uuid id PK
    string slug UK
    string status
    bigint asking_price_minor
  }
  listing_documents {
    uuid id PK
    string access_level
    string scan_status
  }
```

## Interest, inquiry, messages

```mermaid
erDiagram
  listings ||--o{ favorites : saved_by
  users ||--o{ favorites : saves
  listings ||--o{ buyer_interests : receives
  users ||--o{ buyer_interests : expresses
  listings ||--o{ inquiries : receives
  users ||--o{ inquiries : asks
  inquiries ||--o| conversations : opens
  listings ||--o{ conversations : about
  conversations ||--o{ conversation_participants : includes
  users ||--o{ conversation_participants : joins
  conversations ||--o{ messages : contains
  messages ||--o{ message_attachments : has
```

## Verification and NDA

```mermaid
erDiagram
  users ||--o{ verification_requests : submits
  companies ||--o{ verification_requests : subject
  verification_requests ||--o{ verification_documents : evidence
  nda_templates ||--o{ nda_requests : used_by
  listings ||--o{ nda_requests : gates
  users ||--o{ nda_requests : buyer
  buyer_interests ||--o{ nda_requests : follows
  nda_requests ||--o{ nda_signatures : signed
```

## Commerce and deals (later phases)

```mermaid
erDiagram
  subscription_plans ||--o{ subscriptions : offers
  users ||--o{ subscriptions : holds
  subscriptions ||--o{ payments : billed
  users ||--o{ payments : pays
  listings ||--o{ offers : receives
  offers ||--o{ negotiations : revises
  offers ||--o| deals : becomes
  listings ||--o{ deals : tracks
```

## Visibility dependency

Confidential profile rows and `access_level = confidential` documents are readable only when an `nda_requests` row for that listing and buyer is `active`, or the caller is the selling user, or the caller is staff. That rule is enforced in policies, not by a database grant.
