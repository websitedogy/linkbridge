# LinksBridge architecture

The implementation contract is in [docs/architecture](docs/architecture/README.md).

This file records the repository layout used by the development environment. Application folders are:

```text
backend/    Laravel API
web/        Next.js
mobile/     Flutter (Android and iOS)
docs/       Architecture documents
```

Web and mobile talk to the Laravel API only. Business rules stay in the backend.

Do not add buyer, seller, listing, messaging, payment, NDA, or admin features until the next phase. The apps in this repository are installed toolchains, not product screens.
