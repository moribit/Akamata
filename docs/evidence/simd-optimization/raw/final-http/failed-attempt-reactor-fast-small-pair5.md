# Interrupted baseline measurement

The first attempt at Reactor / ReleaseFast / empty Cookie / pair 5 baseline
failed the collector assertion `SIMD HTTP has no request errors`. The preceding
four pairs and the two Threaded mode matrices had completed. The candidate
member of this pair had not started, and neither member has a completed marker.

The original collector asserted before persisting oha stdout. Consequently the
error-distribution body and fixture log for this failed attempt were lost; the
only retained diagnostic is the assertion and stack location in
`tests/runner/simd_http.zig:68`. The specific request error and its cause cannot
be determined retrospectively. This is a baseline failure, not evidence of a
SIMD-specific regression, and it is not silently counted as a successful run.

The collector was changed to persist unique failure stdout/stderr/server-log
files on errors. The incomplete pair is repeated in its entirety. Completed
earlier pairs are retained unchanged. Final summary statistics include only
the specified complete zero-error pairs; this failure remains disclosed.
