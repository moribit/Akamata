#!/usr/bin/env python3
"""Write isolated configs and fresh test credentials; never reads production secrets."""
import base64
import json
import pathlib
import secrets

ROOT = pathlib.Path(__file__).resolve().parents[2]
S = ROOT / '.zig-cache/consumer-migration'
PREFIX = 'akamata-migration-20261106-'
DOMAIN = '.mimoc-maker.workers.dev'


def main():
    resources = json.loads((S / 'staging-resources.json').read_text())
    credentials = S / 'staging-test-credentials.json'
    if not credentials.exists():
        credentials.write_text(json.dumps({
            'JWT_SECRET': secrets.token_hex(32),
            'ADMIN_SECRET': secrets.token_hex(32),
            'BASIC_AUTH_TOKEN': base64.b64encode(('migration:' + secrets.token_hex(24)).encode()).decode(),
        }))
        credentials.chmod(0o600)
    values = json.loads(credentials.read_text())
    for repo, app, main_file, date in (
        ('mimoc_news', 'news', 'worker/index.mjs', '2026-08-08'),
        ('Ehagaki', 'ehagaki', 'worker/index.mjs', '2026-01-15'),
        ('mobus-backend', 'mobus', 'worker/gateway.mjs', '2026-08-21'),
    ):
        name = PREFIX + app
        db = resources['d1'][app]
        config = dict(name=name, main=main_file, compatibility_date=date,
                      compatibility_flags=['nodejs_compat'], workers_dev=True,
                      d1_databases=[dict(binding='DB', database_name=db['name'], database_id=db['id'])],
                      observability=dict(enabled=True, head_sampling_rate=1))
        if app == 'news':
            config['vars'] = dict(DATABASE_URL='d1:DB', MIMOC_NEWS_AUTO_MIGRATE='false',
                                  IMAGE_PUBLIC_BASE_URL='https://' + name + DOMAIN + '/images')
            config['r2_buckets'] = [dict(binding='NEWS_IMAGES', bucket_name=resources['r2'][app])]
        elif app == 'ehagaki':
            config['vars'] = dict(DATABASE_URL='d1:DB', EHAGAKI_AUTO_MIGRATE='false', MOBUS_BASE_URL='https://' + PREFIX + 'mobus' + DOMAIN)
        else:
            config['d1_databases'][0]['migrations_dir'] = '../migrations'
            config['vars'] = dict(DATABASE_URL='d1:DB')
            config['r2_buckets'] = [dict(binding='FILES', bucket_name=resources['r2'][app])]
            config['services'] = [dict(binding='AKAMATA_REALTIME_HANDLER', service=PREFIX + 'rt', entrypoint='AkamataRealtimeApplication'),
                                  dict(binding='EHAGAKI', service=PREFIX + 'ehagaki')]
            config['durable_objects'] = dict(bindings=[dict(name='AKAMATA_REALTIME', class_name='AkamataRealtimeRoom')])
            config['migrations'] = [dict(tag='v1', new_sqlite_classes=['AkamataRealtimeRoom'])]
        path = S / repo / 'deploy/wrangler.migration-staging.json'
        path.write_text(json.dumps(config, indent=2) + '\n')
        selected = {'BASIC_AUTH_TOKEN': values['BASIC_AUTH_TOKEN']} if app == 'news' else {
            k: values[k] for k in ('JWT_SECRET', 'ADMIN_SECRET') if app == 'mobus' or k == 'JWT_SECRET'}
        secret_file = S / (app + '-test-secrets.json')
        secret_file.write_text(json.dumps(selected))
        secret_file.chmod(0o600)
        if app == 'mobus':
            handler = {k: v for k, v in config.items() if k not in ('services', 'durable_objects', 'migrations')}
            handler.update(name=PREFIX + 'rt', main='worker/realtime_handler.mjs')
            (path.parent / 'wrangler.migration-handler.json').write_text(json.dumps(handler, indent=2) + '\n')
        print('configured isolated target:', name)


if __name__ == '__main__':
    main()
