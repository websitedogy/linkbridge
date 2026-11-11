# 4. Roles and permissions

Authorization is enforced in Laravel Policies and, for admin screens, Filament authorization. A role on the client only changes which screens render.

## Roles

| Role | Who | Account rule |
| --- | --- | --- |
| `buyer` | Acquirer or investor | May combine with `seller` |
| `seller` | Business owner listing a company | May combine with `buyer` |
| `admin` | Operations staff | Staff account. Cannot also be buyer or seller. |
| `super_admin` | Platform owner | Staff account. Manages admins and settings. |

New marketplace users receive `buyer` or `seller` from the registration path they chose. They may add the other role later from account settings. Staff accounts are created only by `super_admin`.

`user.status = suspended` denies every authenticated action except logout and reading the suspension message.

Email must be verified before creating a company, listing, interest, inquiry, or NDA. Phone verification is required before seller submission of a listing for review.

## Permission keys

Format: `{area}.{action}`.

### Marketplace

| Key | buyer | seller | admin | super_admin |
| --- | --- | --- | --- | --- |
| listings.public.view | yes (guest too) | yes | yes | yes |
| listings.registered.view | yes | own only | yes | yes |
| listings.confidential.view | NDA active only | own only | yes | yes |
| listings.create | no | yes | no | no |
| listings.update | no | own draft, rejected, or verification_required | no | no |
| listings.submit | no | own | no | no |
| listings.pause | no | own published | yes | yes |
| listings.review | no | no | yes | yes |
| favorites.manage | yes | yes | no | no |
| interests.create | yes | no | no | no |
| interests.decide | no | own listings | yes | yes |
| inquiries.create | yes | no | no | no |
| messages.participate | participant | participant | read for moderation | read |
| documents.upload | no | own listing | no | no |
| documents.download | by access level | own listing | yes | yes |
| nda.request | yes | no | no | no |
| nda.decide | no | own listing | no | no |
| nda.sign | party to the request | party to the request | no | no |
| verification.submit | own buyer file | own seller and company file | no | no |
| verification.decide | no | no | yes | yes |
| users.suspend | no | no | yes | yes |
| admins.manage | no | no | no | yes |
| settings.manage | no | no | no | yes |
| payments.manage | no | no | yes | yes |
| audit.view | no | no | yes | yes |

Seller actions apply only to companies and listings where `seller_user_id` is the caller. A seller cannot express interest in their own listing.

## Policy map

| Model | Methods |
| --- | --- |
| Listing | `viewPublic`, `viewRegistered`, `viewConfidential`, `create`, `update`, `submit`, `pause`, `review` |
| ListingDocument | `view`, `download`, `upload`, `delete` |
| BuyerInterest | `create`, `view`, `decide` |
| Inquiry / Conversation / Message | `view`, `create`, `reply` |
| NdaRequest | `request`, `view`, `approve`, `reject`, `sign` |
| VerificationRequest | `submit`, `view`, `decide` |
| User | `suspend`, `assignStaffRole` |

`viewConfidential` is true when any of these hold:

- caller is the listing seller
- caller is `admin` or `super_admin`
- an `nda_requests` row exists for this listing and caller with status `active` and `expires_at` in the future

## Admin granularity

Filament shield (or an equivalent permission sync) maps the keys above onto admin navigation. `admin` can review listings, verification, users, interests, and audit logs. `admin` cannot create other admins, change payment provider keys, or edit system settings. `super_admin` can.

Admin document access is allowed and is written to `document_access_logs` and `audit_logs`.

## Field visibility matrix

| Field group | Guest | Buyer, no NDA | Buyer, active NDA | Seller owner | Staff |
| --- | --- | --- | --- | --- | --- |
| Public listing card and summary | yes | yes | yes | yes | yes |
| Registered profile and exact registered financials | no | yes | yes | yes | yes |
| Confidential profile | no | no | yes | yes | yes |
| Public images | yes | yes | yes | yes | yes |
| Registered documents | no | yes | yes | yes | yes |
| Confidential documents | no | no | yes | yes | yes |
| Seller email and phone | no | no | no | self | yes |
| Buyer email and phone | no | self | self | no | yes |

Seller contact details stay hidden from buyers after an NDA. Communication stays inside conversations. Staff can see contact details for moderation and verification.
