<?php

use Illuminate\Support\Facades\Route;

// Home page. Laravel renders resources/views/home.blade.php on the server
// and passes it the app version (config/app.php reads APP_VERSION).
Route::get('/', function () {
    return view('home', [
        'version' => config('app.version'),
    ]);
});

// Health check used by CI tests, the deploy platform, and the TypeScript
// frontend. Returning a PHP array makes Laravel send it as JSON.
Route::get('/api/health', function () {
    return ['status' => 'ok'];
});
