#!/usr/bin/env python3
"""Alternating frozen A/B HTTP fixtures. No compilation or diagnostics during load."""
import argparse, fcntl, hashlib, json, os, platform, signal, socket, subprocess, sys, tempfile, time
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'competitive/scripts'))
from measure import load, verify, WORKLOADS, require_disk_reserve
p = argparse.ArgumentParser()
p.add_argument('before')
p.add_argument('after')
p.add_argument('--output', required=True)
p.add_argument('--warmup', type=int, default=2)
p.add_argument('--duration', type=int, default=5)
p.add_argument('--cycles', type=int, default=2)
p.add_argument('--resume', action='store_true')
a = p.parse_args()
out = Path(a.output)
out.parent.mkdir(parents=True, exist_ok=True)
lock = out.with_suffix(out.suffix + '.lock').open('a+')
fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
binaries = {k: {'path': str(Path(v).resolve()), 'sha256': hashlib.sha256(Path(v).read_bytes()).hexdigest()} for k, v in [('A', a.before), ('B', a.after)]}
result = {'source_sha': subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip(), 'os': platform.platform(), 'oha': subprocess.check_output(['oha', '--version'], text=True).strip(), 'command': sys.argv, 'warmup': a.warmup, 'duration': a.duration, 'cycles': a.cycles, 'binaries': binaries, 'runs': []}
if a.resume and out.exists():
    old = json.loads(out.read_text())
    for key in ['binaries', 'warmup', 'duration', 'cycles', 'os', 'oha']:
        assert old[key] == result[key], f'drift {key}'
    result = old

def save():
    tmp = out.with_suffix('.tmp')
    tmp.write_text(json.dumps(result, indent=2) + '\n')
    tmp.replace(out)
completed = {(r['cycle'], r['workload'], r['connections'], r['position']) for r in result['runs'] if 'failure' not in r}
for cycle in range(1, a.cycles + 1):
    for workload in ['db', 'plaintext', 'json', 'echo-1024']:
        for connections in [1, 8, 32, 128, 512, 1024]:
            for position, variant in enumerate('ABBA'):
                key = (cycle, workload, connections, position)
                if key in completed:
                    continue
                require_disk_reserve(out.parent)
                row = dict(cycle=cycle, workload=workload, connections=connections, position=position, variant=variant, started_unix=time.time())
                print(key, variant, flush=True)
                with socket.socket() as probe:
                    probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                    probe.bind(('127.0.0.1', 8088))
                with tempfile.TemporaryFile() as log, tempfile.TemporaryDirectory() as directory:
                    server_env = dict(os.environ, COMPETITIVE_RUNTIME='threaded')
                    server_env.pop('BENCH_STATS', None)
                    server = subprocess.Popen([binaries[variant]['path']], env=server_env, stdout=log, stderr=log)
                    try:
                        deadline = time.monotonic() + 10
                        while True:
                            if server.poll() is not None:
                                raise RuntimeError('server exited')
                            try:
                                with socket.create_connection(('127.0.0.1', 8088), 0.2):
                                    break
                            except OSError:
                                if time.monotonic() > deadline:
                                    raise
                                time.sleep(0.02)
                        row['wire_checks'] = verify()
                        row['thermal_before'] = subprocess.run(['pmset', '-g', 'therm'], capture_output=True, text=True).stdout if platform.system() == 'Darwin' else 'unavailable'
                        method, path, body, _, _ = WORKLOADS[workload]
                        extra = []
                        if body is not None:
                            payload = Path(directory) / 'body'
                            payload.write_bytes(body)
                            extra = ['-m', method, '-T', 'application/octet-stream', '-D', str(payload)]

                        def command(seconds):
                            return ['oha', '--no-tui', '--output-format', 'json', '--http-version', '1.1', '-c', str(connections), '-z', f'{seconds}s', '-t', '10s', '-w', *extra, 'http://127.0.0.1:8088' + path]
                        row['warmup'] = load(command(a.warmup), server, a.warmup)
                        row['load_command'] = command(a.duration)
                        row.update(load(row['load_command'], server, a.duration))
                        row['thermal_after'] = subprocess.run(['pmset', '-g', 'therm'], capture_output=True, text=True).stdout if platform.system() == 'Darwin' else 'unavailable'
                    except BaseException as e:
                        row['failure'] = repr(e)
                        raise
                    finally:
                        start = time.monotonic()
                        if server.poll() is None:
                            server.send_signal(signal.SIGINT)
                        try:
                            server.wait(timeout=45)
                        except subprocess.TimeoutExpired:
                            server.kill()
                            server.wait()
                            row['forced_runner_cleanup'] = True
                        row['shutdown_ms'] = (time.monotonic() - start) * 1000
                        row['server_exit'] = server.returncode
                        log.seek(0)
                        row['server_log'] = log.read().decode(errors='replace')
                        result['runs'].append(row)
                        save()
