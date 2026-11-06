import assert from 'node:assert/strict';
import { readFile, writeFile } from 'node:fs/promises';

const phase = process.argv[2] || 'candidate';
const base = 'https://akamata-migration-20261106-news.mimoc-maker.workers.dev';
const scratch = new URL('../../.zig-cache/consumer-migration/', import.meta.url);
const { BASIC_AUTH_TOKEN } = JSON.parse(await readFile(new URL('staging-test-credentials.json', scratch)));
const headers = { Authorization: `Basic ${BASIC_AUTH_TOKEN}` };
const image = Buffer.alloc(9 * 1024 * 1024); image.set([0xff, 0xd8, 0xff]);
const evidence = { phase, base, checks: [], response_contract: {} };
let id;
function form(title, upload = false, main = false, size) {
  const f = new FormData();
  f.set('date', '2026-11-06'); f.set('title', title); f.set('body', 'isolated migration fixture');
  f.append('category', 'イベント');
  if (upload) {
    const data = size ? Buffer.alloc(size) : image;
    data.set([0xff, 0xd8, 0xff]);
    f.set('title_image', new Blob([data], { type: 'image/jpeg' }), 'fixture.jpg');
  }
  if (main) f.set('main_image', new Blob([image], { type: 'image/jpeg' }), 'main.jpg');
  return f;
}
async function check(name, path, options, status) {
  const r = await fetch(base + path, options);
  assert.equal(r.status, status, `${name}: ${r.status} ${await r.clone().text()}`);
  evidence.checks.push(name);
  const json = r.headers.get('content-type')?.includes('json') ? await r.clone().json() : null;
  evidence.response_contract[name] = { status: r.status, content_type: r.headers.get('content-type'), keys: json && typeof json === 'object' ? Object.keys(json).sort() : [] };
  return r;
}
try {
  await check('public list', '/api/news', undefined, 200);
  await check('admin unauthorized', '/admin', undefined, 401);
  await check('admin authorized', '/admin', { headers }, 200);
  await check('origin rejected', '/api/news', { method: 'POST', headers: { ...headers, Origin: 'https://invalid.example' }, body: form('blocked') }, 403);
  await check('create without required title image', '/api/news', { method: 'POST', headers, body: form('plain fixture') }, 400);
  let r = await check('two 9 MiB uploads', '/api/news', { method: 'POST', headers, body: form('image fixture', true, true) }, 201);
  const row = await r.json(); id = row.id;
  const imageUrl = row.title_image_url;
  assert.equal(new URL(imageUrl).origin, base, 'images must stay in isolated staging');
  r = await fetch(imageUrl); assert.equal(r.status, 200); assert.deepEqual(Buffer.from(await r.arrayBuffer()), image);
  r = await fetch(imageUrl, { method: 'HEAD' }); assert.equal(r.status, 200); assert.equal(await r.text(), '');
  const oldMain = row.main_image_url;
  assert.equal((await fetch(oldMain, { method: 'HEAD' })).status, 200);
  evidence.checks.push('R2 GET/HEAD bytes and both images');
  r = await check('detail observability', `/api/news/${id}`, undefined, 200);
  evidence.observability = { request_id: !!r.headers.get('x-request-id'), server_timing: r.headers.get('server-timing') };
  assert.ok(evidence.observability.request_id); assert.ok(evidence.observability.server_timing);
  for (const r of await Promise.all(Array.from({ length: 16 }, () => fetch(`${base}/api/news/${id}`)))) assert.equal(r.status, 200);
  const retained = await (await check('update retaining images', `/api/news/${id}`, { method: 'PUT', headers, body: form('text only edit') }, 200)).json();
  assert.equal(retained.news.title_image_url, imageUrl);
  assert.equal(retained.news.main_image_url, oldMain);
  r = await check('replace both images', `/api/news/${id}`, { method: 'PUT', headers, body: form('replacement fixture', true, true) }, 200);
  const replacement = (await r.json()).news;
  assert.notEqual(replacement.title_image_url, imageUrl);
  assert.equal((await fetch(imageUrl)).status, 404);
  assert.equal((await fetch(oldMain)).status, 404);
  await check('image size exceeded', `/api/news/${id}`, { method: 'PUT', headers, body: form('oversized', true, false, 10 * 1024 * 1024 + 1) }, 400);
  r = await check('delete images', `/api/news/${id}`, { method: 'DELETE', headers }, 200);
  assert.equal((await r.json()).image_cleanup, 'complete');
  for (const url of [replacement.title_image_url, replacement.main_image_url]) assert.equal((await fetch(url)).status, 404);
  await check('deleted detail', `/api/news/${id}`, undefined, 404); id = null;
  evidence.status = 'success';
} catch (error) {
  evidence.status = 'failed'; evidence.error = String(error); process.exitCode = 1;
} finally {
  if (id) await fetch(`${base}/api/news/${id}`, { method: 'DELETE', headers });
  await writeFile(new URL(`news-${phase}.json`, scratch), JSON.stringify(evidence, null, 2));
  console.log(JSON.stringify(evidence));
}
