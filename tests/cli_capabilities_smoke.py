"""Capability inspection protocol and config drift; no services or accounts."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile

cli = str(Path(sys.argv[1]).resolve())
with tempfile.TemporaryDirectory(prefix="akamata-capability-") as directory:
    root = Path(directory)
    manifest = root / "contract.json"
    config = root / "wrangler.toml"
    declaration = {
        "version": 1, "application": "fixture", "target": "workers",
        "requirements": ["database", "object_storage"],
        "providers": [
            {"capability": "database", "provider": "d1", "binding": "DB"},
            {"capability": "object_storage", "provider": "r2", "binding": "FILES"},
        ], "routes": [{"method": "POST", "path": "/files", "capabilities": ["object_storage"]}],
    }
    config.write_text('[[d1_databases]]\nbinding = "DB"\n[[r2_buckets]]\nbinding = "FILES"\n')

    def run(data, expected=0, extra=()):
        manifest.write_text(json.dumps(data))
        before = config.read_bytes()
        result = subprocess.run([cli, "inspect", "capabilities", "--target=workers", "--json",
                                 f"--manifest={manifest}", f"--config={config}", *extra],
                                cwd=root, capture_output=True, text=True)
        assert result.returncode == expected, result.stderr
        assert config.read_bytes() == before, "inspection changed configuration"
        return result

    result = run(declaration)
    output = json.loads(result.stderr.strip())
    assert all(p["status"] == "binding_configured" for p in output["providers"])
    assert all(p["readiness"] == "configured" for p in output["providers"])
    assert "ready" not in result.stderr
    assert "ProviderConfigurationDrift" in run(declaration, 1, ["--strict"]).stderr
    manifest.write_text(json.dumps(declaration))
    preflight = subprocess.run([cli, "deploy", "--workers", f"--manifest={manifest}", f"--config={config}"], cwd=root, capture_output=True, text=True)
    assert preflight.returncode == 1 and "ProviderConfigurationDrift" in preflight.stderr
    assert "building wasm" not in preflight.stderr and "wrangler deploy" not in preflight.stderr
    config.write_text('[[env.production.d1_databases]]\nbinding="DB"\ndatabase_id="11111111-1111-1111-1111-111111111111"\n[[env.production.r2_buckets]]\nbinding="FILES"\nbucket_name="test-files"\n[env.production.vars]\nDATABASE_URL="d1:DB"\n')
    production = json.loads(run(declaration, extra=["--environment=production", "--strict"]).stderr)
    assert production["environment"] == "production"
    assert all(p["readiness"] == "validated" for p in production["providers"])
    assert "MissingCapabilityBinding" in run(declaration, 1, ["--environment=preview"]).stderr
    # JSONC is a read-only metadata view, with identical environment semantics.
    toml_config = config
    config = root / "wrangler.jsonc"
    config.write_text('''{
      // Root must not satisfy a named environment.
      "r2_buckets": [{"binding":"FILES","bucket_name":"root"}],
      "env": {"production": {
        "d1_databases": [{"binding":"DB","database_id":"11111111-1111-1111-1111-111111111111"}],
        "r2_buckets": [{"binding":"FILES","bucket_name":"production",}],
        "vars": {"DATABASE_URL":"d1:DB",},
      },},
    }''')
    jsonc = json.loads(run(declaration, extra=["--environment=production", "--strict"]).stderr)
    assert all(p["readiness"] == "validated" for p in jsonc["providers"])
    assert "MissingCapabilityBinding" in run(declaration, 1, ["--environment=preview"]).stderr
    config.write_text('{"r2_buckets":false}')
    assert "InvalidDeploymentConfig" in run(declaration, 1).stderr
    config = toml_config
    config.write_text(config.read_text().replace('DATABASE_URL="d1:DB"', 'DATABASE_URL="https://redacted.invalid"'))
    drift = run(declaration, 1, ["--environment=production"])
    assert "ProviderConfigurationDrift" in drift.stderr and "redacted.invalid" not in drift.stderr
    realtime = dict(declaration, requirements=["realtime"], providers=[{"capability": "realtime", "provider": "durable_objects", "binding": "ROOMS"}], routes=[])
    config.write_text("[[durable_objects.bindings]]\nname=\"ROOMS\"\nclass_name=\"Room\"\n")
    assert "ProviderConfigurationDrift" in run(realtime, 1).stderr
    config.write_text(config.read_text() + "[vars]\nAKAMATA_REALTIME_BINDING=\"ROOMS\"\n")
    assert json.loads(run(realtime, extra=["--strict"]).stderr)["providers"][0]["readiness"] == "validated"
    # Restore legacy fixture expectations below.
    config.write_text('[[d1_databases]]\nbinding = "DB"\n[[r2_buckets]]\nbinding = "FILES"\n')
    invalid = dict(declaration, requirements=["database", "database", "object_storage"])
    assert "InvalidCapabilityManifest" in run(invalid, 1).stderr
    invalid = dict(declaration, providers=[declaration["providers"][0], {"capability": "object_storage", "provider": "r2", "binding": "DB"}])
    assert "InvalidCapabilityManifest" in run(invalid, 1).stderr
    invalid = dict(declaration, routes=[{"method": "POST", "path": "/files", "capabilities": ["realtime"]}])
    assert "InvalidCapabilityManifest" in run(invalid, 1).stderr
    config.write_text('# [[r2_buckets]]\n# binding = "FILES"\n[[d1_databases]]\nbinding = "DB"\n')
    assert "MissingCapabilityBinding" in run(declaration, 1).stderr
    invalid = dict(declaration, target="native")
    assert "CapabilityTargetMismatch" in run(invalid, 1).stderr
    invalid = dict(declaration, providers=[{"capability": "database", "provider": "sqlite", "binding": None}])
    assert "InvalidCapabilityManifest" in run(invalid, 1).stderr
    invalid = dict(declaration, providers=[{"capability": "database", "provider": "turso", "binding": None}])
    assert "InvalidCapabilityManifest" in run(invalid, 1).stderr  # missing storage provider
    (root / "src").mkdir()
    (root / "build.zig").write_text("")
    (root / "build.zig.zon").write_text("")
    config.write_text('[[d1_databases]]\nbinding = "DB"\n[[r2_buckets]]\nbinding = "FILES"\n')
    manifest.write_text(json.dumps(declaration))
    checked = subprocess.run([cli, "check", "--quick", "--capabilities", "--target=workers",
                              f"--manifest={manifest}", f"--config={config}"], cwd=root, capture_output=True, text=True)
    assert checked.returncode == 0 and "POST /files" in checked.stderr, checked.stderr
    (root / "src/main.zig").write_text("pub fn main() void {}")
    result = subprocess.run([cli, "inspect", "capabilities"], cwd=root, capture_output=True, text=True)
    assert result.returncode == 1 and "ApplicationContractNotDeclared" in result.stderr
    result = subprocess.run([cli, "deploy", "--workers", "--environment=production", f"--config={config}"], cwd=root, capture_output=True, text=True)
    assert result.returncode == 1 and "ApplicationContractNotDeclared" in result.stderr
    assert "building wasm" not in result.stderr
    manifest.write_text(json.dumps(declaration))
    result = subprocess.run([cli, "deploy", "--containers", f"--manifest={manifest}"], cwd=root, capture_output=True, text=True)
    assert result.returncode == 1 and "CapabilityTargetMismatch" in result.stderr
    assert "docker build" not in result.stderr
print("CLI capability inspection: resolution, config drift, invalid manifests, old-project fail-fast and read-only safety passed")
