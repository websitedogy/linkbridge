# LinksBridge

Business acquisition marketplace. This repository currently contains the architecture and a verified development environment. Product features are not implemented yet.

Architecture: [docs/architecture](docs/architecture/README.md) and [architecture.md](architecture.md).

## Layout

```text
backend/    Laravel 13 API
web/        Next.js
mobile/     Flutter (Android and iOS)
docs/       Architecture
scripts/    Local PostgreSQL and Redis
```

## Start local services

These commands were run successfully on this machine. PostgreSQL and Redis are already running after setup.

```text
PostgreSQL:
powershell -File scripts/postgres.ps1

Redis:
powershell -File scripts/redis.ps1
```

PostgreSQL uses the already installed 18 binaries with a project-local data directory on `127.0.0.1:5434`. The database name and user are `linksbridge`. The password is in `backend/.env` (`DB_PASSWORD`). System clusters on ports 5432 and 5433 were left unchanged.

Redis 8.10.2 listens on `127.0.0.1:6379`. It is a user process, not a Windows service.

Open a new terminal before using `php` or `composer`. Both were added to the user PATH.

## Start the applications

```text
Backend:
cd backend
php artisan serve
```

Verified: `http://127.0.0.1:8000/up` returns 200. `GET /api/user` without a token returns 401.

`composer run dev` is defined by Laravel and also starts the queue listener, logs, and Vite. It was not used for verification. The API does not need the Vite dev server.

```text
Web:
cd web
npm run dev
```

Verified: the dev server became ready and `GET /` returned 200. If port 3000 is already taken, Next.js picks the next free port.

```text
Mobile:
cd mobile
flutter run
```

Verified in this session: `flutter analyze`, `flutter test`, and `flutter build apk --debug`. An interactive `flutter run` session was not left running. iOS cannot be compiled on Windows.

## Checks

```text
cd backend
php artisan test
vendor/bin/pint --test
vendor/bin/phpstan analyse --memory-limit=512M

cd web
npm run typecheck
npm run lint

cd mobile
flutter analyze
flutter test
```

Migrations have not been run. The LinksBridge schema is not created yet.
