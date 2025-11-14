const { defineConfig, devices } = require('@playwright/test');
const base = require('./playwright.config.js');

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
            'name': 'Tricentis Demo Tests',
            'build': `Build ${process.env.GITHUB_RUN_NUMBER || 'local'}`,
            'project': 'tricentis-demo-tests',
            'browserstack.username': process.env.BROWSERSTACK_USERNAME,
            'browserstack.accessKey': process.env.BROWSERSTACK_ACCESS_KEY,
            'browserstack.console': 'info',
            'browserstack.networkLogs': 'true',
          }))}`,
        },
      },
    },
  ],

  // Forcer l'exécution séquentielle
  workers: 1,
  fullyParallel: false,
});
