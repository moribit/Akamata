import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { spawnSync } from "node:child_process";

test("live contract fails closed before fetch without isolation or valid expiring manifest", () => {
  const root = mkdtempSync(join(tmpdir(), "akamata-live-guard-"));
  try {
    const manifest = join(root, "manifest.json");
    const preload = join(root, "fetch.mjs");
    writeFileSync(preload, 'globalThis.fetch = () => { console.error("NETWORK_CALLED"); throw new Error("unexpected network"); };');
    const env = { ...process.env, AKAMATA_LIVE_BASE_URL: "https://akamata-contract-test.invalid", AKAMATA_LIVE_SUBJECT: "akamata-contract-user", AKAMATA_LIVE_LOGIN_SECRET: "local-guard-test", AKAMATA_LIVE_RESOURCE_MANIFEST: manifest, AKAMATA_LIVE_ISOLATED: "1" };
    const data = { deployment: "akamata-contract-test", host: "akamata-contract-test.invalid", source_sha: "a".repeat(40), binary_sha: "b".repeat(64), expires_at: new Date(Date.now() + 60_000).toISOString(), resources: { worker: "akamata-contract-test", d1: "akamata-contract-db", r2: "akamata-contract-files", queue: "akamata-contract-events", durable_objects: { script: "akamata-contract-test" } } };
    function run(value, overrides = {}) {
      writeFileSync(manifest, JSON.stringify(value));
      const result = spawnSync(process.execPath, ["--import", preload, resolve("tests/cloudflare_live.mjs")], { env: { ...env, ...overrides }, encoding: "utf8" });
      assert.notEqual(result.status, 0);
      assert.ok(!result.stderr.includes("NETWORK_CALLED"), result.stderr);
      return result;
    }
    assert.equal(run(data, { AKAMATA_LIVE_ISOLATED: "0" }).status, 2);
    run({ ...data, expires_at: new Date(Date.now() - 1000).toISOString() });
    run({ ...data, host: "production.invalid" });
    run({ ...data, resources: { ...data.resources, d1: "production-db" } });
    run({ ...data, resources: { ...data.resources, durable_objects: { script: "production-worker" } } });
  } finally { rmSync(root, { recursive: true, force: true }); }
});
