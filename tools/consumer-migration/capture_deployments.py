#!/usr/bin/env python3
"""Read only Worker deployment/secret-name inventory; never reads secret values."""
import subprocess,json,re
from pathlib import Path
root=Path(__file__).resolve().parents[2];base=root/'.zig-cache/consumer-migration';rows=[]
for repo,name,config in [('Yaku','yaku-mvp','deploy/wrangler.toml'),('mimoc_news','mimoc-news','deploy/wrangler.jsonc'),('Ehagaki','ehagaki','deploy/wrangler.toml'),('mobus-backend','mobus-backend','deploy/wrangler.toml'),('mobus-backend','mobus-realtime-handler','deploy/wrangler.realtime-handler.toml')]:
    row={'repo':repo,'worker':name}
    for kind,args in [('deployments',['deployments','list','--json']),('secrets',['secret','list'])]:
        command=['wrangler',*args,'--config',str(base/repo/config),'--name',name]
        result=subprocess.run(command,cwd=base/repo,capture_output=True,text=True,timeout=90)
        row[kind+'_exit']=result.returncode
        try:
            # stdout must be machine-readable: fail rather than publishing logs.
            data=json.loads(result.stdout)
            if kind=='secrets':row['secret_names']=[x['name'] for x in data]
            else:row['deployments']=data
        except (ValueError,KeyError,TypeError):
            row[kind+'_status']='unavailable; inspect private scratch log'
            # No command output is copied to public evidence on failure.
        print(repo,name,kind,'exit',result.returncode,flush=True)
    rows.append(row)
    (base/'deployments.json').write_text(json.dumps(rows,indent=2)+'\n')
