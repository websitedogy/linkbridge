# 7. Flutter screen map

One Flutter app, Android and iOS. Feature folders match the architecture prompt. GoRouter guards send unauthenticated users to login and block seller submit screens until phone verification.

There is no SEO surface. The app uses the same visibility rules as `/app` on the web.

## Routes

| Route | Feature folder | Purpose |
| --- | --- | --- |
| `/` | `home` | Redirect to login or role home. |
| `/login` | `auth` | Login. |
| `/register` | `auth` | Account type, then form. |
| `/verify-email` | `auth` | Email OTP. |
| `/verify-phone` | `auth` | SMS OTP. |
| `/forgot-password` | `auth` | Request reset. |
| `/reset-password` | `auth` | Confirm reset. |
| `/home` | `home` | Role-aware dashboard. |
| `/search` | `search` | Keyword, filters, sort, paged results. |
| `/listings/:id` | `listings` | Detail at the caller's visibility. Save, interest, inquiry, request NDA. |
| `/favorites` | `favorites` | Saved listings. |
| `/buyer/profile` | `buyer` | Profile and preferences. |
| `/buyer/interests` | `inquiries` | Interest list. |
| `/buyer/inquiries` | `inquiries` | Inquiry list. |
| `/seller/profile` | `seller` | Seller profile. |
| `/seller/companies/new` | `companies` | Create company. |
| `/seller/companies/:id` | `companies` | Edit company. |
| `/seller/listings` | `listings` | Own listings. |
| `/seller/listings/new` | `listings` | Create draft. |
| `/seller/listings/:id/edit` | `listings` | Edit, media, documents, submit. |
| `/seller/interests` | `inquiries` | Approve or reject. |
| `/messages` | `messages` | Inbox for the active role. |
| `/messages/:id` | `messages` | Thread and attachments. |
| `/nda` | `nda` | List and sign or decide. |
| `/documents/:listingId` | `documents` | Documents the caller may see. Download opens the signed URL. |
| `/verification` | `profile` | Upload verification files. |
| `/notifications` | `notifications` | In-app list. |
| `/profile` | `profile` | Account, password, role add, logout. |

## Module responsibilities

| Folder | Holds |
| --- | --- |
| `core/network` | Dio client, auth interceptor, refresh-on-401, error mapping to the API `code`. |
| `core/storage` | Secure token storage. |
| `core/routing` | GoRouter and guards. |
| `core/theme` | Shared visual tokens. |
| `features/*/data` | DTO and API calls. |
| `features/*/domain` | Plain models. No business workflow that the API already decides. |
| `features/*/presentation` | Screens and Riverpod notifiers. |

Freezed is used for API response models that have more than a few fields (listing, user, conversation).

## Push

FCM token is registered with `POST /devices` after login and removed on logout. Taps deep-link to the matching screen: message, interest, NDA, listing status.

## Visibility

The listing screen renders sections only when the JSON includes them. It does not guess that confidential data exists. A locked state is shown when the buyer is eligible to request an NDA (approved interest, no active NDA), using the interest and NDA endpoints, not by probing document URLs.
