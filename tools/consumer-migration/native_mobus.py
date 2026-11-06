#!/usr/bin/env python3
"""Run existing acceptance tests only on an owned disposable loopback server."""
import argparse,subprocess,tempfile,socket,time,os,secrets,signal,json
from pathlib import Path
root=Path(__file__).resolve().parents[2];base=root/'.zig-cache/consumer-migration'
p=argparse.ArgumentParser();p.add_argument('phase',choices=['baseline','candidate']);p.add_argument('--isolation',action='store_true');a=p.parse_args()
cwd=base/'mobus-backend';binary=(base/'mobus-backend-baseline-artifacts/mobus-backend') if a.phase=='baseline' else (cwd/'zig-out/bin/mobus-backend')
logdir=base/'logs';logdir.mkdir(exist_ok=True)
with socket.socket() as probe:
    probe.bind(('127.0.0.1',0));port=probe.getsockname()[1]
with tempfile.TemporaryDirectory(prefix='akamata-consumer-mobus-') as directory:
    env=dict(os.environ,DATABASE_URL='file:'+directory+'/fixture.db',OBJECT_STORE_PATH=directory+'/objects',PORT=str(port),JWT_SECRET=secrets.token_urlsafe(48),ADMIN_SECRET=secrets.token_urlsafe(48),MOBUS_BASE_URL=f'http://127.0.0.1:{port}')
    env.pop('AKAMATA_RUNTIME',None)
    with (logdir/(a.phase+'-mobus-server.log')).open('w') as server_log:
        server=subprocess.Popen([str(binary)],cwd=cwd,env=env,stdout=server_log,stderr=server_log)
        result={'phase':a.phase,'binary':str(binary.relative_to(root)),'data':'disposable local SQLite and filesystem only','tests':[]}
        try:
            deadline=time.monotonic()+30
            while True:
                if server.poll() is not None:raise RuntimeError('server startup failed')
                try:
                    with socket.create_connection(('127.0.0.1',port),.1):break
                except OSError:
                    if time.monotonic()>deadline:raise
                    time.sleep(.02)
            suffix='-isolation' if a.isolation else ''
            path=logdir/(a.phase+'-mobus-native-e2e'+suffix+'.log')
            with path.open('w') as f:
                proc=subprocess.run(['python3','scripts/realtime_isolation_e2e.py' if a.isolation else 'scripts/native_e2e.py'],cwd=cwd,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=180)
            result['tests'].append({'name':'sender exclusion minimal reproduction' if a.isolation else 'two-user Native E2E','exit':proc.returncode,'log':str(path.relative_to(root))})
        finally:
            if server.poll() is None:server.send_signal(signal.SIGINT)
            try:server.wait(timeout=45)
            except subprocess.TimeoutExpired:server.kill();server.wait();result['forced_cleanup']=True
            result['server_exit']=server.returncode
            (base/(a.phase+'-mobus-e2e'+('-isolation' if a.isolation else '')+'.json')).write_text(json.dumps(result,indent=2)+'\n')
            print(json.dumps(result))
raise SystemExit(0 if result['server_exit'] == 0 and all(t['exit'] == 0 for t in result['tests']) else 1)
