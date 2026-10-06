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
    assert "ready" not in result.stderr
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
print("CLI capability inspection: resolution, config drift, invalid manifests, old-project fail-fast and read-only safety passed")
