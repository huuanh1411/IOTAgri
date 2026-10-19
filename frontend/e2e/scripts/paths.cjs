const path = require('node:path');

const e2eRoot = path.resolve(__dirname, '..');
const repoRoot = path.resolve(e2eRoot, '../..');

function resolveReportDir() {
  if (process.env.E2E_REPORT_DIR) {
    return path.resolve(repoRoot, process.env.E2E_REPORT_DIR);
  }
  const runName = `${new Date().toISOString().replace(/[:.]/g, '-')}-${process.pid}`;
  return path.join(repoRoot, 'testing/reports/frontend/e2e', runName);
}

module.exports = { e2eRoot, resolveReportDir };
