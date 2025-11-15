/**
 * Fixtures Playwright pour BrowserStack
 * Crée une session BrowserStack séparée pour chaque test avec son propre nom et logs
 */

const base = require('@playwright/test');
const { chromium } = require('playwright');
const bsConfig = require('./browserstack.config');
const cp = require('child_process');

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
  try {
    const payload = `browserstack_executor: ${JSON.stringify({ action, arguments: args })}`;
    await page.evaluate(() => {}, payload);
  } catch (error) {
    // Ignore silencieusement les erreurs pour ne pas interrompre les tests
  }
};

// Étend les fixtures de base Playwright
const test = base.test.extend({
  // Override du contexte pour créer une session BrowserStack par test
  context: async ({}, use, testInfo) => {
    if (!isBrowserStackRun()) {
      // Mode local: utiliser le contexte par défaut
      const context = await chromium.launchPersistentContext('', {
        headless: false,
      });
      await use(context);
      await context.close();
      return;
    }

    // Mode BrowserStack: créer une session dédiée pour ce test
    const clientPlaywrightVersion = cp.execSync('npx playwright --version').toString().trim().split(' ')[1];
    const testName = formatTestName(testInfo);
    
    const caps = {
      browser: bsConfig.capabilities.browser,
      browser_version: bsConfig.capabilities.browserVersion,
      os: bsConfig.capabilities.os,
      os_version: bsConfig.capabilities.osVersion,
      build: bsConfig.buildName,
      project: bsConfig.projectName,
      name: testName, // Nom unique pour chaque test
      'browserstack.username': bsConfig.username,
      'browserstack.accessKey': bsConfig.accessKey,
      'browserstack.console': bsConfig.capabilities['browserstack.console'],
      'browserstack.networkLogs': bsConfig.capabilities['browserstack.networkLogs'],
      'browserstack.debug': bsConfig.capabilities['browserstack.debug'],
      'browserstack.video': bsConfig.capabilities['browserstack.video'],
      'browserstack.timezone': bsConfig.capabilities['browserstack.timezone'],
      'client.playwrightVersion': clientPlaywrightVersion,
    };

    const wsEndpoint = `wss://cdp.browserstack.com/playwright?caps=${encodeURIComponent(JSON.stringify(caps))}`;
    
    let browser;
    let context;
    
    try {
      // Connexion à BrowserStack via CDP
      browser = await chromium.connectOverCDP(wsEndpoint);
      context = browser.contexts()[0] || await browser.newContext();
      
      await use(context);
      
      // Récupérer le statut du test pour la mise à jour
      const page = context.pages()[0];
      if (page) {
        const isExpected = testInfo.status === 'passed' || testInfo.status === testInfo.expectedStatus;
        const status = isExpected ? 'passed' : 'failed';
        const reason = testInfo.error?.message?.slice(0, 250) || 
          (status === 'passed' ? 'Test passed successfully' : `Test ${testInfo.status}`);
        
        await sendBrowserStackCommand(page, 'setSessionStatus', { status, reason });
      }
    } finally {
      // Nettoyage
      if (context) {
        try { await context.close(); } catch (e) {}
      }
      if (browser) {
        try { await browser.close(); } catch (e) {}
      }
    }
  },
  
  // Override de page pour utiliser le contexte personnalisé
  page: async ({ context }, use) => {
    const page = context.pages()[0] || await context.newPage();
    await use(page);
  },
});

module.exports = { test, expect: base.expect };
