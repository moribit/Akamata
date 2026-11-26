| Native CI host | Mode | Valid 1KiB scalar → vector ns/op | Time reduction |
| --- | --- | --- | ---: |
| ubuntu-latest | fast | 844.974 → 51.248 | 93.94% |
| ubuntu-latest | safe | 705.255 → 51.439 | 92.71% |
| ubuntu-24.04-arm | fast | 1071.781 → 76.708 | 92.84% |
| ubuntu-24.04-arm | safe | 1074.068 → 76.849 | 92.85% |
| macos-latest | fast | 1156.304 → 42.047 | 96.36% |
| macos-latest | safe | 1063.379 → 39.752 | 96.26% |
