const { test, expect } = require('../test-fixtures');

test('sanity test', async ({ page }) => {
  // Simple test to verify Playwright detection
  await page.goto('/');
  expect(1 + 1).toBe(2);
});

test.afterEach(async ({ page }) => {
  try { await page.context().close(); } catch (e) {}
});
