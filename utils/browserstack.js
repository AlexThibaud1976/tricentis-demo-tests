const MAX_REASON_LENGTH = 250;

function isBrowserStackRun() {
  return Boolean(process.env.BROWSERSTACK_USERNAME && process.env.BROWSERSTACK_ACCESS_KEY);
}

function getTitlePathArray(testInfo) {
  if (!testInfo) return ['(unknown)'];
  // Support both Playwright versions: titlePath() function or titlePath array
  try {
    if (typeof testInfo.titlePath === 'function') return testInfo.titlePath();
    if (Array.isArray(testInfo.titlePath)) return testInfo.titlePath;
    if (Array.isArray(testInfo.titlePath && testInfo.titlePath())) return testInfo.titlePath();
  } catch (e) {
    // ignore
  }
  // Fallbacks
  if (typeof testInfo.title === 'string') return [testInfo.title];
  return ['(unknown)'];
}

function formatTestName(testInfo) {
  const titlePath = getTitlePathArray(testInfo);
  // Remove file name (first element) if present
  const parts = titlePath.slice(1);
  return parts.length ? parts.join(' › ') : titlePath.join(' › ');
}

async function sendExecutorCommand(page, action, args) {
  try {
    await page.evaluate(() => {}, `browserstack_executor: ${JSON.stringify({ action, arguments: args })}`);
  } catch (error) {
    // Ne pas interrompre le test si BrowserStack n'est pas disponible
    console.warn(`[BrowserStack] ${action} failed: ${error.message}`);
  }
}

async function markTestStart(page, testInfo) {
  if (!isBrowserStackRun()) {
    return;
  }
  await sendExecutorCommand(page, 'setSessionName', { name: formatTestName(testInfo) });
}

async function markTestResult(page, testInfo) {
  if (!isBrowserStackRun()) {
    return;
  }

  const isExpected = testInfo.status === 'passed' || testInfo.status === testInfo.expectedStatus;
  const status = isExpected ? 'passed' : 'failed';
  const defaultReason = status === 'passed' ? 'Test completed successfully' : `Test ${testInfo.status}`;
  const reason = (testInfo.error?.message || defaultReason).slice(0, MAX_REASON_LENGTH);

  await sendExecutorCommand(page, 'setSessionStatus', {
    status,
    reason,
  });
}

module.exports = { markTestStart, markTestResult, isBrowserStackRun };
