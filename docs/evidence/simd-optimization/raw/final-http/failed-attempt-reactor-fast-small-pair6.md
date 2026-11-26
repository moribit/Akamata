# Baseline load error, with retained diagnostics

Reactor / ReleaseFast / empty Cookie / pair 6 baseline reported six request
errors out of approximately 369,209 attempts: two `connection closed before
message completed` and four `operation was canceled`. It returned 369,203 HTTP
200 responses. The server log only reports the experimental reactor listener;
it does not identify the cause. See the uniquely named `.failed-*.oha.stdout`,
`.oha.stderr` and `.server.log` files beside this note.

The candidate member had completed first (BA order). Its complete data bundle
is preserved in `discarded-pair6-candidate/`, and the entire pair is repeated
so the paired comparison remains adjacent. This is a second observed baseline
load failure; neither failure is evidence of a SIMD-specific fault, and neither
is concealed by reporting the zero-error acceptance cohort alone. The cause
of the baseline experimental-reactor disconnects remains unresolved.
