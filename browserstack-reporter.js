/**
 * Reporter personnalisé pour BrowserStack
 * Met à jour le nom et le statut de chaque session de test via l'API BrowserStack
 */

const { updateBrowserStackSession, getBrowserStackSessions } = require('./browserstack-utils');

class BrowserStackReporter {
  constructor(options) {
    this.options = options;
    this.testStartTimes = new Map();
    this.sessionCache = [];
    this.updateQueue = [];
  }

  async onBegin(config, suite) {
    console.log(`\n[BrowserStack] Starting test run with ${suite.allTests().length} tests`);
    
    // Récupérer la liste des sessions actives
    if (process.env.BROWSERSTACK_USERNAME) {
      console.log('[BrowserStack] Fetching active sessions...');
      this.sessionCache = await getBrowserStackSessions();
    }
  }

  async onTestBegin(test, result) {
    // Enregistrer l'heure de début du test
    this.testStartTimes.set(test.id, Date.now());
  }

  async onTestEnd(test, result) {
    // Ne traiter que les tests BrowserStack
    if (!test.parent?.project()?.name?.includes('browserstack')) {
      return;
    }

    // Construire le nom complet du test
    const testName = this.getTestName(test);
    const status = result.status === 'passed' ? 'passed' : 'failed';
    const reason = result.error ? result.error.message.substring(0, 255) : '';

    console.log(`\n[BrowserStack] Test completed: ${testName} → ${status}`);

    // Récupérer les sessions mises à jour
    const sessions = await getBrowserStackSessions();
    
    // Trouver la session la plus récente qui correspond à ce test
    const testStartTime = this.testStartTimes.get(test.id);
    if (sessions && sessions.length > 0) {
      // Chercher la session qui a démarré autour du même moment
      const recentSession = sessions.find(s => {
        const sessionTime = new Date(s.created_at).getTime();
        return Math.abs(sessionTime - testStartTime) < 60000; // Dans les 60 secondes
      });

      if (recentSession && recentSession.hashed_id) {
        // Mettre à jour la session avec le bon nom et statut
        await updateBrowserStackSession(recentSession.hashed_id, {
          name: testName,
          status: status,
          reason: reason
        });
      } else {
        console.log(`[BrowserStack] Could not find matching session for: ${testName}`);
      }
    }
  }

  getTestName(test) {
    const titlePath = test.titlePath();
    // Retirer le nom du fichier (premier élément) et garder describe + test title
    return titlePath.slice(1).join(' › ');
  }

  async onEnd(result) {
    console.log(`\n[BrowserStack] Test run finished: ${result.status}`);
  }
}

module.exports = BrowserStackReporter;
