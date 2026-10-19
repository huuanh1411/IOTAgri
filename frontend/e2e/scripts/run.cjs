const { spawn } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const { generateReport } = require('./report.cjs');
const { e2eRoot, resolveReportDir } = require('./paths.cjs');
const out = resolveReportDir();
fs.mkdirSync(out, { recursive: true });
fs.rmSync(path.join(e2eRoot, 'test-results/results.json'), { force: true });
const stream = fs.createWriteStream(path.join(out, 'runner.log'));
const child = spawn(
  process.execPath,
  [require.resolve('@playwright/test/cli'), 'test', ...process.argv.slice(2)],
  { cwd: e2eRoot, stdio: ['inherit', 'pipe', 'pipe'] },
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
  let exitCode = Number.isInteger(code) ? code : 1;
  try {
    if (fs.existsSync(path.join(e2eRoot, 'test-results/results.json')))
      generateReport(out);
  } catch (error) {
    console.error(error);
    exitCode = 1;
  } finally {
    fs.writeFileSync(path.join(out, 'exit-code.txt'), `${exitCode}\n`);
    process.exitCode = exitCode;
  }
});
