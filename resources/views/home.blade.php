<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ config('app.name') }}</title>

    {{-- Loads the CSS and the compiled TypeScript that Vite builds --}}
    @vite(['resources/css/app.css', 'resources/js/app.ts'])
</head>
<body class="font-sans p-8">
    {{-- Everything in this file is rendered by PHP on the server --}}
    <h1 class="text-2xl font-semibold">CI/CD Lab</h1>
    <p>The application is running.</p>
    <p>Version {{ $version }}</p>

    {{-- Filled in by TypeScript in the browser (resources/js/app.ts) --}}
    <p id="health-status" data-health-url="/api/health">Checking server health…</p>
</body>
</html>
