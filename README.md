# CI/CD Lab (Laravel + TypeScript)

The CI/CD Crash Course lab, rebuilt with a **PHP (Laravel) backend** and a **TypeScript frontend**.

- `main` branch: the original Express + TypeScript version that follows the course.
- `laravel` branch: this version.

## How the pieces fit

| Part | Language | Where | Runs on |
|---|---|---|---|
| Routes, pages, API | PHP (Laravel 13) | `routes/web.php`, `resources/views/` | Server |
| Interactive frontend | TypeScript | `resources/js/app.ts` | Browser (compiled by Vite) |
| Backend tests | PHP (PHPUnit) | `tests/Feature/` | `php artisan test` |
| Frontend checks | TypeScript / Vite | `tsconfig.json`, `vite.config.js` | `npm run verify` |

The home page is rendered by PHP. Then `app.ts` calls `/api/health` from the browser and shows whether the server is healthy.

## Requirements

- PHP 8.3+ (CI uses 8.5) and Composer
- Node.js 24 and npm
- Git

On macOS: `brew install php composer node`

## Get started

```bash
composer install            # PHP packages -> vendor/
npm ci                      # JS packages  -> node_modules/
cp .env.example .env        # local settings (never committed)
php artisan key:generate    # creates APP_KEY in .env
npm run build               # compile TypeScript + CSS
php artisan serve           # http://localhost:8000
```

The [health endpoint](http://localhost:8000/api/health) returns `{"status":"ok"}`.

For live frontend reloading during development, run `npm run dev` in a second terminal alongside `php artisan serve`.

## Scripts

| Command | What it does |
|---|---|
| `php artisan serve` | Start the PHP development server |
| `php artisan test` | Run the backend tests |
| `npm run dev` | Vite dev server with hot reload for TS/CSS |
| `npm run typecheck` | Check TypeScript types |
| `npm run build` | Compile TS/CSS into `public/build` |
| `npm run verify` | Typecheck + build (what CI runs for the frontend) |

## CI

`.github/workflows/ci.yml` runs on pushes and pull requests to `main`, and on pushes to `laravel`:

1. Set up PHP, restore the Composer cache, `composer install`
2. Create `.env` and a throwaway `APP_KEY`
3. Set up Node (with npm cache), `npm ci`, `npm run verify`
4. `php artisan test`

## Configuration

| Variable | Default | Used for |
|---|---|---|
| `APP_VERSION` | `development` | Shown on the home page |
| `APP_KEY` | *(none)* | Laravel's encryption key. Generate with `php artisan key:generate` |
| `APP_URL` | `http://localhost:8000` | Base URL Laravel uses when building links |

Keep `composer.lock` and `package-lock.json` committed. `vendor/`, `node_modules/`, `public/build/`, and `.env` are excluded by `.gitignore`.
