const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

function prepareApplication(suiteRoot, logPath) {
  const repositoryRoot = path.resolve(suiteRoot, '../..');
  const hasApplication = dir => fs.existsSync(path.join(dir, 'backend/Program.cs')) && fs.existsSync(path.join(dir, 'frontend/pubspec.yaml'));
  const git = (args, cwd, log = false) => {
    const result = spawnSync('git', ['-c', 'core.longpaths=true', ...args], { cwd, encoding: 'utf8', maxBuffer: 16 * 1024 * 1024 });
    if (log) fs.appendFileSync(logPath, (result.stdout || '') + (result.stderr || ''));
    if (result.error || result.status !== 0) throw new Error(`Git source preparation failed: ${result.error?.message || result.stderr || args[0]}. See source.log.`);
    return result.stdout.trim();
  };
  const local = process.env.E2E_APP_DIR ? path.resolve(process.env.E2E_APP_DIR) : repositoryRoot;
  if (hasApplication(local)) {
    return { mode: 'checkout', directory: local, revision: git(['rev-parse', 'HEAD'], local) };
  }
  if (process.env.E2E_APP_DIR) throw new Error('E2E_APP_DIR must contain backend/Program.cs and frontend/pubspec.yaml.');
  const source = JSON.parse(fs.readFileSync(path.join(suiteRoot, 'application-source.json'), 'utf8'));
  if (!/^[a-f0-9]{40}$/.test(source.revision)) throw new Error('application-source.json requires a full Git commit SHA.');
  const directory = path.join(suiteRoot, '.app', source.revision);
  if (!fs.existsSync(path.join(directory, '.git'))) {
    fs.mkdirSync(directory, { recursive: true });
    git(['init'], directory, true);
  }
  const existing = spawnSync('git', ['rev-parse', '--verify', 'HEAD'], { cwd: directory, encoding: 'utf8' });
  if (existing.status !== 0) {
    git(['fetch', '--depth=1', source.repository, source.revision], directory, true);
    git(['checkout', '--detach', source.revision], directory, true);
  }
  if (git(['rev-parse', 'HEAD'], directory) !== source.revision)
    throw new Error('Application cache has a different revision; use a fresh .app cache.');
  if (git(['status', '--porcelain'], directory)) throw new Error('Application cache has local changes; preserve them and use a fresh cache.');
  if (!hasApplication(directory)) throw new Error('Pinned source does not contain a runnable application.');
  return { mode: 'pinned', directory, repository: source.repository, revision: source.revision };
}
module.exports = { prepareApplication };
