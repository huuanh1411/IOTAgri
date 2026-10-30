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
    return { mode: 'checkout', directory: local, revision: git(['rev-parse', 'HEAD'], local), workingTree: git(['status', '--short'], local) };
  }
  if (process.env.E2E_APP_DIR) throw new Error('E2E_APP_DIR must contain backend/Program.cs and frontend/pubspec.yaml.');
  const source = JSON.parse(fs.readFileSync(path.join(suiteRoot, 'application-source.json'), 'utf8'));
  const ref = process.env.E2E_APP_REV || source.ref || source.revision;
  if (!ref || ref.startsWith('-')) throw new Error('Invalid application source ref.');
  const mirror = path.join(suiteRoot, '.app', 'remote.git');
  if (!fs.existsSync(path.join(mirror, 'HEAD'))) {
    fs.mkdirSync(mirror, { recursive: true });
    git(['init', '--bare'], mirror, true);
  }
  // Fetch once per run, then materialize that exact SHA. Never reset a user's checkout.
  git(['fetch', '--depth=1', source.repository, ref], mirror, true);
  const revision = git(['rev-parse', 'FETCH_HEAD'], mirror);
  const directory = path.join(suiteRoot, '.app', revision);
  if (!fs.existsSync(path.join(directory, '.git'))) {
    fs.mkdirSync(directory, { recursive: true });
    git(['init'], directory, true);
  }
  const existing = spawnSync('git', ['rev-parse', '--verify', 'HEAD'], { cwd: directory, encoding: 'utf8' });
  if (existing.status !== 0) {
    git(['fetch', '--depth=1', mirror, revision], directory, true);
    git(['checkout', '--detach', revision], directory, true);
  }
  if (git(['rev-parse', 'HEAD'], directory) !== revision)
    throw new Error('Application cache has a different revision; use a fresh .app cache.');
  if (git(['status', '--porcelain'], directory)) throw new Error('Application cache has local changes; preserve them and use a fresh cache.');
  if (!hasApplication(directory)) throw new Error('Selected source does not contain a runnable application.');
  return { mode: 'remote', directory, repository: source.repository, ref, revision };
}
module.exports = { prepareApplication };
