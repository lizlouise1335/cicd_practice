<?php

namespace Tests\Feature;

use Tests\TestCase;

class HomePageTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        // The page includes Vite-built assets. Skip them so PHP tests
        // don't depend on running `npm run build` first.
        $this->withoutVite();
    }

    public function test_home_page_shows_default_version(): void
    {
        $this->get('/')
            ->assertOk()
            ->assertSee('CI/CD Lab')
            ->assertSee('Version development');
    }

    public function test_home_page_shows_configured_version(): void
    {
        config(['app.version' => '1.2.3']);

        $this->get('/')
            ->assertOk()
            ->assertSee('Version 1.2.3');
    }
}
