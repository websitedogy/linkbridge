# 6. Website page map

Next.js App Router. Public marketing and listing pages are server-rendered and indexable. Everything under `/app` is authenticated, `noindex`, and omitted from the sitemap.

## Public, indexable

| Path | Purpose | Data |
| --- | --- | --- |
| `/` | Marketplace home. Search entry, featured industries. | Public listing sample, industries. |
| `/businesses` | Filterable directory. | `GET /search/listings`. |
| `/businesses/[slug]` | Listing detail. | `GET /listings/slug/{slug}`. Public resource only, even if the visitor has a session. A signed-in buyer follows a link into the app for registered detail. |
| `/industries/[slug]` | Industry landing. | Search constrained to that industry. |
| `/locations/[country]/[region]` | Location landing, only for regions with listings. | Search constrained to location. |
| `/for-buyers` | How buying works. | Static. |
| `/for-sellers` | How selling works. | Static. |
| `/pricing` | Plan overview. Copy only until phase 7. | Static. |
| `/about` | Company. | Static. |
| `/contact` | Contact form to mail, no CRM in MVP. | — |
| `/legal/terms` | Terms. | Static. |
| `/legal/privacy` | Privacy. | Static. |
| `/sitemap.xml` | Listings, industries, static pages. | Public slugs. |
| `/robots.txt` | Allow public paths. Disallow `/app`, `/login`, `/register`. | — |

Listing URL shape: `/businesses/hyderabad-manufacturing-company-for-sale`. Slug is generated from city, industry, and a short unique suffix. It does not contain the legal name.

Each public listing page sets title, meta description, canonical URL, Open Graph, Twitter card, and `Business`/`Offer` JSON-LD using only public fields. No seller name, no street address.

## Auth

| Path | Purpose |
| --- | --- |
| `/login` | Email and password. |
| `/register` | Choose buyer or seller, then the form. |
| `/verify-email` | Enter email code. |
| `/verify-phone` | Enter SMS code. Sellers are blocked from submit until this succeeds. |
| `/forgot-password` | Request code. |
| `/reset-password` | New password. |

These pages are `noindex`.

## Authenticated app

Shared shell: navigation, notification bell, role switcher if the user has both buyer and seller.

### Buyer

| Path | Purpose |
| --- | --- |
| `/app/buyer` | Dashboard: interests, unread messages. |
| `/app/buyer/profile` | Budget, type, bio. |
| `/app/buyer/preferences` | Industries, locations, business types. |
| `/app/buyer/saved` | Favorites. |
| `/app/buyer/interests` | Interest status list. |
| `/app/buyer/inquiries` | Inquiry list. |
| `/app/buyer/messages` | Inbox. |
| `/app/buyer/messages/[id]` | Thread. |
| `/app/buyer/nda` | NDA requests and sign action. |
| `/app/buyer/listings/[id]` | Registered and, when unlocked, confidential detail. Not the SEO page. |
| `/app/buyer/notifications` | In-app notifications. |
| `/app/buyer/verification` | Buyer verification upload. |

### Seller

| Path | Purpose |
| --- | --- |
| `/app/seller` | Dashboard: listing status, pending interests. |
| `/app/seller/profile` | Seller profile. |
| `/app/seller/companies/new` | Create company. |
| `/app/seller/companies/[id]` | Edit company. |
| `/app/seller/listings` | Own listings. |
| `/app/seller/listings/new` | Create draft. |
| `/app/seller/listings/[id]/edit` | Edit while the status allows it. |
| `/app/seller/listings/[id]` | Owner view, including rejection reason. |
| `/app/seller/interests` | Approve or reject. |
| `/app/seller/inquiries` | Incoming inquiries. |
| `/app/seller/messages` | Inbox. |
| `/app/seller/messages/[id]` | Thread. |
| `/app/seller/nda` | Approve, reject, sign. |
| `/app/seller/verification` | Identity and company documents. |
| `/app/seller/notifications` | In-app notifications. |

### Account

| Path | Purpose |
| --- | --- |
| `/app/account` | Name, avatar, password, add the other marketplace role. |
| `/app/account/devices` | Push token is mobile-only; this page explains notification email preferences later. |

## SEO rules

- Public detail pages call the unauthenticated listing endpoint from the server so a logged-in seller testing the marketing URL cannot leak confidential fields into HTML.
- Registered and confidential views exist only under `/app`.
- Image `alt` text is the public title, not a legal name.
- Pagination on `/businesses` uses crawlable links, not button-only paging.
