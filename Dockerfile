# =====================================================================
# Builds a container image that runs the Laravel app anywhere Docker
# runs: your Mac, Render, or any cloud.
#
# It's a MULTI-STAGE build:
#   Stage 1 "assets" uses Node to compile the TypeScript + CSS.
#   Stage 2 "app" is PHP + Apache. It copies in only the built files,
#   so the final image has no Node and no node_modules.
#
# Build:  docker build -t cicd-lab .
# Run:    docker run -p 8080:8080 -e APP_KEY=base64:... cicd-lab
# =====================================================================

# ---------- Stage 1: build the TypeScript frontend with Node ----------
FROM node:24-alpine AS assets
WORKDIR /app

# Copy only the package files first. Docker caches each step, so if
# these files haven't changed, the slow "npm ci" is reused from cache
# (the same idea as "cache: npm" in CI).
COPY package.json package-lock.json .npmrc ./
RUN npm ci

# Now copy what Vite needs and build into public/build.
COPY vite.config.js tsconfig.json ./
COPY resources ./resources
RUN npm run typecheck && npm run build


# ---------- Stage 2: the PHP server that actually runs ----------
FROM php:8.5-apache AS app

# Composer needs unzip to install packages. Clean up apt's cache after
# so the image stays small.
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/*

# Borrow the Composer program from its official image.
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Apache setup:
#  - serve the public/ folder (never the whole project, so .env-style
#    files and source code can't be reached from the web)
#  - enable mod_rewrite + .htaccess so every URL goes to public/index.php
#  - listen on $PORT, which Render sets (defaults to 8080 below)
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri 's!AllowOverride None!AllowOverride All!g' /etc/apache2/apache2.conf \
    && sed -ri 's!^Listen 80$!Listen ${PORT}!' /etc/apache2/ports.conf \
    && sed -ri 's!<VirtualHost \*:80>!<VirtualHost *:${PORT}>!' /etc/apache2/sites-available/000-default.conf \
    && a2enmod rewrite

WORKDIR /var/www/html

# PHP packages first (cached unless composer.lock changes).
# --no-dev skips test-only packages like PHPUnit. --no-scripts waits
# until the app code is copied in, because Laravel's scripts need it.
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --no-progress --no-scripts --no-autoloader

# The app code, then the compiled frontend from stage 1.
COPY . .
COPY --from=assets /app/public/build ./public/build

# Finish Composer now that the code is here: build an optimized class
# map and run Laravel's package discovery.
RUN composer dump-autoload --optimize --no-dev \
    && php artisan package:discover \
    && chown -R www-data:www-data storage bootstrap/cache

# Production settings. APP_KEY is NOT here: it's a secret, so you pass
# it when the container starts (docker run -e, or Render's env vars).
# This app has no database, so sessions use cookies and cache uses files
# instead of Laravel's database defaults.
ENV PORT=8080 \
    APP_ENV=production \
    APP_DEBUG=false \
    LOG_CHANNEL=stderr \
    SESSION_DRIVER=cookie \
    CACHE_STORE=file \
    APP_VERSION=development

EXPOSE 8080

# The php:apache image's default command starts Apache in the foreground.
