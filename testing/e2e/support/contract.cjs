// Select before execution, never infer expectations from an API response.
const authContract = process.env.E2E_AUTH_CONTRACT || 'verified-v1';
if (!['verified-v1', 'direct-v1'].includes(authContract))
  throw new Error('E2E_AUTH_CONTRACT must be verified-v1 or direct-v1.');
const verifiesEmail = authContract === 'verified-v1';
module.exports = { authContract, verifiesEmail, registrationStatus: verifiesEmail ? 202 : 201 };
