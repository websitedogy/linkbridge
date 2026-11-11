# 9–14. Flows

Statuses are the database values. Clients display them in uppercase labels.

## 9. Authentication

```mermaid
sequenceDiagram
  actor User
  participant Client as Web or Flutter
  participant API as Laravel
  participant Mail as SES
  participant SMS as SmsSender

  User->>Client: Register as buyer or seller
  Client->>API: POST /auth/register
  API->>Mail: Email OTP
  API-->>Client: 201 pending
  User->>Client: Email code
  Client->>API: POST /auth/email/verify
  API-->>Client: access and refresh tokens
  Client->>API: POST /auth/phone/resend
  API->>SMS: SMS OTP
  Client->>API: POST /auth/phone/verify
  Note over API: Seller listing submit stays blocked until phone_verified_at is set
```

Login loads the user, checks `status` is `active`, verifies the password, writes an auth audit row, and returns a 15-minute access token plus a 30-day refresh token. Refresh revokes the presented refresh token and issues a new pair. Reuse of a revoked refresh token revokes the whole rotation chain for that device.

Logout revokes the current refresh token and the Sanctum access token.

Password reset always responds 200 on the request step so accounts cannot be enumerated. The code is hashed. Five bad attempts burn it.

Staff login is Filament, not `/api/v1/auth/login`. Staff without confirmed TOTP cannot open the panel.

## 10. Buyer

```mermaid
flowchart TD
  A[Register and verify email] --> B[Buyer profile and preferences]
  B --> C[Search and open a public listing]
  C --> D[Save favorite]
  C --> E[Open registered detail in the app]
  E --> F[Express interest]
  F --> G{Seller decision}
  G -->|Rejected| H[Interest closed]
  G -->|Approved| I[Send inquiry and messages]
  I --> J[Request NDA]
  J --> K[Sign after seller approval]
  K --> L[Read confidential information]
```

A buyer does not message a seller until an inquiry exists. An NDA cannot be requested until the interest is `approved`. The buyer never receives the seller's email or phone.

## 11. Seller

```mermaid
flowchart TD
  A[Register, verify email and phone] --> B[Seller profile]
  B --> C[Create company with legal identity]
  C --> D[Create listing draft]
  D --> E[Public summary, ranges, price, images]
  E --> F[Optional registered and confidential text]
  F --> G[Upload documents with an access level]
  G --> H[Submit]
  H --> I{Admin review}
  I -->|Rejected| D
  I -->|Need verification| J[Upload verification documents]
  J --> H
  I -->|Published| K[Receive interests]
  K --> L[Approve or reject buyers]
  L --> M[Answer inquiries]
  M --> N[Decide NDA and sign]
  N --> O[Pause, or later mark sold]
```

Legal name and street address are stored on the company and are not copied into the public listing resource.

## 12. Listing approval

```mermaid
stateDiagram-v2
  [*] --> draft
  draft --> submitted: seller submits
  submitted --> under_review: admin starts review
  under_review --> approved: admin approves
  approved --> published: service publishes
  under_review --> verification_required: admin asks for evidence
  verification_required --> submitted: seller resubmits
  under_review --> rejected: admin rejects
  rejected --> draft: seller edits
  published --> paused: seller or admin pauses
  paused --> published: seller resumes
  published --> expired: scheduler after expires_at
  published --> sold: later phase
  expired --> [*]
  sold --> [*]
```

Public `GET /listings` returns rows in `published` or `under_offer` only. `under_offer` is unused until phase 8. `approved` is transient inside the approve transaction so clients rarely observe it.

`expires_at` is set to 90 days after publish in the MVP. The scheduler moves due rows to `expired` and notifies the seller.

## 13. NDA

```mermaid
stateDiagram-v2
  [*] --> seller_review: buyer requests after approved interest
  seller_review --> seller_rejected: seller rejects
  seller_review --> awaiting_buyer_signature: seller approves
  awaiting_buyer_signature --> awaiting_seller_signature: buyer signs
  awaiting_seller_signature --> active: seller signs
  active --> expired: expires_at passes
  active --> revoked: later, seller or staff
  seller_rejected --> [*]
  expired --> [*]
```

On the transition to `active`, `NdaActivated` is dispatched. Listeners notify both parties. Confidential resources start including data on the next request. No cache of a public listing payload is reused for that buyer.

The signature row stores the hash of the template body the user saw, the time, IP, and user agent. `method = in_app` in the MVP. `external_envelope_id` is reserved for the future provider. Replacing the provider does not change `nda_requests.status`.

A rejected or expired NDA does not leave confidential access in place. Access is computed from current status, not from a sticky boolean on the user.

## 14. Document permissions

```mermaid
flowchart TD
  A[Client asks to download a document] --> B{Authenticated?}
  B -->|No| C[401]
  B -->|Yes| D{Policy allows this access level?}
  D -->|No| E[403 CONFIDENTIAL_LOCKED]
  D -->|Yes| F{scan_status is clean?}
  F -->|No| G[409 not available]
  F -->|Yes| H[Write document_access_logs]
  H --> I[Return 5-minute signed S3 URL]
  I --> J[Client fetches bytes from S3]
```

| Access level | Who can download |
| --- | --- |
| `public` | Any authenticated user, and the public listing media path for images uses the same scanner and signed URLs. Guest image URLs are signed by the server while rendering public JSON. |
| `registered` | Verified-email buyer, listing seller, staff. |
| `confidential` | Buyer with an active unexpired NDA for that listing, listing seller, staff. |

S3 bucket policy denies public `GetObject`. Keys are never returned. Filenames of confidential documents are omitted from JSON when the policy fails, because the list endpoint filters rows before serialization.

Upload path: validate extension, MIME, and size; store in a pending prefix; enqueue scan; set `clean` or `rejected`. A rejected object cannot be downloaded and is deleted by a daily job.

Message attachments use this same gate, with the added rule that the caller must be a conversation participant.
