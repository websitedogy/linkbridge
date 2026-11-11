# 8. Admin panel module map

Laravel Filament, path `/admin`, same Laravel application. Staff must pass TOTP before the panel loads. `admin` and `super_admin` see different navigation from the permission matrix.

The panel calls services. It does not embed a second copy of listing-approval or NDA rules.

## MVP modules (phases 4–6)

| Module | Screens | Who |
| --- | --- | --- |
| Dashboard | Counts: submitted listings, verifications waiting, open interests, failed scans. | admin |
| Users | List, view, suspend, unsuspend. No password display. | admin |
| Buyers | Buyer profile, preferences, verification status. | admin |
| Sellers | Seller profile, companies. | admin |
| Companies | Legal identity, locations, verification. | admin |
| Listings | Queue by status. Open review. Approve, reject, request verification, publish, pause. | admin |
| Industries | CRUD, active flag. | admin |
| Categories | CRUD, active flag. | admin |
| Verification | Queue. Approve, reject, request more information. View documents via signed URL. | admin |
| Documents | Scan failures, access level, access log link. | admin |
| NDA requests | Read-only status across the marketplace for support. Staff do not sign. | admin |
| Interests | Read-only, with the ability to suspend a user from the row. | admin |
| Inquiries and messages | Read-only moderation view. | admin |
| Notifications | Template preview is out of scope. A log of failed notification jobs is enough. | admin |
| Audit logs | Filter by actor, subject, action. | admin |

## Later modules

| Phase | Module |
| --- | --- |
| 7 | Plans, subscriptions, payments (provider ids and status, never card data). |
| 8 | Deals, offers, meetings. |
| 9 | Reports beyond the dashboard counts. |

## Phase 7–9 navigation stays hidden until those tables are in use.

## Settings (super_admin)

| Screen | Contents |
| --- | --- |
| Staff | Invite admin, revoke admin. |
| NDA template | Edit the active template version. Publishing a version does not rewrite signed requests. |
| System | Feature flags for phase 7+ (payments enabled, meetings enabled). |

## Listing review actions

| Action | Resulting status |
| --- | --- |
| Start review | `under_review` |
| Approve | `approved`, then the service publishes immediately in the MVP (`published`) |
| Reject | `rejected` with a reason the seller can read |
| Request verification | `verification_required` with a note |

Approve is refused if the listing has no clean public image or the seller phone is unverified. Those checks live in `ListingReviewService`.

## Audit

Every suspend, listing decision, verification decision, and document open writes `audit_logs`. Document opens also write `document_access_logs`.
