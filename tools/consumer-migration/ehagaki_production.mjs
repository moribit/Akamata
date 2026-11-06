import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { writeFile } from 'node:fs/promises';
const issuer = 'https://mimoc.jp'; // Existing legacy issuer; no deployment or routing change.
const target = 'https://ehagaki.mimoc-maker.workers.dev';
const accounts = [], posts = [], checks = [];
const evidence = { status: 'failed', checks, production_secret_read: false };
async function call(base, method, path, body, token, expected = 200) {
  const r = await fetch(base + path, { method, headers: {
    'User-Agent': 'Akamata-Release-Verification', ...(body ? { 'Content-Type': 'application/json' } : {}),
    ...(token ? { Authorization: `Bearer ${token}` } : {}) }, body: body ? JSON.stringify(body) : undefined });
  assert.equal(r.status, expected, `${method} ${path}: unexpected status ${r.status}`);
  return r;
}
try {
  for (let i = 0; i < 2; i++) {
    const account = await (await call(issuer, 'POST', '/api/auth/register', {
      login_id: 'akamata-release-' + randomUUID(), nickname: 'aktest', password: randomUUID() }, undefined, 201)).json();
    assert.ok(account.token && account.user_id); accounts.push(account);
  }
  checks.push('fresh test accounts issued by unchanged production Mo-Bus');
  for (const is_public of [true, false]) {
    const post = await (await call(target, 'POST', '/api/posts', {
      title: 'テスト', text: 'Akamata release verification', is_public }, accounts[0].token, 201)).json();
    assert.equal(post.user_id, accounts[0].user_id); posts.push(post.id);
    await call(target, 'GET', `/api/posts/${post.id}`, undefined, undefined, is_public ? 200 : 404);
    await call(target, 'GET', `/api/posts/${post.id}`, undefined, accounts[0].token);
    await call(target, 'DELETE', `/api/posts/${post.id}`, undefined, accounts[1].token, 404);
  }
  checks.push('production-issued JWT user_id compatibility, public/private visibility, owner and nonowner semantics');
  const parts = accounts[0].token.split('.');
  parts[2] = (parts[2][0] === 'A' ? 'B' : 'A') + parts[2].slice(1);
  await call(target, 'POST', '/api/posts', { text: 'rejected' }, parts.join('.'), 401);
  checks.push('invalid signature rejected');
  const proxy = await fetch('https://mimoc.jp/ehagaki/health');
  assert.equal(proxy.status, 200); checks.push('existing public Ehagaki proxy health');
  evidence.status = 'success';
} catch (error) {
  evidence.error = String(error); process.exitCode = 1;
} finally {
  evidence.deleted_posts = 0; evidence.deleted_test_accounts = 0;
  for (const id of posts) {
    try { await call(target, 'DELETE', `/api/posts/${id}`, undefined, accounts[0].token); evidence.deleted_posts++; }
    catch { evidence.status = 'failed'; evidence.cleanup_failure = true; process.exitCode = 1; }
  }
  for (const account of accounts) {
    try { await call(issuer, 'DELETE', '/api/user/me', undefined, account.token); evidence.deleted_test_accounts++; }
    catch { evidence.status = 'failed'; evidence.cleanup_failure = true; process.exitCode = 1; }
  }
  await writeFile(new URL('../../.zig-cache/consumer-migration/ehagaki-production.json', import.meta.url), JSON.stringify(evidence, null, 2));
  console.log(JSON.stringify(evidence));
}
