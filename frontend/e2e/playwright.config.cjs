const { defineConfig } = require('@playwright/test');
module.exports = defineConfig({
  testDir: './tests',
  timeout: 45000,
  expect: { timeout: 12000 },
  workers: 1,
  retries: 0,
  globalSetup: './setup.cjs',
  outputDir: './test-results',
  reporter: [
    ['list'],
    ['json', { outputFile: './test-results/results.json' }],
    ['html', { open: 'never' }],
  ],
  use: {
    baseURL: process.env.FE_URL || 'http://localhost:3000',
    channel: 'chrome',
    headless: true,
    viewport: { width: 390, height: 844 },
    locale: 'vi-VN',
    timezoneId: 'Asia/Ho_Chi_Minh',
    screenshot: 'on',
    trace: 'retain-on-failure',
    serviceWorkers: 'block',
  },
  projects: [
    {
      name: 'mobile',
      use: {
        viewport: { width: 390, height: 844 },
        isMobile: true,
        hasTouch: true,
      },
    },
    {
      name: 'small-mobile',
      use: {
        viewport: { width: 320, height: 568 },
        isMobile: true,
        hasTouch: true,
      },
    },
    { name: 'desktop', use: { viewport: { width: 1280, height: 900 } } },
  ],
  webServer: {
    command:
      'python -m http.server 3000 --bind 127.0.0.1 --directory ../build/web',
    url: process.env.FE_URL || 'http://localhost:3000',
    reuseExistingServer: true,
    timeout: 10000,
  },
});
