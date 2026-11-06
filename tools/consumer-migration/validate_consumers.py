#!/usr/bin/env python3
"""Build/test isolated checkouts. No deployment, migrations, secrets or production URLs."""
import argparse,subprocess,json,time,hashlib,os
from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();selection=p.add_mutually_exclusive_group();selection.add_argument('--candidate',action='store_true');selection.add_argument('--release',action='store_true');a=p.parse_args()
base=root/'.zig-cache/consumer-migration';phase='published' if a.release else ('candidate' if a.candidate else 'baseline');runs=[]
for name in ['Yaku','mimoc_news','Ehagaki','mobus-backend']:
    cwd=base/name
    commands=[['zig','build','test','-Doptimize=ReleaseSafe','-j2','--summary','all'],['zig','build','-Doptimize=ReleaseSafe','-j2','--summary','all'],['zig','build','-Dbackend=workers','-Doptimize=ReleaseSafe','-j2','--summary','all']]
    for index,command in enumerate(commands):
        if a.candidate:command.append('--fork='+str(root))
        logs=base/'logs';logs.mkdir(exist_ok=True);log=logs/f'{phase}-{name}-{index}.log'
        print(phase,name,index,command,flush=True)
        env=dict(os.environ);env.pop('DATABASE_URL',None);env.pop('JWT_SECRET',None);env.pop('ADMIN_SECRET',None)
        started=time.monotonic()
        with log.open('w') as f:
            try:r=subprocess.run(command,cwd=cwd,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=900);status=r.returncode
            except subprocess.TimeoutExpired:status=124
        runs.append(dict(repo=name,command=command,exit=status,seconds=time.monotonic()-started,log=str(log.relative_to(root))))
        source='v0.2.1^{}' if a.release else 'HEAD'
        (base/(phase+'.json')).write_text(json.dumps({'phase':phase,'akamata_sha':subprocess.check_output(['git','rev-parse',source],cwd=root,text=True).strip(),'runs':runs},indent=2)+'\n')
        print('result',status,flush=True)
raise SystemExit(1 if any(row['exit'] != 0 for row in runs) else 0)
