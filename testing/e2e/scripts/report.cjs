const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const root = path.resolve(__dirname, '..');
const latest = path.join(root, 'artifacts/latest-run.txt');
if (!fs.existsSync(latest)) {
  console.error('No E2E run found. Run npm test first.');
  process.exitCode = 1;
} else {
  const dir = fs.readFileSync(latest, 'utf8').trim();
  if (!fs.existsSync(path.join(dir, 'playwright-report/index.html'))) {
    console.error(`No HTML report: this run failed before test execution. Inspect ${dir}`);
    process.exitCode = 1;
  } else {
    process.exitCode = spawnSync(process.execPath, [require.resolve('@playwright/test/cli'), 'show-report', path.join(dir, 'playwright-report')], { stdio: 'inherit' }).status ?? 1;
  }
}
