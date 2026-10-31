const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const { randomBytes } = require('node:crypto');
const { prepareApplication } = require('../support/application.cjs');
const { authContract } = require('../support/contract.cjs');
const lowRam = process.argv.includes('--low-ram');
const testArgs = process.argv.slice(2).filter(arg => arg !== '--low-ram');
if (lowRam && testArgs.some(arg => /^(--project|--workers|--fully-parallel|--ui|--headed|--debug)(=|$)/.test(arg))) {
  console.error('Low-RAM mode fixes project=system and workers=1. Browser/parallel CLI options are not supported. Use --grep to select system cases.');
  process.exit(1);
}

const root = path.resolve(__dirname, '..');
const project = `iotagri-e2e-${Date.now()}-${randomBytes(3).toString('hex')}`;
const stamp = project.slice('iotagri-e2e-'.length);
const artifacts = path.join(root, 'artifacts', stamp);
fs.mkdirSync(artifacts, { recursive: true });
const env = { ...process.env, E2E_ARTIFACTS_DIR: artifacts.replaceAll('\\', '/') };
env.E2E_AUTH_CONTRACT = authContract;
env.E2E_LOW_RAM_API_IMAGE = `${project}-api`;
env.E2E_LOW_RAM_RUNNER_IMAGE = `${project}-runner`;
for (const key of ['COMPOSE_FILE', 'COMPOSE_PROJECT_NAME', 'COMPOSE_PROFILES', 'COMPOSE_ENV_FILES']) delete env[key];
// Never consume the developer's .env or COMPOSE_FILE/COMPOSE_PROJECT_NAME.
const compose = ['compose', '--env-file', path.join(root, 'empty.env'), '-p', project, '-f', path.join(root, lowRam ? 'compose.lowram.yaml' : 'compose.yaml')];
const builder = `${project}-builder`;
let builderCreated = false;
function docker(args, logName) {
  const fd = logName ? fs.openSync(path.join(artifacts, logName), 'a') : null;
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
meta.authContract = authContract;
meta.mode = lowRam ? 'low-ram' : 'full';
meta.scope = lowRam ? '17 system cases only; frontend/browser cases not selected' : '17 system cases + 15 browser cases';
if (lowRam) meta.resourceLimitsMiB = { build: 1536, postgres: 256, mosquitto: 64, mailpit: 128, api: 640, runner: 512 };
meta.workingTree = spawnSync('git', ['status', '--short'], { cwd: path.resolve(root, '../..'), encoding: 'utf8' }).stdout?.trim();
fs.writeFileSync(path.join(artifacts, 'run.json'), JSON.stringify(meta, null, 2));
try {
  if (Number(process.versions.node.split('.')[0]) < 22) throw new Error('Node.js 22 or newer is required.');
  if (docker(['info', '--format', '{{.ServerVersion}}']) !== 0)
    throw new Error('Docker Engine is unavailable. Start Docker Desktop (Linux containers), then rerun.');
  meta.application = prepareApplication(root, path.join(artifacts, 'source.log'));
  env.E2E_APP_DIR = meta.application.directory.replaceAll('\\', '/');
  env.E2E_FRONTEND_DIR = path.join(meta.application.directory, 'frontend').replaceAll('\\', '/');
  env.E2E_API_DOCKERFILE = path.join(root, lowRam ? 'api.lowram.Dockerfile' : 'api.Dockerfile').replaceAll('\\', '/');
  env.E2E_FRONTEND_DOCKERFILE = path.join(root, 'frontend.Dockerfile').replaceAll('\\', '/');
  fs.writeFileSync(path.join(artifacts, 'run.json'), JSON.stringify(meta, null, 2));
  console.log(`Application: ${meta.application.revision} (${meta.application.mode})`);
  console.log(`Auth contract: ${authContract}`);
  console.log(`Mode: ${meta.mode}. Scope: ${meta.scope}`);
  if (docker([...compose, 'config', '--quiet']) !== 0)
    throw new Error('Invalid E2E Compose configuration.');
  console.log(`Building E2E images. Log: ${path.join(artifacts, 'build.log')}`);
  if (lowRam) {
    builderCreated = true;
    if (docker(['buildx', 'create', '--name', builder, '--driver', 'docker-container',
      '--driver-opt', 'memory=1536m,memory-swap=1536m,cpu-period=100000,cpu-quota=100000',
      '--buildkitd-config', path.join(root, 'buildkit.lowram.toml')], 'build.log') !== 0)
      throw new Error('Cannot create the memory-limited builder. Docker Buildx is required. Inspect build.log.');
    for (const [file, context, tag] of [
      ['api.lowram.Dockerfile', meta.application.directory, env.E2E_LOW_RAM_API_IMAGE],
      ['Dockerfile.lowram', root, env.E2E_LOW_RAM_RUNNER_IMAGE],
    ]) {
      if (docker(['buildx', 'build', '--builder', builder, '--load', '--provenance=false',
        '-t', tag, '-f', path.join(root, file), context], 'build.log') !== 0)
        throw new Error('Low-RAM image build failed. Inspect build.log; no unrestricted fallback is used.');
    }
    if (docker(['buildx', 'rm', builder], 'build.log') !== 0) throw new Error('Cannot remove the temporary builder.');
    builderCreated = false;
  } else if (docker([...compose, 'build'], 'build.log') !== 0) throw new Error('E2E image build failed. Inspect build.log.');
  if (docker([...compose, 'up', '-d', '--no-build', '--wait', '--wait-timeout', '240', lowRam ? 'api' : 'frontend']) !== 0)
    throw new Error('E2E services did not become healthy. Inspect services.log.');
  console.log(`Running E2E suite. Log: ${path.join(artifacts, 'runner.log')}`);
  exitCode = docker([...compose, 'run', '--rm', '--no-deps', '--name', `${project}-runner-run`, 'runner', 'npx', 'playwright', 'test', ...testArgs, ...(lowRam ? ['--project=system', '--workers=1'] : [])], 'runner.log');
} catch (error) {
  console.error(error.message);
  meta.error = error.message;
} finally {
  if (builderCreated) {
    const builderCleanup = docker(['buildx', 'rm', builder], 'build.log');
    meta.builderCleanupCode = builderCleanup;
    if (builderCleanup !== 0 && exitCode === 0) exitCode = builderCleanup;
  }
  docker([...compose, 'logs', '--no-color', '--timestamps'], 'services.log');
  docker([...compose, 'ps', '-a'], 'services-status.txt');
  // Only this generated project's containers and named test volume are removed.
  cleanupCode = docker([...compose, 'down', '--volumes', '--remove-orphans']);
  if (cleanupCode !== 0 && exitCode === 0) exitCode = cleanupCode;
  Object.assign(meta, { finishedAt: new Date().toISOString(), exitCode, cleanupCode });
  fs.writeFileSync(path.join(artifacts, 'run.json'), JSON.stringify(meta, null, 2));
  fs.writeFileSync(path.join(artifacts, 'exit-code.txt'), `${exitCode}\n`);
  fs.writeFileSync(path.join(root, 'artifacts', 'latest-run.txt'), `${artifacts}\n`);
  const resultsFile = path.join(artifacts, 'results.json');
  if (fs.existsSync(resultsFile)) {
    try {
      const results = JSON.parse(fs.readFileSync(resultsFile, 'utf8'));
      meta.stats = results.stats;
      meta.setupErrors = (results.errors || []).map(error => error.message);
      const s = results.stats;
      console.log(`Tests: ${s.expected} passed, ${s.unexpected} failed, ${s.skipped} skipped, ${s.flaky} flaky; ${meta.setupErrors.length} setup/runner errors`);
    } catch (error) { console.error(`Cannot read test summary: ${error.message}`); }
  }
  console.log(`Test exit: ${exitCode}; cleanup exit: ${cleanupCode}`);
  console.log(`Runner log: ${path.join(artifacts, 'runner.log')}`);
  fs.writeFileSync(path.join(artifacts, 'run.json'), JSON.stringify(meta, null, 2));
  console.log(`Artifacts: ${artifacts}`);
  console.log(`HTML: ${path.join(artifacts, 'playwright-report', 'index.html')}`);
}
process.exitCode = exitCode;
