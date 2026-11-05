#!/usr/bin/env python3
"""Serial DB microbenchmarks. Diagnostic runs are never throughput baselines."""
import argparse, csv, hashlib, json, os, platform, random, re, resource, subprocess, time
from pathlib import Path
p=argparse.ArgumentParser(); p.add_argument("binary"); p.add_argument("--output",required=True); p.add_argument("--paired"); p.add_argument("--rounds",type=int,default=3); p.add_argument("--total-ops",type=int,default=200000); a=p.parse_args()
out=Path(a.output); out.parent.mkdir(parents=True,exist_ok=True)
result={"binary":str(Path(a.binary).resolve()),"sha256":hashlib.sha256(Path(a.binary).read_bytes()).hexdigest(),"source_sha":subprocess.check_output(["git","rev-parse","HEAD"],text=True).strip(),"os":platform.platform(),"command":__import__('sys').argv,"runs":[]}
result['binaries']={k:{'path':v,'sha256':hashlib.sha256(Path(v).read_bytes()).hexdigest()} for k,v in [('A',a.binary),('B',a.paired or a.binary)]}
for r in range(a.rounds):
    cases=[(c,t) for c in range(6) for t in [1,8,32,128]]; random.Random(714+r).shuffle(cases)
    cases=[(c,t,variant) for c,t in cases for variant in ('ABBA' if a.paired else 'A')]
    for c,t,variant in cases:
        env=dict(os.environ,DB_CASE=str(c),DB_THREADS=str(t),DB_OPS=str(max(1000,a.total_ops//t)))
        before=resource.getrusage(resource.RUSAGE_CHILDREN); start=time.monotonic()
        proc=subprocess.run([result['binaries'][variant]['path']],env=env,capture_output=True,text=True,check=True)
        wall=time.monotonic()-start; after=resource.getrusage(resource.RUSAGE_CHILDREN)
        line=next(x[9:] for x in proc.stderr.splitlines() if x.startswith("DB_MICRO "))
        line=re.sub(r'("stage_(?:ns|calls)":)\{([^}]*)\}',r'\1[\2]',line)
        row=json.loads(line); row.update(variant=variant,round=r+1,process_wall_seconds=wall,cpu_seconds=after.ru_utime+after.ru_stime-before.ru_utime-before.ru_stime,max_rss_process_cumulative=after.ru_maxrss)
        result['runs'].append(row); tmp=out.with_suffix('.tmp');tmp.write_text(json.dumps(result,indent=2)+'\n');tmp.replace(out)
        print(f"{r+1} {chr(65+c)} t={t} {row['operations']*1e9/row['elapsed_ns']:.0f} op/s errors={row['errors']}",flush=True)
