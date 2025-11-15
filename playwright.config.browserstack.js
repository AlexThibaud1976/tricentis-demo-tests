/**
 * Configuration Playwright pour BrowserStack
 * Utilise la configuration centralisée browserstack.config.js
 */

const { defineConfig, devices } = require('@playwright/test');
const bsConfig = require('./browserstack.config');
const cp = require('child_process');
const clientPlaywrightVersion = cp.execSync('npx playwright --version').toString().trim().split(' ')[1];

module.exports = defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: bsConfig.retries,
  workers: bsConfig.workers,
  
  reporter: [
    ['list'],
    ['html', { open: 'never' }],
    ['json', { outputFile: 'test-results.json' }],
    ['./browserstack-reporter.js']
  ],

  use: {
    baseURL: 'https://demowebshop.tricentis.com',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  timeout: bsConfig.timeout,
  expect: {
    timeout: 10000
  },

  // Configuration BrowserStack via CDP
  projects: [
    {
      name: `browserstack-${bsConfig.capabilities.browser}`,
      use: {
        ...devices['Desktop Chrome'],
        connectOptions: {
          wsEndpoint: `wss://cdp.browserstack.com/playwright?caps=${encodeURIComponent(JSON.stringify({
            browser: bsConfig.capabilities.browser,
            browser_version: bsConfig.capabilities.browserVersion,
            os: bsConfig.capabilities.os,
            os_version: bsConfig.capabilities.osVersion,
            build: bsConfig.buildName,
            project: bsConfig.projectName,
            name: 'Playwright Test',
            'browserstack.username': bsConfig.username,
            'browserstack.accessKey': bsConfig.accessKey,
            'browserstack.console': bsConfig.capabilities['browserstack.console'],
            'browserstack.networkLogs': bsConfig.capabilities['browserstack.networkLogs'],
            'browserstack.debug': bsConfig.capabilities['browserstack.debug'],
            'browserstack.video': bsConfig.capabilities['browserstack.video'],
            'browserstack.timezone': bsConfig.capabilities['browserstack.timezone'],
            'client.playwrightVersion': clientPlaywrightVersion,
          }))}`,
        },
      },
    },
  ],
});
