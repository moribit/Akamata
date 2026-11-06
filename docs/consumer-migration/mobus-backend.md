# mobus-backend — final staging result

Original SHA: da3f9c0. Isolated validated SHA:
`dd8273beb0fa47f119c59304e740c1d0b9fa667a` (app fix c389a8e plus acceptance coverage).
Native production remains Threaded. Original checkout/production unchanged.

## Realtime finding and correction

**失敗 (before)**: a minimal two-client call test on the saved baseline and the
candidate before app repair receives the sender own client event. Native app
called broadcast; Workers action already used broadcast_except_sender. This is
an application semantic difference, not evidence of an Akamata delivery failure.

**成功 (after)**: existing Service.room(...).broadcastExcept(..., connection_id)
is used only for Native client-originated events. REST-originated notification
broadcast behavior is retained. Same acceptance driver passes Native and real
Workers: two-user connections, offers/accept, bidirectional Signal/Text, sender
silence, disconnect/reconnect, end/status, unauthorized room rejection, unknown
event rejection and clean socket close. Workers uses a separate named application
handler via Service Binding and a dedicated DO namespace. Internal authorization
route is accessible to the Native local fixture but correctly 404 on the public
Workers gateway. Eight mock gateway/dispatch contracts also passed earlier.

## Firmware and provider finding

**失敗 (before)**: newly added Native HEAD followed by Range exposed a segmentation
fault serializing Storage headers after reader cleanup. **成功 (after)**: Akamata
0ea0c17 snapshots ETag/Content-Type into request arena. Poison-on-close regression
fails with the old two lines and passes after correction. Full Native acceptance
then exits 0 with a clean server exit; Workers HEAD/Range passes too.

**成功**: actual D1 migrations (four existing files, empty isolated DB), user/auth,
friend/messages/unread, check-in ownership, firmware manifest/upload, wrong size
rejection, same-size wrong-digest rejection, full download byte/SHA-256 verification, publish/latest, HEAD/Range bytes, crash upload,
and dedicated R2 readback of synthetic dump bytes. Gateway-to-Ehagaki succeeds.
Firmware test device/version names are unique so repeated tests do not overwrite
existing published artifacts. No real firmware or device credential is used.

Final gateway version: `e4eae085-faf5-40ff-8310-85c947dd6977`;
handler: `37183f27-c433-4580-8f51-abdbc881136f`.
Dependency update changes no SQL schema. Production SQLite-to-D1 import, write
freeze, backup/count verification, real ESP32 hardware test, production key equality,
cutover/rollback rehearsal and production rollout are **未実施** and remain separate
gates. This work does not certify that historical production DB cutover is ready.
See [live evidence](evidence/mobus-live.json) and [deployment report](deployment-report.md).

Final supplemental acceptance driver commit: `6607725` (test-only; application/WASM source unchanged from dd8273b). Private local bundle refreshed after this commit.
