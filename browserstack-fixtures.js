/**
 * Fixtures personnalisées pour BrowserStack
 * Permet de mettre à jour les noms et statuts des tests
 */

const base = require('@playwright/test');
const https = require('https');

// Étendre les fixtures de base
exports.test = base.test.extend({
  page: async ({ page, browserName }, use, testInfo) => {
    // Avant le test : configurer le nom de la session BrowserStack
    if (process.env.BROWSERSTACK_USERNAME) {
      try {
        // Construire le nom du test
        const testName = testInfo.titlePath.slice(1).join(' › ');
        
        // Injecter le nom du test dans le contexte du navigateur
        await page.evaluate((name) => {
          window.BROWSERSTACK_TEST_NAME = name;
        }, testName);
        
        console.log(`[BrowserStack] Starting test: ${testName}`);
      } catch (error) {
        console.log(`[BrowserStack] Could not set test name: ${error.message}`);
      }
    }

    // Exécuter le test
    await use(page);

    // Après le test : mettre à jour le statut
    if (process.env.BROWSERSTACK_USERNAME) {
      try {
        const testName = testInfo.titlePath.slice(1).join(' › ');
        const status = testInfo.status === 'passed' ? 'passed' : 'failed';
        const reason = testInfo.error ? testInfo.error.message.substring(0, 255) : '';
        
        // Tenter d'extraire l'ID de session depuis le CDP
        const cdpSession = await page.context().newCDPSession(page);
        
        try {
          // Récupérer des informations sur la session
          const info = await cdpSession.send('Target.getTargetInfo', {
            targetId: page.mainFrame()._id
          });
          
          console.log(`[BrowserStack] Test completed: ${testName} → ${status}`);
        } catch (e) {
          // Ignorer les erreurs CDP
        } finally {
          await cdpSession.detach();
        }
        
        // Pour BrowserStack, on doit utiliser l'API REST avec l'ID de session
        // Malheureusement, l'ID de session n'est pas facilement accessible depuis Playwright
        // La meilleure approche est d'utiliser les capabilities dans le wsEndpoint
        
      } catch (error) {
        console.log(`[BrowserStack] Error in afterEach: ${error.message}`);
      }
    }
  },
});

exports.expect = base.expect;

/**
 * Fonction utilitaire pour mettre à jour une session BrowserStack
 */
async function updateBrowserStackSession(sessionId, name, status, reason = '') {
  if (!process.env.BROWSERSTACK_USERNAME || !process.env.BROWSERSTACK_ACCESS_KEY) {
    return;
  }

  const auth = Buffer.from(
    `${process.env.BROWSERSTACK_USERNAME}:${process.env.BROWSERSTACK_ACCESS_KEY}`
  ).toString('base64');

  const data = JSON.stringify({
    name: name,
    status: status,
    reason: reason
  });

  const options = {
    hostname: 'api.browserstack.com',
    port: 443,
    path: `/automate/sessions/${sessionId}.json`,
    method: 'PUT',
    headers: {
      'Authorization': `Basic ${auth}`,
      'Content-Type': 'application/json',
      'Content-Length': data.length
    }
  };

  return new Promise((resolve) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        if (res.statusCode === 200) {
          console.log(`[BrowserStack] ✓ Session updated: ${name} → ${status}`);
        }
        resolve();
      });
    });

    req.on('error', () => resolve());
    req.write(data);
    req.end();
  });
}

exports.updateBrowserStackSession = updateBrowserStackSession;
