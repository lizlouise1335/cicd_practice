<?php

namespace Tests\Feature;

use Tests\TestCase;

// Replaces the Express test/app.test.ts. Laravel fakes the HTTP request,
// so there is no server to start or stop.
class HealthTest extends TestCase
{
    public function test_health_endpoint_returns_ok(): void
    {
        $this->getJson('/api/health')
            ->assertOk()
            ->assertExactJson(['status' => 'ok']);
    }
}
