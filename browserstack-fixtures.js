/**
 * Fixtures Playwright pour BrowserStack
 * Crée une session BrowserStack séparée pour chaque test avec son propre nom et logs
 */

const base = require('@playwright/test');
const { chromium } = require('playwright');
const bsConfig = require('./browserstack.config');
const cp = require('child_process');

// Compteur global pour rendre chaque session unique
let sessionCounter = 0;

// Vérifie si BrowserStack est configuré
const isBrowserStackRun = () => {
  return Boolean(bsConfig.username && bsConfig.accessKey);
};

// Formatte le nom complet du test avec un ID unique
const formatTestName = (testInfo, sessionId) => {
  const titlePath = Array.isArray(testInfo.titlePath) 
    ? testInfo.titlePath 
    : typeof testInfo.titlePath === 'function' 
      ? testInfo.titlePath() 
      : [testInfo.title || 'Unknown Test'];
  
  // Enlève le nom du fichier (premier élément) et ajoute un ID unique
  const testName = titlePath.slice(1).join(' › ');
  return `[${sessionId}] ${testName}`;
};

// Envoie une commande à l'executor BrowserStack
const sendBrowserStackCommand = async (page, action, args) => {
  try {
    const payload = `browserstack_executor: ${JSON.stringify({ action, arguments: args })}`;
    await page.evaluate(() => {}, payload);
    console.log(`[BrowserStack] ${action} executed successfully`);
  } catch (error) {
    console.warn(`[BrowserStack] ${action} failed:`, error.message);
  }
};

// Étend les fixtures de base Playwright
const test = base.test.extend({
  // Override du contexte pour créer une session BrowserStack par test
  context: async ({}, use, testInfo) => {
    if (!isBrowserStackRun()) {
      // Mode local: utiliser le contexte par défaut de Playwright
      const browser = await chromium.launch({ headless: false });
      const context = await browser.newContext();
      await use(context);
      await context.close();
      await browser.close();
      return;
    }

    // Mode BrowserStack: créer une session dédiée pour ce test
    const clientPlaywrightVersion = cp.execSync('npx playwright --version').toString().trim().split(' ')[1];
    const sessionId = `S${++sessionCounter}`;
    const testName = formatTestName(testInfo, sessionId);
    
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
      console.log(`[BrowserStack] Connecting session ${sessionId} for test: ${testInfo.title}`);
      
      // Connexion à BrowserStack via CDP
      browser = await chromium.connectOverCDP(wsEndpoint);
      
      // Récupérer ou créer le contexte
      const contexts = browser.contexts();
      context = contexts.length > 0 ? contexts[0] : await browser.newContext();
      
      // Attendre que le contexte soit prêt
      await context.pages()[0]?.waitForLoadState('domcontentloaded').catch(() => {});
      
      // Utiliser le contexte dans le test
      await use(context);
      
      // Après le test: mettre à jour le statut
      console.log(`[BrowserStack] Test ${sessionId} finished with status: ${testInfo.status}`);
      
      const pages = context.pages();
      if (pages.length > 0 && !pages[0].isClosed()) {
        const page = pages[0];
        const isExpected = testInfo.status === 'passed' || testInfo.status === testInfo.expectedStatus;
        const status = isExpected ? 'passed' : 'failed';
        const reason = testInfo.error?.message?.slice(0, 250) || 
          (status === 'passed' ? 'Test passed successfully' : `Test ${testInfo.status}`);
        
        console.log(`[BrowserStack] Setting status to: ${status}`);
        await sendBrowserStackCommand(page, 'setSessionStatus', { status, reason });
        
        // Petite pause pour s'assurer que le statut est envoyé
        await page.waitForTimeout(500);
      }
    } catch (error) {
      console.error(`[BrowserStack] Error in session ${sessionId}:`, error.message);
      // Toujours appeler use() même en cas d'erreur pour éviter "use() was not called"
      if (!context) {
        // Créer un contexte fallback local si la connexion BrowserStack échoue
        const localBrowser = await chromium.launch({ headless: false });
        context = await localBrowser.newContext();
        console.warn(`[BrowserStack] Fallback to local browser due to connection error`);
      }
      throw error; // Re-throw pour marquer le test comme failed
    } finally {
      // Nettoyage
      if (context) {
        try { 
          await context.close(); 
          console.log(`[BrowserStack] Context closed for ${sessionId}`);
        } catch (e) {
          console.warn(`[BrowserStack] Error closing context:`, e.message);
        }
      }
      if (browser) {
        try { 
          await browser.close(); 
          console.log(`[BrowserStack] Browser closed for ${sessionId}`);
        } catch (e) {
          console.warn(`[BrowserStack] Error closing browser:`, e.message);
        }
      }
    }
  },
  
  // Override de page pour utiliser le contexte personnalisé
  page: async ({ context }, use) => {
    const pages = context.pages();
    const page = pages.length > 0 ? pages[0] : await context.newPage();
    await use(page);
  },
});

module.exports = { test, expect: base.expect };
