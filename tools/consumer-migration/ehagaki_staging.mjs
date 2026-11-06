import assert from 'node:assert/strict';
import { createHmac, randomUUID } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
const scratch = new URL('../../.zig-cache/consumer-migration/', import.meta.url);
const { JWT_SECRET } = JSON.parse(await readFile(new URL('staging-test-credentials.json', scratch)));
const base = 'https://akamata-migration-20261106-ehagaki.mimoc-maker.workers.dev';
const mobus = 'https://akamata-migration-20261106-mobus.mimoc-maker.workers.dev';
const checks = [], ids = [];
function signed(user, exp, secret = JWT_SECRET) {
  const enc = value => Buffer.from(JSON.stringify(value)).toString('base64url');
  const wire = `${enc({ alg: 'HS256', typ: 'JWT' })}.${enc({ user_id: user, sub: user, exp })}`;
  return `${wire}.${createHmac('sha256', secret).update(wire).digest('base64url')}`;
}
let ownerToken;
async function req(name, path, method = 'GET', body, token, expected = 200) {
  const r = await fetch(base + path, { method, body: body === undefined ? undefined : JSON.stringify(body), headers: {
    ...(body === undefined ? {} : { 'Content-Type': 'application/json' }), ...(token ? { Authorization: `Bearer ${token}` } : {}) } });
  assert.equal(r.status, expected, `${name}: ${r.status} ${await r.clone().text()}`);
  checks.push(name); return r;
}
try {
  await req('isolated migration completed / health', '/health');
  await req('anonymous timeline', '/api/timeline');
  await req('anonymous create denied', '/api/posts', 'POST', { text: 'test' }, undefined, 401);
  const login = 'migration-' + randomUUID();
  const r = await fetch(mobus + '/api/auth/register', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ login_id: login, nickname: 'migration', password: randomUUID() }) });
  assert.equal(r.status, 201); const user = await r.json(); ownerToken = user.token;
  await req('expired JWT denied', '/api/posts', 'POST', { text: 'test' }, signed(user.user_id, 1), 401);
  await req('invalid signature denied', '/api/posts', 'POST', { text: 'test' }, signed(user.user_id, Math.floor(Date.now()/1000)+60, 'different-test-key'), 401);
  const other = signed('different-test-user', Math.floor(Date.now()/1000)+60);
  for (const pub of [true, false]) {
    const row = await (await req('Mo-Bus issued JWT accepted: ' + pub, '/api/posts', 'POST', { title: 'テスト', text: 'body', is_public: pub }, ownerToken, 201)).json();
    assert.equal(row.user_id, user.user_id); ids.push(row.id);
    await req('anonymous visibility: ' + pub, `/api/posts/${row.id}`, 'GET', undefined, undefined, pub ? 200 : 404);
    await req('owner visibility: ' + pub, `/api/posts/${row.id}`, 'GET', undefined, ownerToken);
    await req('other delete denied', `/api/posts/${row.id}`, 'DELETE', undefined, other, 404);
  }
  const rows = await (await req('authenticated search and paging', '/api/timeline?q=' + encodeURIComponent('テスト') + '&page=1&page_size=3', 'GET', undefined, ownerToken)).json();
  assert.ok(rows.posts.some(row => ids.includes(row.id)));
  await req('Unicode charset rejects emoji', '/api/posts', 'POST', { text: '😀' }, ownerToken, 400);
  const bitmap = await (await req('bitmap create', '/api/posts', 'POST', { bitmap_b64: Buffer.alloc(1024).toString('base64'), is_public: true }, ownerToken, 201)).json(); ids.push(bitmap.id);
  await req('bitmap size rejects', '/api/posts', 'POST', { bitmap_b64: Buffer.alloc(1023).toString('base64') }, ownerToken, 400);
  for (const id of ids) await req('owner delete', `/api/posts/${id}`, 'DELETE', undefined, ownerToken);
  ids.length = 0;
  const gateway = await fetch(mobus + '/ehagaki/health'); assert.equal(gateway.status, 200); checks.push('gateway Service Binding to Ehagaki');
  const evidence = { status: 'success', base, checks, jwt: 'fresh staging Mo-Bus-issued token with shared test-only signing secret' };
  await writeFile(new URL('ehagaki-live.json', scratch), JSON.stringify(evidence, null, 2)); console.log(JSON.stringify(evidence));
} finally {
  for (const id of ids) await fetch(`${base}/api/posts/${id}`, { method: 'DELETE', headers: { Authorization: `Bearer ${ownerToken}` } });
}
