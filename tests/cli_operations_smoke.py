#!/usr/bin/env python3
"""CLI command contracts using fake external tools; no accounts or deployment."""
import json
import os
from pathlib import Path
import subprocess
import signal
import time
import sys
import tempfile

cli = str(Path(sys.argv[1]).resolve())
uuid = "abcd1234-5678-9abc-def0-fedcba987654"
with tempfile.TemporaryDirectory(prefix="akamata-operations-") as directory:
    root = Path(directory)
    bin_dir = root / "bin"
    bin_dir.mkdir()
    mock = r"""#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
args = [Path(sys.argv[0]).name, *sys.argv[1:]]
with open(os.environ['MOCK_LOG'], 'a') as f: f.write(json.dumps(args) + '\n')
mode = os.environ.get('MOCK_MODE', 'create')
if args[0] == 'npx' and args[1:4] == ['wrangler', 'd1', 'create']:
    if mode == 'exists': print('already exists'); sys.exit(1)
    if mode == 'fail': print('permission denied'); sys.exit(1)
    print('database_id = "abcd1234-5678-9abc-def0-fedcba987654"')
elif args[0] == 'npx' and args[1:4] == ['wrangler', 'd1', 'list']:
    print('[banner]\n' + json.dumps([{'name': 'test-db', 'uuid': 'abcd1234-5678-9abc-def0-fedcba987654'}]))
elif mode == 'fail-build' and args[0] == 'zig': sys.exit(1)
"""
    for name in ['zig', 'npx', 'docker']:
        p = bin_dir / name
        p.write_text(mock)
        p.chmod(0o755)
    config = root / "custom.toml"
    initial = 'name = "test"\n# retain this comment\n[[d1_databases]]\nbinding = "DB"\ndatabase_name = "test-db"\ndatabase_id = "00000000-0000-0000-0000-000000000000"\n'
    log = root / "commands.jsonl"
    env = dict(os.environ, PATH=str(bin_dir) + os.pathsep + os.environ['PATH'], MOCK_LOG=str(log))

    def run(args, mode='create', success=True):
        log.write_text('')
        result = subprocess.run([cli, *args], cwd=root, env=dict(env, MOCK_MODE=mode), capture_output=True)
        assert (result.returncode == 0) == success, result.stderr.decode()
        if not success:
            assert result.returncode == 1, result.returncode
        return [json.loads(line) for line in log.read_text().splitlines()]

    for mode in ['create', 'exists']:
        config.write_text(initial)
        calls = run(['deploy', '--workers', '--config=custom.toml', '--migrate=schema.sql'], mode)
        expected = [['npx', 'wrangler', 'd1', 'create', 'test-db']]
        if mode == 'exists': expected += [['npx', 'wrangler', 'd1', 'list', '--json']]
        expected += [
            ['npx', 'wrangler', 'd1', 'execute', 'test-db', '--remote', '--config', 'custom.toml', '--file', 'schema.sql', '--yes'],
            ['zig', 'build', '-Dbackend=workers', '-Doptimize=ReleaseFast'],
            ['npx', 'wrangler', 'deploy', '--config', 'custom.toml'],
        ]
        assert calls == expected, calls
        assert config.read_text() == initial.replace('00000000-0000-0000-0000-000000000000', uuid)
        calls = run(['deploy', '--workers', '--config=custom.toml', '--optimize=ReleaseSafe'])
        assert calls == [['zig', 'build', '-Dbackend=workers', '-Doptimize=ReleaseSafe'], ['npx', 'wrangler', 'deploy', '--config', 'custom.toml']]
    config.write_text(initial)
    calls = run(['deploy', '--workers', '--config=custom.toml'], 'fail', False)
    assert len(calls) == 1
    assert config.read_text() == initial
    config.write_text(initial.replace('00000000-0000-0000-0000-000000000000', uuid))
    calls = run(['deploy', '--workers', '--config=custom.toml'], 'fail-build', False)
    assert calls == [['zig', 'build', '-Dbackend=workers', '-Doptimize=ReleaseFast']]
    assert run(['db', 'schema.sql', '--remote', '--config=custom.toml']) == [['npx', 'wrangler', 'd1', 'execute', 'test-db', '--remote', '--config', 'custom.toml', '--file', 'schema.sql', '--yes']]
    assert run(['db', 'schema.sql']) == [['npx', 'wrangler', 'd1', 'execute', 'DB', '--local', '--file', 'schema.sql', '--yes']]
    config.rename(root / 'wrangler.toml')
    assert run(['db', 'schema.sql']) == [['npx', 'wrangler', 'd1', 'execute', 'test-db', '--local', '--file', 'schema.sql', '--yes']]
    assert run(['deploy', '--containers']) == [['zig', 'build', '-Dtarget=x86_64-linux-musl', '-Doptimize=ReleaseFast'], ['docker', 'build', '-f', 'deploy/Dockerfile', '-t', 'akamata-app', '.']]
    assert run(['build', '--workers', '--optimize=ReleaseSmall']) == [['zig', 'build', '-Dbackend=workers', '-Doptimize=ReleaseSmall']]
    assert run(['dev', '--no-watch']) == [['zig', 'build', 'run']]
    # Exercise the actual watcher/process-group path, not only --no-watch.
    (root / 'build.zig.zon').write_text('.{ .name = .watch_app }')
    (root / 'src').mkdir()
    source = root / 'src/main.zig'
    source.write_text('first')
    app_dir = root / 'zig-out/bin'
    app_dir.mkdir(parents=True)
    watched = app_dir / 'watch_app'
    watched.write_text(r"""#!/usr/bin/env python3
import json, os, signal, sys, time
with open(os.environ['MOCK_LOG'], 'a') as f: f.write(json.dumps(['watch_app', os.getpid()]) + '\n')
signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
while True: time.sleep(0.1)
""")
    watched.chmod(0o755)
    log.write_text('')
    dev = subprocess.Popen([cli, 'dev'], cwd=root, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)

    def wait_for_children(count):
        deadline = time.monotonic() + 8
        while time.monotonic() < deadline:
            calls = [json.loads(line) for line in log.read_text().splitlines()]
            pids = [call[1] for call in calls if call[0] == 'watch_app']
            if len(pids) >= count:
                return pids
            assert dev.poll() is None, dev.communicate()[1].decode()
            time.sleep(0.05)
        raise AssertionError('dev did not start/restart its child')

    try:
        pids = wait_for_children(1)
        source.write_text('second version')
        pids = wait_for_children(2)
    finally:
        dev.send_signal(signal.SIGINT)
        _, stderr = dev.communicate(timeout=8)
    assert dev.returncode == 0, stderr.decode()
    for pid in pids:
        try:
            os.kill(pid, 0)
        except ProcessLookupError:
            continue
        raise AssertionError(f'dev orphaned child {pid}')
print('CLI operations smoke: deploy, D1 provisioning, failure safety, build, dev restart/shutdown and containers OK')
