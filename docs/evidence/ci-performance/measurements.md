# CI timing measurements

Times are seconds. Wall includes runner queues; job sum is elapsed execution, not billed minutes.
Only successful completed runs are comparable. No estimate is presented as a measured improvement.

| Run | SHA | Result | Wall | Job sum |
|---|---|---|---:|---:|
| [42009937630](https://github.com/moribit/Akamata/actions/runs/42009937630) | 280c534 | success | 1153 | 5794 |
| [42172173403](https://github.com/moribit/Akamata/actions/runs/42172173403) | 08da8b1 | success | 953 | 5150 |
| [42180983015](https://github.com/moribit/Akamata/actions/runs/42180983015) | 7e11714 | success | 1000 | 5502 |
| [42181682857](https://github.com/moribit/Akamata/actions/runs/42181682857) | 257c33d | success | 1232 | 5328 |
| [42186696270](https://github.com/moribit/Akamata/actions/runs/42186696270) | 8e8547d | success | 651 | 5316 |
| [42187971389](https://github.com/moribit/Akamata/actions/runs/42187971389) | 54e83bf | success | 638 | 5447 |
| [42232703639](https://github.com/moribit/Akamata/actions/runs/42232703639) | 1e18bab | success | 715 | 5558 |
| [42234525201](https://github.com/moribit/Akamata/actions/runs/42234525201) | 1e18bab | success | 700 | 5442 |
| [42236457517](https://github.com/moribit/Akamata/actions/runs/42236457517) | 9e2b233 | success | 683 | 5550 |

## Run 42009937630

| Job | Start offset | Duration | Result |
|---|---:|---:|---|
| generated DX client strict typecheck | 12 | 113 | success |
| living examples (macos-latest) | 27 | 728 | success |
| linux threaded + epoll contract | 47 | 262 | success |
| living examples (ubuntu-latest) | 45 | 717 | success |
| adversarial HTTP smoke | 30 | 165 | success |
| macos native + kqueue contract | 37 | 486 | success |
| cli-build | 155 | 147 | success |
| guestbook-workers | 163 | 100 | success |
| package-archive | 76 | 110 | success |
| portable-application-workers | 52 | 119 | success |
| public documentation and PDF contract | 190 | 11 | success |
| native-test | 189 | 160 | success |
| chat-workers | 103 | 83 | success |
| device-messaging-native | 127 | 223 | success |
| private competitive fixture contracts | 181 | 264 | success |
| native-openssl | 113 | 529 | success |
| native-integration | 173 | 118 | success |
| device-messaging-workers | 74 | 113 | success |
| tasks-test | 63 | 89 | success |
| native-release-safe | 188 | 392 | success |
| chat-native | 142 | 129 | success |
| docker-build (chat container) | 645 | 228 | success |
| cli init smoke test | 645 | 508 | success |

### living-examples-macos-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug` | 164.772 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe` | 120.747 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe` | 75.647 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe` | 64.662 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe` | 63.762 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe` | 54.782 |
| `zig build documentation-test -Doptimize=ReleaseSafe` | 34.537 |
| `zig build -Dexample=device_messaging -Doptimize=Debug` | 24.257 |
| `zig build -Dexample=chat -Doptimize=Debug` | 22.831 |
| `zig build -Dexample=guestbook -Doptimize=Debug` | 17.802 |
| `zig build -Dexample=tasks -Doptimize=Debug` | 16.128 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe` | 6.187 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe` | 4.621 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe` | 4.245 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe` | 4.228 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 1.828 |

### living-examples-ubuntu-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug` | 125.741 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe` | 100.578 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe` | 92.633 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe` | 87.009 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe` | 86.757 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe` | 86.726 |
| `zig build documentation-test -Doptimize=ReleaseSafe` | 49.829 |
| `zig build -Dexample=device_messaging -Doptimize=Debug` | 9.480 |
| `zig build -Dexample=chat -Doptimize=Debug` | 9.386 |
| `zig build -Dexample=guestbook -Doptimize=Debug` | 9.308 |
| `zig build -Dexample=tasks -Doptimize=Debug` | 9.253 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe` | 6.463 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe` | 4.368 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe` | 4.311 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe` | 3.887 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-1v89jtqj/guestbook.ts` | 1.220 |

## Run 42172173403

| Job | Start offset | Duration | Result |
|---|---:|---:|---|
| living examples (ubuntu-latest) | 3 | 459 | success |
| macos native + kqueue contract | 4 | 518 | success |
| living examples (macos-latest) | 4 | 493 | success |
| chat-workers | 4 | 125 | success |
| private competitive fixture contracts | 4 | 205 | success |
| public documentation and PDF contract | 4 | 12 | success |
| adversarial HTTP smoke | 4 | 153 | success |
| portable-application-workers | 4 | 131 | success |
| native-test | 4 | 164 | success |
| cli-build | 4 | 122 | success |
| device-messaging-native | 4 | 155 | success |
| native-release-safe | 4 | 434 | success |
| linux threaded + epoll contract | 3 | 187 | success |
| package-archive | 4 | 72 | success |
| device-messaging-workers | 4 | 116 | success |
| chat-native | 4 | 140 | success |
| guestbook-workers | 4 | 110 | success |
| native-integration | 4 | 164 | success |
| native-openssl | 4 | 442 | success |
| tasks-test | 18 | 146 | success |
| generated DX client strict typecheck | 4 | 114 | success |
| docker-build (chat container) | 449 | 184 | success |
| cli init smoke test | 449 | 504 | success |

### living-examples-macos-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug` | 107.021 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe` | 66.325 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe` | 62.273 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe` | 50.605 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe` | 46.557 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe` | 41.823 |
| `zig build documentation-test -Doptimize=ReleaseSafe` | 32.133 |
| `zig build -Dexample=device_messaging -Doptimize=Debug` | 10.088 |
| `zig build -Dexample=chat -Doptimize=Debug` | 9.662 |
| `zig build -Dexample=guestbook -Doptimize=Debug` | 9.445 |
| `zig build -Dexample=tasks -Doptimize=Debug` | 9.211 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe` | 4.291 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe` | 2.980 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe` | 2.430 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe` | 2.312 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 1.822 |

### living-examples-ubuntu-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug` | 82.346 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe` | 60.951 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe` | 60.273 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe` | 56.994 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe` | 54.845 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe` | 53.653 |
| `zig build documentation-test -Doptimize=ReleaseSafe` | 31.483 |
| `zig build -Dexample=tasks -Doptimize=Debug` | 5.576 |
| `zig build -Dexample=chat -Doptimize=Debug` | 5.510 |
| `zig build -Dexample=guestbook -Doptimize=Debug` | 5.506 |
| `zig build -Dexample=device_messaging -Doptimize=Debug` | 5.490 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe` | 4.094 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe` | 2.721 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe` | 2.708 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe` | 2.386 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 0.975 |

## Run 42180983015

| Job | Start offset | Duration | Result |
|---|---:|---:|---|
| living examples (ubuntu-latest) | 3 | 710 | success |
| private competitive fixture contracts | 3 | 273 | success |
| living examples (macos-latest) | 3 | 539 | success |
| native-release-safe | 4 | 540 | success |
| public documentation and PDF contract | 3 | 12 | success |
| adversarial HTTP smoke | 3 | 213 | success |
| macos native + kqueue contract | 5 | 470 | success |
| tasks-test | 3 | 93 | success |
| guestbook-workers | 3 | 78 | success |
| generated DX client strict typecheck | 4 | 132 | success |
| chat-workers | 4 | 118 | success |
| device-messaging-native | 4 | 197 | success |
| cli-build | 4 | 144 | success |
| package-archive | 4 | 89 | success |
| native-test | 3 | 134 | success |
| native-integration | 4 | 130 | success |
| chat-native | 5 | 136 | success |
| linux threaded + epoll contract | 5 | 285 | success |
| portable-application-workers | 5 | 108 | success |
| device-messaging-workers | 4 | 111 | success |
| native-openssl | 18 | 366 | success |
| cli init smoke test | 547 | 453 | success |
| docker-build (chat container) | 547 | 171 | success |

### living-examples-macos-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug` | 126.953 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe` | 80.294 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe` | 66.301 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe` | 49.893 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe` | 47.704 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe` | 44.455 |
| `zig build documentation-test -Doptimize=ReleaseSafe` | 24.146 |
| `zig build -Dexample=device_messaging -Doptimize=Debug` | 15.754 |
| `zig build -Dexample=guestbook -Doptimize=Debug` | 15.687 |
| `zig build -Dexample=chat -Doptimize=Debug` | 13.778 |
| `zig build -Dexample=tasks -Doptimize=Debug` | 11.992 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe` | 3.836 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe` | 2.297 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe` | 2.171 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe` | 2.102 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 1.822 |

### living-examples-ubuntu-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug` | 132.041 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe` | 101.612 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe` | 89.001 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe` | 87.001 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe` | 86.226 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe` | 84.655 |
| `zig build documentation-test -Doptimize=ReleaseSafe` | 47.713 |
| `zig build -Dexample=tasks -Doptimize=Debug` | 9.608 |
| `zig build -Dexample=guestbook -Doptimize=Debug` | 9.601 |
| `zig build -Dexample=device_messaging -Doptimize=Debug` | 9.587 |
| `zig build -Dexample=chat -Doptimize=Debug` | 9.559 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe` | 6.233 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe` | 4.229 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe` | 4.194 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe` | 3.683 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-5o80wutj/guestbook.ts` | 1.151 |

## Run 42181682857

| Job | Start offset | Duration | Result |
|---|---:|---:|---|
| public documentation and PDF contract | 4 | 12 | success |
| generated DX client strict typecheck | 3 | 83 | success |
| private competitive fixture contracts | 3 | 171 | success |
| adversarial HTTP smoke | 4 | 172 | success |
| living examples (ubuntu-latest) | 4 | 688 | success |
| living examples (macos-latest) | 19 | 501 | success |
| linux threaded + epoll contract | 4 | 230 | success |
| guestbook-workers | 4 | 122 | success |
| portable-application-workers | 4 | 111 | success |
| package-archive | 3 | 110 | success |
| chat-native | 4 | 140 | success |
| native-openssl | 4 | 451 | success |
| native-test | 4 | 121 | success |
| native-integration | 4 | 173 | success |
| device-messaging-native | 4 | 179 | success |
| macos native + kqueue contract | 88 | 275 | success |
| device-messaging-workers | 93 | 113 | success |
| native-release-safe | 116 | 584 | success |
| tasks-test | 106 | 90 | success |
| chat-workers | 4 | 100 | success |
| cli-build | 4 | 144 | success |
| docker-build (chat container) | 703 | 229 | success |
| cli init smoke test | 703 | 529 | success |

### living-examples-macos-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug` | 121.805 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe` | 79.364 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe` | 51.881 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe` | 44.488 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe` | 44.275 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe` | 41.840 |
| `zig build documentation-test -Doptimize=ReleaseSafe` | 23.124 |
| `zig build -Dexample=tasks -Doptimize=Debug` | 12.593 |
| `zig build -Dexample=chat -Doptimize=Debug` | 12.458 |
| `zig build -Dexample=device_messaging -Doptimize=Debug` | 12.244 |
| `zig build -Dexample=guestbook -Doptimize=Debug` | 11.620 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe` | 3.553 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe` | 2.400 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe` | 2.300 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe` | 1.924 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 1.833 |

### living-examples-ubuntu-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug` | 119.962 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe` | 96.211 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe` | 87.291 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe` | 86.578 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe` | 84.903 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe` | 84.646 |
| `zig build documentation-test -Doptimize=ReleaseSafe` | 47.315 |
| `zig build -Dexample=device_messaging -Doptimize=Debug` | 9.329 |
| `zig build -Dexample=tasks -Doptimize=Debug` | 9.279 |
| `zig build -Dexample=guestbook -Doptimize=Debug` | 9.202 |
| `zig build -Dexample=chat -Doptimize=Debug` | 9.119 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe` | 6.178 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe` | 4.193 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe` | 4.108 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe` | 3.761 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-ze52zfw2/chat.ts` | 1.146 |

## Run 42186696270

| Job | Start offset | Duration | Result |
|---|---:|---:|---|
| docker-build (chat container) | 4 | 218 | success |
| private competitive fixture contracts | 4 | 214 | success |
| cli init smoke test | 4 | 406 | success |
| public documentation and PDF contract | 4 | 12 | success |
| living examples (ubuntu-latest) | 4 | 438 | success |
| living examples (macos-latest) | 4 | 587 | success |
| macos native + kqueue contract | 5 | 610 | success |
| generated DX client strict typecheck | 4 | 135 | success |
| adversarial HTTP smoke | 4 | 163 | success |
| tasks-test | 4 | 89 | success |
| linux threaded + epoll contract | 4 | 194 | success |
| native-release-safe | 4 | 647 | success |
| chat-native | 4 | 105 | success |
| chat-workers | 4 | 83 | success |
| package-archive | 4 | 82 | success |
| cli-build | 4 | 143 | success |
| native-openssl | 4 | 423 | success |
| native-integration | 4 | 173 | success |
| device-messaging-native | 4 | 169 | success |
| guestbook-workers | 4 | 81 | success |
| portable-application-workers | 88 | 131 | success |
| native-test | 19 | 95 | success |
| device-messaging-workers | 87 | 118 | success |

### living-examples-macos-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug` | 154.007 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe` | 69.543 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe` | 58.257 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe` | 56.226 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe` | 55.449 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe` | 45.129 |
| `zig build documentation-test -Doptimize=ReleaseSafe` | 33.141 |
| `zig build -Dexample=guestbook -Doptimize=Debug` | 16.070 |
| `zig build -Dexample=device_messaging -Doptimize=Debug` | 15.488 |
| `zig build -Dexample=tasks -Doptimize=Debug` | 13.526 |
| `zig build -Dexample=chat -Doptimize=Debug` | 12.073 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe` | 4.199 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe` | 3.401 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe` | 3.341 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe` | 2.929 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 1.515 |

### living-examples-ubuntu-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug` | 75.224 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe` | 60.328 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe` | 55.758 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe` | 54.987 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe` | 53.838 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe` | 52.770 |
| `zig build documentation-test -Doptimize=ReleaseSafe` | 29.719 |
| `zig build -Dexample=guestbook -Doptimize=Debug` | 5.283 |
| `zig build -Dexample=tasks -Doptimize=Debug` | 5.278 |
| `zig build -Dexample=device_messaging -Doptimize=Debug` | 5.278 |
| `zig build -Dexample=chat -Doptimize=Debug` | 5.151 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe` | 3.863 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe` | 2.546 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe` | 2.522 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe` | 2.293 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 0.959 |

## Run 42187971389

| Job | Start offset | Duration | Result |
|---|---:|---:|---|
| generated DX client strict typecheck | 3 | 137 | success |
| private competitive fixture contracts | 3 | 277 | success |
| adversarial HTTP smoke | 3 | 156 | success |
| cli init smoke test | 3 | 481 | success |
| native-openssl | 3 | 569 | success |
| living examples (macos-latest) | 3 | 557 | success |
| docker-build (chat container) | 3 | 178 | success |
| living examples (ubuntu-latest) | 3 | 362 | success |
| public documentation and PDF contract | 3 | 11 | success |
| portable-application-workers | 3 | 134 | success |
| chat-workers | 3 | 121 | success |
| native-integration | 3 | 125 | success |
| native-test | 3 | 139 | success |
| macos native + kqueue contract | 99 | 470 | success |
| linux threaded + epoll contract | 3 | 264 | success |
| tasks-test | 125 | 112 | success |
| device-messaging-native | 3 | 142 | success |
| guestbook-workers | 4 | 123 | success |
| device-messaging-workers | 4 | 124 | success |
| chat-native | 4 | 92 | success |
| native-release-safe | 17 | 621 | success |
| cli-build | 4 | 140 | success |
| package-archive | 11 | 112 | success |

### living-examples-macos-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug --summary all` | 108.420 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe --summary all` | 77.179 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe --summary all` | 63.452 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe --summary all` | 55.859 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe --summary all` | 52.331 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe --summary all` | 50.088 |
| `zig build documentation-test -Doptimize=ReleaseSafe --summary all` | 39.156 |
| `zig build -Dexample=guestbook -Doptimize=Debug --summary all` | 16.474 |
| `zig build -Dexample=tasks -Doptimize=Debug --summary all` | 13.945 |
| `zig build -Dexample=chat -Doptimize=Debug --summary all` | 12.922 |
| `zig build -Dexample=device_messaging -Doptimize=Debug --summary all` | 12.243 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /var/folders/n6/hn37q6pj7sj_9dmqqc2113800000gn/T/akamata-living-3310c7x6/guestbook.ts` | 2.189 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 1.916 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /var/folders/n6/hn37q6pj7sj_9dmqqc2113800000gn/T/akamata-living-3310c7x6/chat.ts` | 1.012 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /var/folders/n6/hn37q6pj7sj_9dmqqc2113800000gn/T/akamata-living-3310c7x6/device_messaging-protocol.ts` | 0.981 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /var/folders/n6/hn37q6pj7sj_9dmqqc2113800000gn/T/akamata-living-3310c7x6/chat-protocol.ts` | 0.842 |

### living-examples-ubuntu-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe --summary all` | 62.250 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe --summary all` | 54.141 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe --summary all` | 53.543 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe --summary all` | 51.283 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe --summary all` | 50.636 |
| `zig build documentation-test -Doptimize=ReleaseSafe --summary all` | 31.181 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug --summary all` | 7.488 |
| `zig build -Dexample=chat -Doptimize=Debug --summary all` | 5.873 |
| `zig build -Dexample=device_messaging -Doptimize=Debug --summary all` | 5.848 |
| `zig build -Dexample=guestbook -Doptimize=Debug --summary all` | 5.651 |
| `zig build -Dexample=tasks -Doptimize=Debug --summary all` | 5.483 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 0.961 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-e0qwi8mb/guestbook.ts` | 0.730 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-e0qwi8mb/tasks.ts` | 0.673 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-e0qwi8mb/device_messaging-protocol.ts` | 0.639 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-e0qwi8mb/chat.ts` | 0.638 |

## Run 42232703639

| Job | Start offset | Duration | Result |
|---|---:|---:|---|
| cli init smoke test | 5 | 521 | success |
| macos native + kqueue contract | 94 | 412 | success |
| chat-workers | 4 | 109 | success |
| public documentation and PDF contract | 4 | 20 | success |
| living examples (macos-latest) | 30 | 685 | success |
| tasks-test | 4 | 112 | success |
| generated DX client strict typecheck | 4 | 92 | success |
| device-messaging-workers | 5 | 124 | success |
| living examples (ubuntu-latest) | 4 | 647 | success |
| adversarial HTTP smoke | 4 | 157 | success |
| portable-application-workers | 4 | 134 | success |
| guestbook-workers | 4 | 87 | success |
| package-archive | 5 | 113 | success |
| docker-build (chat container) | 4 | 219 | success |
| private competitive fixture contracts | 4 | 281 | success |
| device-messaging-native | 5 | 214 | success |
| cli-build | 4 | 132 | success |
| chat-native | 4 | 121 | success |
| native-release-safe | 5 | 421 | success |
| native-openssl | 4 | 481 | success |
| linux threaded + epoll contract | 4 | 260 | success |
| native-integration | 99 | 119 | success |
| native-test | 4 | 97 | success |

### living-examples-macos-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug --summary all` | 141.835 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe --summary all` | 108.629 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe --summary all` | 72.738 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe --summary all` | 72.104 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe --summary all` | 61.828 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe --summary all` | 59.103 |
| `zig build documentation-test -Doptimize=ReleaseSafe --summary all` | 31.317 |
| `zig build -Dexample=device_messaging -Doptimize=Debug --summary all` | 16.522 |
| `zig build -Dexample=tasks -Doptimize=Debug --summary all` | 15.513 |
| `zig build -Dexample=guestbook -Doptimize=Debug --summary all` | 15.370 |
| `zig build -Dexample=chat -Doptimize=Debug --summary all` | 14.051 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 5.287 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 3.130 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 2.873 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 2.606 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 1.920 |

### living-examples-ubuntu-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug --summary all` | 112.911 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe --summary all` | 91.626 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe --summary all` | 80.916 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe --summary all` | 79.923 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe --summary all` | 78.922 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe --summary all` | 78.611 |
| `zig build documentation-test -Doptimize=ReleaseSafe --summary all` | 43.556 |
| `zig build -Dexample=device_messaging -Doptimize=Debug --summary all` | 8.249 |
| `zig build -Dexample=chat -Doptimize=Debug --summary all` | 8.222 |
| `zig build -Dexample=guestbook -Doptimize=Debug --summary all` | 8.121 |
| `zig build -Dexample=tasks -Doptimize=Debug --summary all` | 8.052 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 5.523 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 3.734 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 3.732 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 3.269 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-3d5duj36/guestbook.ts` | 1.011 |

## Run 42234525201

| Job | Start offset | Duration | Result |
|---|---:|---:|---|
| macos native + kqueue contract | 8 | 384 | success |
| adversarial HTTP smoke | 5 | 207 | success |
| public documentation and PDF contract | 5 | 16 | success |
| docker-build (chat container) | 5 | 194 | success |
| native-release-safe | 5 | 570 | success |
| private competitive fixture contracts | 5 | 210 | success |
| generated DX client strict typecheck | 4 | 105 | success |
| living examples (ubuntu-latest) | 5 | 695 | success |
| living examples (macos-latest) | 5 | 626 | success |
| cli init smoke test | 111 | 388 | success |
| package-archive | 5 | 112 | success |
| native-test | 5 | 159 | success |
| device-messaging-native | 5 | 199 | success |
| chat-workers | 5 | 124 | success |
| native-integration | 5 | 148 | success |
| tasks-test | 5 | 118 | success |
| guestbook-workers | 5 | 117 | success |
| chat-native | 24 | 138 | success |
| portable-application-workers | 5 | 89 | success |
| device-messaging-workers | 7 | 117 | success |
| linux threaded + epoll contract | 4 | 256 | success |
| native-openssl | 5 | 378 | success |
| cli-build | 97 | 92 | success |

### living-examples-macos-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe --summary all` | 98.769 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe --summary all` | 89.190 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe --summary all` | 84.491 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe --summary all` | 72.011 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe --summary all` | 68.739 |
| `zig build documentation-test -Doptimize=ReleaseSafe --summary all` | 38.722 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug --summary all` | 29.399 |
| `zig build -Dexample=chat -Doptimize=Debug --summary all` | 22.353 |
| `zig build -Dexample=device_messaging -Doptimize=Debug --summary all` | 20.070 |
| `zig build -Dexample=tasks -Doptimize=Debug --summary all` | 17.281 |
| `zig build -Dexample=guestbook -Doptimize=Debug --summary all` | 15.770 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /var/folders/h5/t85nd63d71x27_8gl5gw3l_w0000gn/T/akamata-living-huoigukn/guestbook.ts` | 2.490 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 1.835 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /var/folders/h5/t85nd63d71x27_8gl5gw3l_w0000gn/T/akamata-living-huoigukn/chat-protocol.ts` | 1.012 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /var/folders/h5/t85nd63d71x27_8gl5gw3l_w0000gn/T/akamata-living-huoigukn/chat.ts` | 0.830 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /var/folders/h5/t85nd63d71x27_8gl5gw3l_w0000gn/T/akamata-living-huoigukn/tasks.ts` | 0.781 |

### living-examples-ubuntu-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug --summary all` | 119.165 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe --summary all` | 99.882 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe --summary all` | 88.560 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe --summary all` | 86.878 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe --summary all` | 86.300 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe --summary all` | 85.942 |
| `zig build documentation-test -Doptimize=ReleaseSafe --summary all` | 48.280 |
| `zig build -Dexample=guestbook -Doptimize=Debug --summary all` | 9.426 |
| `zig build -Dexample=device_messaging -Doptimize=Debug --summary all` | 9.406 |
| `zig build -Dexample=tasks -Doptimize=Debug --summary all` | 9.403 |
| `zig build -Dexample=chat -Doptimize=Debug --summary all` | 9.402 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-5stt1axa/chat.ts` | 1.210 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-5stt1axa/guestbook.ts` | 1.204 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-5stt1axa/tasks.ts` | 1.197 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /tmp/akamata-living-5stt1axa/chat-protocol.ts` | 1.102 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 1.027 |

## Run 42236457517

| Job | Start offset | Duration | Result |
|---|---:|---:|---|
| public documentation and PDF contract | 4 | 13 | success |
| private competitive fixture contracts | 4 | 277 | success |
| living examples (macos-latest) | 5 | 678 | success |
| macos native + kqueue contract | 6 | 507 | success |
| docker-build (chat container) | 4 | 150 | success |
| living examples (ubuntu-latest) | 4 | 554 | success |
| adversarial HTTP smoke | 4 | 204 | success |
| cli init smoke test | 4 | 428 | success |
| generated DX client strict typecheck | 5 | 130 | success |
| tasks-test | 4 | 124 | success |
| chat-workers | 4 | 78 | success |
| native-openssl | 4 | 391 | success |
| linux threaded + epoll contract | 4 | 270 | success |
| device-messaging-workers | 4 | 95 | success |
| chat-native | 4 | 136 | success |
| native-release-safe | 5 | 591 | success |
| native-test | 4 | 151 | success |
| package-archive | 4 | 98 | success |
| portable-application-workers | 20 | 130 | success |
| cli-build | 89 | 131 | success |
| device-messaging-native | 5 | 208 | success |
| guestbook-workers | 4 | 82 | success |
| native-integration | 84 | 124 | success |

### living-examples-macos-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug --summary all` | 154.644 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe --summary all` | 113.843 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe --summary all` | 74.188 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe --summary all` | 65.304 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe --summary all` | 57.496 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe --summary all` | 56.977 |
| `zig build documentation-test -Doptimize=ReleaseSafe --summary all` | 32.156 |
| `zig build -Dexample=device_messaging -Doptimize=Debug --summary all` | 18.055 |
| `zig build -Dexample=guestbook -Doptimize=Debug --summary all` | 16.033 |
| `zig build -Dexample=tasks -Doptimize=Debug --summary all` | 15.301 |
| `zig build -Dexample=chat -Doptimize=Debug --summary all` | 15.002 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 5.279 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 3.652 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 3.167 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 3.066 |
| `node /tmp/akamata-dx-ts/node_modules/typescript/lib/tsc.js --strict --noEmit --target ES2022 --lib ES2022,DOM /var/folders/h5/t85nd63d71x27_8gl5gw3l_w0000gn/T/akamata-living-w2hsqa4r/guestbook.ts` | 1.873 |

### living-examples-ubuntu-latest: 57 commands

| Command | Seconds |
|---|---:|
| `zig build guestbook-test tasks-test chat-test -Doptimize=Debug --summary all` | 97.856 |
| `zig build guestbook-test tasks-test chat-test -Doptimize=ReleaseSafe --summary all` | 80.028 |
| `zig build -Dexample=guestbook -Doptimize=ReleaseSafe --summary all` | 68.567 |
| `zig build -Dexample=tasks -Doptimize=ReleaseSafe --summary all` | 66.516 |
| `zig build -Dexample=device_messaging -Doptimize=ReleaseSafe --summary all` | 66.417 |
| `zig build -Dexample=chat -Doptimize=ReleaseSafe --summary all` | 65.954 |
| `zig build documentation-test -Doptimize=ReleaseSafe --summary all` | 35.408 |
| `zig build -Dexample=chat -Doptimize=Debug --summary all` | 7.432 |
| `zig build -Dexample=tasks -Doptimize=Debug --summary all` | 7.426 |
| `zig build -Dexample=device_messaging -Doptimize=Debug --summary all` | 7.393 |
| `zig build -Dexample=guestbook -Doptimize=Debug --summary all` | 7.366 |
| `zig build -Dexample=guestbook -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 4.661 |
| `zig build -Dexample=tasks -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 3.148 |
| `zig build -Dexample=device_messaging -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 3.141 |
| `zig build -Dexample=chat -Dbackend=workers -Doptimize=ReleaseSafe --summary all` | 2.778 |
| `node --test tests/workers_wasm_dispatch_test.mjs` | 0.984 |
