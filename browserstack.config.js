/**
 * Configuration centralisée BrowserStack
 * Permet de configurer facilement OS, navigateur, versions et parallélisation
 */

module.exports = {
  // Identifiants BrowserStack (via variables d'environnement)
  username: process.env.BROWSERSTACK_USERNAME,
  accessKey: process.env.BROWSERSTACK_ACCESS_KEY,

  // Nom du build (unique par exécution)
  buildName: process.env.BROWSERSTACK_BUILD_NAME || 
    `Tricentis Demo Tests - ${new Date().toISOString().split('T')[0]} ${new Date().getHours()}:${new Date().getMinutes()}`,

  // Nom du projet
  projectName: 'Tricentis Demo Web Shop',

  // Configuration de l'environnement d'exécution
  capabilities: {
    // Système d'exploitation
    os: process.env.BS_OS || 'Windows',
    osVersion: process.env.BS_OS_VERSION || '11',
    
    // Navigateur
    browser: process.env.BS_BROWSER || 'chrome',
    browserVersion: process.env.BS_BROWSER_VERSION || 'latest',
    
    // Options BrowserStack
    'browserstack.console': 'info',
    'browserstack.networkLogs': 'true',
    'browserstack.debug': 'true',
    'browserstack.video': 'true',
    'browserstack.timezone': 'Paris',
    'browserstack.selenium_version': '4.0.0',
  },

  // Nombre de tests en parallèle
  workers: parseInt(process.env.BS_WORKERS || '5', 10),

  // Timeout pour les tests
  timeout: 90000,

  // Options de retry (désactivé pour BrowserStack)
  retries: 0,
};
