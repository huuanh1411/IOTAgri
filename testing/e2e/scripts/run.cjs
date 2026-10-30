const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const { randomBytes } = require('node:crypto');
const { prepareApplication } = require('../support/application.cjs');

const root = path.resolve(__dirname, '..');
const project = `iotagri-e2e-${Date.now()}-${randomBytes(3).toString('hex')}`;
const stamp = project.slice('iotagri-e2e-'.length);
const artifacts = path.join(root, 'artifacts', stamp);
fs.mkdirSync(artifacts, { recursive: true });
const env = { ...process.env, E2E_ARTIFACTS_DIR: artifacts.replaceAll('\\', '/') };
for (const key of ['COMPOSE_FILE', 'COMPOSE_PROJECT_NAME', 'COMPOSE_PROFILES', 'COMPOSE_ENV_FILES']) delete env[key];
// Never consume the developer's .env or COMPOSE_FILE/COMPOSE_PROJECT_NAME.
const compose = ['compose', '--env-file', path.join(root, 'empty.env'), '-p', project, '-f', path.join(root, 'compose.yaml')];
function docker(args, logName) {
  const fd = logName ? fs.openSync(path.join(artifacts, logName), 'w') : null;
  try {
    const result = spawnSync('docker', args, {
      cwd: root, env, stdio: fd === null ? 'inherit' : ['ignore', fd, fd],
    });
    if (result.error) console.error(result.error.message);
    return result.status ?? 1;
  } finally {
    if (fd !== null) fs.closeSync(fd);
  }
}
let exitCode = 1;
let cleanupCode = 0;
const meta = { project, revision: spawnSync('git', ['rev-parse', 'HEAD'], { cwd: root, encoding: 'utf8' }).stdout?.trim(), startedAt: new Date().toISOString(), args: process.argv.slice(2) };
meta.workingTree = spawnSync('git', ['status', '--short'], { cwd: path.resolve(root, '../..'), encoding: 'utf8' }).stdout?.trim();
fs.writeFileSync(path.join(artifacts, 'run.json'), JSON.stringify(meta, null, 2));
try {
  if (Number(process.versions.node.split('.')[0]) < 22) throw new Error('Node.js 22 or newer is required.');
  if (docker(['info', '--format', '{{.ServerVersion}}']) !== 0)
    throw new Error('Docker Engine is unavailable. Start Docker Desktop (Linux containers), then rerun.');
  meta.application = prepareApplication(root, path.join(artifacts, 'source.log'));
  env.E2E_APP_DIR = meta.application.directory.replaceAll('\\', '/');
  env.E2E_FRONTEND_DIR = path.join(meta.application.directory, 'frontend').replaceAll('\\', '/');
  env.E2E_API_DOCKERFILE = path.join(root, 'api.Dockerfile').replaceAll('\\', '/');
  env.E2E_FRONTEND_DOCKERFILE = path.join(root, 'frontend.Dockerfile').replaceAll('\\', '/');
  fs.writeFileSync(path.join(artifacts, 'run.json'), JSON.stringify(meta, null, 2));
  console.log(`Application: ${meta.application.revision} (${meta.application.mode})`);
  if (docker([...compose, 'config', '--quiet']) !== 0)
    throw new Error('Invalid E2E Compose configuration.');
  console.log(`Building E2E images. Log: ${path.join(artifacts, 'build.log')}`);
  if (docker([...compose, 'build'], 'build.log') !== 0) throw new Error('E2E image build failed. Inspect build.log.');
  if (docker([...compose, 'up', '-d', '--wait', '--wait-timeout', '240', 'frontend']) !== 0)
    throw new Error('E2E services did not become healthy. Inspect services.log.');
  console.log(`Running E2E suite. Log: ${path.join(artifacts, 'runner.log')}`);
  exitCode = docker([...compose, 'run', '--rm', '--no-deps', 'runner', 'npx', 'playwright', 'test', ...process.argv.slice(2)], 'runner.log');
} catch (error) {
  console.error(error.message);
  meta.error = error.message;
} finally {
  docker([...compose, 'logs', '--no-color', '--timestamps'], 'services.log');
  docker([...compose, 'ps', '-a'], 'services-status.txt');
  // Only this generated project's containers and named test volume are removed.
  cleanupCode = docker([...compose, 'down', '--volumes', '--remove-orphans']);
  if (cleanupCode !== 0 && exitCode === 0) exitCode = cleanupCode;
  Object.assign(meta, { finishedAt: new Date().toISOString(), exitCode, cleanupCode });
  fs.writeFileSync(path.join(artifacts, 'run.json'), JSON.stringify(meta, null, 2));
  fs.writeFileSync(path.join(artifacts, 'exit-code.txt'), `${exitCode}\n`);
  fs.writeFileSync(path.join(root, 'artifacts', 'latest-run.txt'), `${artifacts}\n`);
  console.log(`Artifacts: ${artifacts}`);
  console.log(`HTML: ${path.join(artifacts, 'playwright-report', 'index.html')}`);
}
process.exitCode = exitCode;
