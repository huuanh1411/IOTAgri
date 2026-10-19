const { spawn } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const { generateReport } = require('./report.cjs');
const out = path.resolve(__dirname, '../..', 'docs/testing/2026-10-19-ui');
fs.mkdirSync(out, { recursive: true });
fs.rmSync(path.join(__dirname, 'test-results/results.json'), { force: true });
const stream = fs.createWriteStream(path.join(out, 'runner.log'));
const child = spawn(
  process.execPath,
  [require.resolve('@playwright/test/cli'), 'test', ...process.argv.slice(2)],
  { cwd: __dirname, stdio: ['inherit', 'pipe', 'pipe'] },
);
for (const [source, target] of [
  [child.stdout, process.stdout],
  [child.stderr, process.stderr],
]) {
  source.on('data', (data) => {
    target.write(data);
    stream.write(data);
  });
}
child.on('error', (error) => {
  console.error(error);
  process.exitCode = 1;
  stream.end();
});
child.on('close', (code) => {
  stream.end();
  if (fs.existsSync(path.join(__dirname, 'test-results/results.json')))
    generateReport(out);
  fs.writeFileSync(path.join(out, 'exit-code.txt'), `${code}\n`);
  process.exitCode = code || 0;
});
