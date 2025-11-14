/**
 * Reporter personnalisé pour BrowserStack
 * Met à jour le nom et le statut de chaque session de test
 */

const https = require('https');

class BrowserStackReporter {
  constructor(options) {
    this.options = options;
  }

  async onTestEnd(test, result) {
    // Ne traiter que les tests BrowserStack
    if (!test.parent?.project()?.name?.includes('browserstack')) {
      return;
    }

    const page = result.attachments.find(a => a.name === 'page')?.body;
    
    try {
      // Récupérer l'ID de session depuis le contexte du test
      const sessionId = await this.getSessionId(result);
      
      if (sessionId) {
        const testName = `${test.parent.title} - ${test.title}`;
        const status = result.status === 'passed' ? 'passed' : 'failed';
        const reason = result.error?.message || '';

        // Mettre à jour le nom de la session
        await this.updateSession(sessionId, {
          name: testName,
          status: status,
          reason: reason
        });
      }
    } catch (error) {
      // Ignorer les erreurs silencieusement
      console.log(`Could not update BrowserStack session: ${error.message}`);
    }
  }

  async getSessionId(result) {
    // L'ID de session BrowserStack est disponible dans les capabilities
    // mais difficile à extraire directement de Playwright
    // Pour l'instant, on s'appuie sur le SDK qui gère cela automatiquement
    return null;
  }

  async updateSession(sessionId, data) {
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

    return new Promise((resolve, reject) => {
      const req = https.request(options, (res) => {
        let body = '';
        res.on('data', (chunk) => body += chunk);
        res.on('end', () => {
          if (res.statusCode === 200) {
            console.log(`✓ BrowserStack session updated: ${data.name}`);
          }
          resolve();
        });
      });

      req.on('error', (error) => {
        console.error(`Error updating BrowserStack: ${error.message}`);
        resolve();
      });

      req.write(payload);
      req.end();
    });
  }
}

module.exports = BrowserStackReporter;
