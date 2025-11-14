/**
 * Global Setup pour BrowserStack
 * Configure les hooks pour mettre à jour les noms et statuts des tests
 */

const { chromium } = require('@playwright/test');
const https = require('https');

// Map pour stocker les IDs de session
global.browserstackSessions = new Map();

/**
 * Met à jour une session BrowserStack via l'API REST
 */
async function updateBrowserStackSession(sessionId, data) {
  if (!process.env.BROWSERSTACK_USERNAME || !process.env.BROWSERSTACK_ACCESS_KEY) {
    return;
  }

  const auth = Buffer.from(
    `${process.env.BROWSERSTACK_USERNAME}:${process.env.BROWSERSTACK_ACCESS_KEY}`
  ).toString('base64');

  const payload = JSON.stringify(data);

  const options = {
    hostname: 'api.browserstack.com',
    port: 443,
    path: `/automate/sessions/${sessionId}.json`,
    method: 'PUT',
    headers: {
      'Authorization': `Basic ${auth}`,
      'Content-Type': 'application/json',
      'Content-Length': payload.length
    }
  };

  return new Promise((resolve) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        if (res.statusCode === 200) {
          console.log(`[BrowserStack] ✓ Updated: ${data.name || sessionId}`);
        } else {
          console.log(`[BrowserStack] ✗ Failed (${res.statusCode})`);
        }
        resolve();
      });
    });

    req.on('error', () => resolve());
    req.write(payload);
    req.end();
  });
}

/**
 * Récupère la liste des sessions BrowserStack récentes
 */
async function getBrowserStackSessions() {
  if (!process.env.BROWSERSTACK_USERNAME || !process.env.BROWSERSTACK_ACCESS_KEY) {
    return [];
  }

  const auth = Buffer.from(
    `${process.env.BROWSERSTACK_USERNAME}:${process.env.BROWSERSTACK_ACCESS_KEY}`
  ).toString('base64');

  const options = {
    hostname: 'api.browserstack.com',
    port: 443,
    path: '/automate/sessions.json?limit=100',
    method: 'GET',
    headers: {
      'Authorization': `Basic ${auth}`,
    }
  };

  return new Promise((resolve) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const sessions = JSON.parse(body);
          resolve(sessions);
        } catch (e) {
          resolve([]);
        }
      });
    });

    req.on('error', () => resolve([]));
    req.end();
  });
}

module.exports = { updateBrowserStackSession, getBrowserStackSessions };
