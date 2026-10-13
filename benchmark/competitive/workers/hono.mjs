import { Hono } from 'hono';
import { bodyLimit } from 'hono/body-limit';
const app = new Hono();
app.get('/plaintext', c => new Response('Hello, World!', { headers: { 'content-type': 'text/plain; charset=utf-8' } }));
app.get('/json', c => c.json({ message: 'Hello, World!' }));
app.post('/echo', bodyLimit({ maxSize: 1024 * 1024 }), async c => {
  const bytes = await c.req.arrayBuffer();
  if (bytes.byteLength > 1024 * 1024) return new Response(null, { status: 413 });
  return new Response(bytes, { headers: { 'content-type': 'application/octet-stream' } });
});
app.get('/users/:user/posts/:post', c => {
  const user = Number(c.req.param('user')), post = Number(c.req.param('post'));
  if (!Number.isSafeInteger(user) || !Number.isSafeInteger(post) || user < 0 || post < 0)
    return c.json({ error: 'invalid_id' }, 400);
  return c.json({ user, post });
});
app.get('/db/1', async c => {
  const row = await c.env.DB.prepare('SELECT id, name, weight FROM items WHERE id = ?').bind(1).first();
  return row ? c.json(row) : c.json({ error: 'not_found' }, 404);
});
export default app;
