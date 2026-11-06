# Yaku — final staging result

Source unchanged: `f1f809fb6cba61b819dab35592b59ca7fae27db8`.
**成功**: baseline and candidate ReleaseSafe tests/Native/Workers builds; catalog
38, quiz 35 and all difficulty generation/grading/answer privacy; free-hand analysis,
glossary 49, validation/body-limit errors, OpenAPI and client in HTTP smoke.
The earlier staging browser suite passed 36/36 across mobile Chromium/WebKit,
Android Chromium and desktop Chromium, including application-served assets.
Final rebuilt WASM was redeployed and its HTTP smoke passed again.

Final isolated version: `1b1318c7-cf37-4b0e-8c1f-f666921da6f2`. No providers or
secrets. Existing app-owned 4 KiB bounded request limiter remains in front of the
managed bridge. No generated bridge was edited. CLI sync protects the current
Git-SHA dependency with AkamataDependencyNotFound; approved immutable tag pinning
must precede normal tagged sync. No DB means no migration is needed.

Formal dependency update and production rollout: **未実施**. No production Worker
was changed. Earlier 36-browser evidence and final HTTP smoke are distinct runs;
a fresh 36-browser run on the last deployment was not repeated (asset/application
source unchanged). See [deployment report](deployment-report.md).
