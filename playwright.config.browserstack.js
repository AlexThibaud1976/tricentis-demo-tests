const { defineConfig, devices } = require('@playwright/test');
const base = require('./playwright.config.js');
const cp = require('child_process');
const clientPlaywrightVersion = cp
  .execSync('npx playwright --version')
  .toString()
  .trim()
  .split(' ')[1];

/**
 * Configuration Playwright pour BrowserStack
 * Documentation: https://www.browserstack.com/docs/automate/playwright
 */
module.exports = defineConfig({
  ...base,
  
  // Désactiver le mode headed pour BrowserStack
  use: {
    ...base.use,
    headless: true,
  },

  // Reporter personnalisé pour BrowserStack + reporters standards
  reporter: [
    ['list'],
    ['html'],
    ['./browserstack-reporter.js'],
  ],

  // Configuration BrowserStack
  projects: [
    {
      name: 'browserstack-chrome',
      use: {
        ...devices['Desktop Chrome'],
        // Capabilities BrowserStack
        connectOptions: {
          wsEndpoint: `wss://cdp.browserstack.com/playwright?caps=${encodeURIComponent(JSON.stringify({
            'browser': 'chrome',
            'browser_version': 'latest',
            'os': 'Windows',
            'os_version': '11',
            'build': 'TRICENTIS-DEMO-TESTS',
            'project': 'TRICENTIS-DEMO-TESTS',
            'name': 'Test', // Sera mis à jour par le reporter
            'browserstack.username': process.env.BROWSERSTACK_USERNAME,
            'browserstack.accessKey': process.env.BROWSERSTACK_ACCESS_KEY,
            'browserstack.console': 'info',
            'browserstack.networkLogs': 'true',
            'browserstack.playwrightVersion': clientPlaywrightVersion,
            'client.playwrightVersion': clientPlaywrightVersion,
          }))}`,
        },
      },
    },
  ],

  // Exécution parallèle avec 5 workers maximum
  workers: 5,
  fullyParallel: true,
});
