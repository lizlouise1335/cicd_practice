// Runs in the browser. Vite compiles this TypeScript to plain JavaScript,
// and the Blade template loads it with @vite(...).

// The shape of the JSON that the PHP route /api/health returns.
// If PHP and TypeScript disagree, this is where you'd update the contract.
export interface HealthResponse {
  status: 'ok';
}

export function isHealthResponse(value: unknown): value is HealthResponse {
  return (
    typeof value === 'object' &&
    value !== null &&
    (value as { status?: unknown }).status === 'ok'
  );
}

async function showHealth(element: HTMLElement): Promise<void> {
  const url = element.dataset.healthUrl ?? '/api/health';

  try {
    const response = await fetch(url, { headers: { Accept: 'application/json' } });
    const body: unknown = await response.json();

    element.textContent =
      response.ok && isHealthResponse(body) ? '✅ Server healthy' : '⚠️ Server unhealthy';
  } catch {
    element.textContent = '❌ Could not reach the server';
  }
}

const healthElement = document.getElementById('health-status');

if (healthElement) {
  void showHealth(healthElement);
}
