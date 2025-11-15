/**
 * Fixtures Playwright pour BrowserStack
 * Gère automatiquement le nom et le statut des tests sans modifier les fichiers de tests
 */

const base = require('@playwright/test');
const bsConfig = require('./browserstack.config');

// Vérifie si BrowserStack est configuré
const isBrowserStackRun = () => {
  return Boolean(bsConfig.username && bsConfig.accessKey);
};

// Formatte le nom complet du test
const formatTestName = (testInfo) => {
  const titlePath = Array.isArray(testInfo.titlePath) 
    ? testInfo.titlePath 
    : typeof testInfo.titlePath === 'function' 
      ? testInfo.titlePath() 
      : [testInfo.title || 'Unknown Test'];
  
  // Enlève le nom du fichier (premier élément)
  return titlePath.slice(1).join(' › ');
};

// Envoie une commande à l'executor BrowserStack
const sendBrowserStackCommand = async (page, action, args) => {
  if (!isBrowserStackRun()) return;
  
  try {
    const payload = `browserstack_executor: ${JSON.stringify({ action, arguments: args })}`;
    await page.evaluate(() => {}, payload);
  } catch (error) {
    // Ignore silencieusement les erreurs pour ne pas interrompre les tests
  }
};

// Étend les fixtures de base Playwright
const test = base.test.extend({
  page: async ({ page }, use, testInfo) => {
    // Avant le test: définir le nom de la session
    if (isBrowserStackRun()) {
      const testName = formatTestName(testInfo);
      await sendBrowserStackCommand(page, 'setSessionName', { name: testName });
    }

    // Exécuter le test
    await use(page);

    // Après le test: mettre à jour le statut
    if (isBrowserStackRun()) {
      const isExpected = testInfo.status === 'passed' || testInfo.status === testInfo.expectedStatus;
      const status = isExpected ? 'passed' : 'failed';
      const reason = testInfo.error?.message?.slice(0, 250) || 
        (status === 'passed' ? 'Test passed successfully' : `Test ${testInfo.status}`);
      
      await sendBrowserStackCommand(page, 'setSessionStatus', { status, reason });
    }
  },
});

module.exports = { test, expect: base.expect };
