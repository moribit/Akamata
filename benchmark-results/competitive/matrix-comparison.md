# Full Native matrix comparison

1260 baseline and 630 after cases; five 30-second rounds after 10-second warmup.
Medians of all rounds; latency is median of round percentiles, not pooled.
CPU: one core = 100%; RSS: median sampled round mean. All errors retained.

| Workload | Connections | After runtime | Before HTTP 200/s | After HTTP 200/s | Change % | Before P99 ms | After P99 ms | Before CPU % | After CPU % | Before RSS KiB | After RSS KiB | After threads | After client errors | After non-200 | After forced cleanup |
|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| plaintext | 1 | akamata-threaded-after | 27132 | 27289 | +0.58 | 0.055 | 0.051 | 23.0 | 23.2 | 4157 | 4221 | 9 | 0 | 0 | 0 |
| plaintext | 1 | akamata-reactor-single-after | 27132 | 20975 | -22.69 | 0.055 | 0.062 | 23.0 | 37.4 | 4157 | 4608 | 9 | 0 | 0 | 0 |
| plaintext | 1 | akamata-reactor-sharded-after | 27132 | 21176 | -21.95 | 0.055 | 0.060 | 23.0 | 37.1 | 4157 | 5279 | 12 | 0 | 0 | 0 |
| plaintext | 8 | akamata-threaded-after | 105143 | 89314 | -15.05 | 0.150 | 0.149 | 165.3 | 172.2 | 5104 | 5178 | 16 | 0 | 0 | 0 |
| plaintext | 8 | akamata-reactor-single-after | 105143 | 63835 | -39.29 | 0.150 | 0.223 | 165.3 | 167.7 | 5104 | 4784 | 9 | 0 | 0 | 0 |
| plaintext | 8 | akamata-reactor-sharded-after | 105143 | 61534 | -41.48 | 0.150 | 0.260 | 165.3 | 239.7 | 5104 | 5607 | 12 | 0 | 0 | 0 |
| plaintext | 32 | akamata-threaded-after | 89479 | 142245 | +58.97 | 0.569 | 0.863 | 206.3 | 340.9 | 8233 | 8281 | 40 | 0 | 0 | 0 |
| plaintext | 32 | akamata-reactor-single-after | 89479 | 72121 | -19.40 | 0.569 | 0.788 | 206.3 | 182.9 | 8233 | 5440 | 9 | 0 | 0 | 0 |
| plaintext | 32 | akamata-reactor-sharded-after | 89479 | 96831 | +8.22 | 0.569 | 0.881 | 206.3 | 371.0 | 8233 | 6334 | 12 | 0 | 0 | 0 |
| plaintext | 128 | akamata-threaded-after | 169325 | 160884 | -4.98 | 6.728 | 4.331 | 255.9 | 341.5 | 20682 | 20571 | 136 | 0 | 0 | 0 |
| plaintext | 128 | akamata-reactor-single-after | 169325 | 88920 | -47.49 | 6.728 | 2.307 | 255.9 | 183.6 | 20682 | 7936 | 9 | 0 | 0 | 0 |
| plaintext | 128 | akamata-reactor-sharded-after | 169325 | 111238 | -34.31 | 6.728 | 2.994 | 255.9 | 312.3 | 20682 | 8843 | 12 | 0 | 0 | 0 |
| plaintext | 512 | akamata-threaded-after | 141934 | 144047 | +1.49 | 26.319 | 21.877 | 330.9 | 338.7 | 70314 | 69471 | 520 | 0 | 0 | 0 |
| plaintext | 512 | akamata-reactor-single-after | 141934 | 85937 | -39.45 | 26.319 | 7.673 | 330.9 | 180.4 | 70314 | 17920 | 9 | 3 | 0 | 0 |
| plaintext | 512 | akamata-reactor-sharded-after | 141934 | 121101 | -14.68 | 26.319 | 12.331 | 330.9 | 368.4 | 70314 | 18876 | 12 | 13 | 0 | 0 |
| plaintext | 1024 | akamata-threaded-after | 129266 | 137681 | +6.51 | 38.148 | 39.249 | 362.6 | 367.4 | 135513 | 135105 | 1032 | 1720 | 0 | 0 |
| plaintext | 1024 | akamata-reactor-single-after | 129266 | 94196 | -27.13 | 38.148 | 14.402 | 362.6 | 179.4 | 135513 | 31200 | 9 | 0 | 0 | 0 |
| plaintext | 1024 | akamata-reactor-sharded-after | 129266 | 152274 | +17.80 | 38.148 | 19.127 | 362.6 | 389.7 | 135513 | 32466 | 12 | 1018 | 0 | 0 |
| json | 1 | akamata-threaded-after | 27215 | 27747 | +1.95 | 0.054 | 0.045 | 22.9 | 22.8 | 4157 | 4221 | 9 | 0 | 0 | 0 |
| json | 1 | akamata-reactor-single-after | 27215 | 21188 | -22.14 | 0.054 | 0.058 | 22.9 | 37.1 | 4157 | 4624 | 9 | 1 | 0 | 0 |
| json | 1 | akamata-reactor-sharded-after | 27215 | 21208 | -22.07 | 0.054 | 0.058 | 22.9 | 37.3 | 4157 | 5152 | 12 | 1 | 0 | 0 |
| json | 8 | akamata-threaded-after | 87005 | 114068 | +31.10 | 0.158 | 0.115 | 173.4 | 172.2 | 5097 | 5162 | 16 | 0 | 0 | 0 |
| json | 8 | akamata-reactor-single-after | 87005 | 80907 | -7.01 | 0.158 | 0.174 | 173.4 | 168.7 | 5097 | 4784 | 9 | 0 | 0 | 0 |
| json | 8 | akamata-reactor-sharded-after | 87005 | 82502 | -5.18 | 0.158 | 0.177 | 173.4 | 220.9 | 5097 | 5692 | 12 | 6 | 0 | 0 |
| json | 32 | akamata-threaded-after | 136871 | 154732 | +13.05 | 1.045 | 0.878 | 321.7 | 336.2 | 8186 | 8403 | 40 | 23 | 0 | 0 |
| json | 32 | akamata-reactor-single-after | 136871 | 88652 | -35.23 | 1.045 | 0.607 | 321.7 | 190.7 | 8186 | 5440 | 9 | 0 | 0 | 0 |
| json | 32 | akamata-reactor-sharded-after | 136871 | 103508 | -24.37 | 1.045 | 0.796 | 321.7 | 324.1 | 8186 | 6349 | 12 | 0 | 0 | 0 |
| json | 128 | akamata-threaded-after | 154678 | 174791 | +13.00 | 5.529 | 4.772 | 320.8 | 314.3 | 20569 | 20596 | 136 | 0 | 0 | 0 |
| json | 128 | akamata-reactor-single-after | 154678 | 91388 | -40.92 | 5.529 | 2.341 | 320.8 | 185.7 | 20569 | 7920 | 9 | 55 | 0 | 0 |
| json | 128 | akamata-reactor-sharded-after | 154678 | 124840 | -19.29 | 5.529 | 3.044 | 320.8 | 328.4 | 20569 | 8795 | 12 | 70 | 0 | 0 |
| json | 512 | akamata-threaded-after | 148583 | 171776 | +15.61 | 20.105 | 21.505 | 335.0 | 326.9 | 69794 | 69641 | 520 | 0 | 0 | 0 |
| json | 512 | akamata-reactor-single-after | 148583 | 95044 | -36.03 | 20.105 | 6.884 | 335.0 | 185.5 | 69794 | 17920 | 9 | 0 | 0 | 0 |
| json | 512 | akamata-reactor-sharded-after | 148583 | 135349 | -8.91 | 20.105 | 11.796 | 335.0 | 398.7 | 69794 | 18799 | 12 | 0 | 0 | 0 |
| json | 1024 | akamata-threaded-after | 124325 | 151338 | +21.73 | 34.393 | 37.449 | 362.5 | 366.7 | 135353 | 136898 | 1032 | 2043 | 0 | 0 |
| json | 1024 | akamata-reactor-single-after | 124325 | 94023 | -24.37 | 34.393 | 13.811 | 362.5 | 181.1 | 135353 | 31232 | 9 | 2538 | 0 | 0 |
| json | 1024 | akamata-reactor-sharded-after | 124325 | 159595 | +28.37 | 34.393 | 17.657 | 362.5 | 401.3 | 135353 | 32406 | 12 | 0 | 0 | 0 |
| routing | 1 | akamata-threaded-after | 27138 | 27504 | +1.35 | 0.052 | 0.046 | 23.7 | 23.4 | 4157 | 4221 | 9 | 0 | 0 | 0 |
| routing | 1 | akamata-reactor-single-after | 27138 | 21261 | -21.66 | 0.052 | 0.057 | 23.7 | 37.3 | 4157 | 4624 | 9 | 0 | 0 | 0 |
| routing | 1 | akamata-reactor-sharded-after | 27138 | 21220 | -21.81 | 0.052 | 0.058 | 23.7 | 37.0 | 4157 | 5152 | 12 | 0 | 0 | 0 |
| routing | 8 | akamata-threaded-after | 73205 | 107688 | +47.11 | 0.177 | 0.119 | 174.8 | 175.1 | 5098 | 5192 | 16 | 3 | 0 | 0 |
| routing | 8 | akamata-reactor-single-after | 73205 | 83717 | +14.36 | 0.177 | 0.165 | 174.8 | 167.9 | 5098 | 4784 | 9 | 7 | 0 | 0 |
| routing | 8 | akamata-reactor-sharded-after | 73205 | 85723 | +17.10 | 0.177 | 0.169 | 174.8 | 195.8 | 5098 | 5518 | 12 | 0 | 0 | 0 |
| routing | 32 | akamata-threaded-after | 132714 | 144203 | +8.66 | 1.022 | 0.924 | 318.2 | 323.6 | 8232 | 8280 | 40 | 18 | 0 | 0 |
| routing | 32 | akamata-reactor-single-after | 132714 | 84844 | -36.07 | 1.022 | 0.628 | 318.2 | 188.5 | 8232 | 5440 | 9 | 0 | 0 | 0 |
| routing | 32 | akamata-reactor-sharded-after | 132714 | 105925 | -20.19 | 1.022 | 0.720 | 318.2 | 292.4 | 8232 | 6238 | 12 | 0 | 0 | 0 |
| routing | 128 | akamata-threaded-after | 162024 | 170423 | +5.18 | 5.501 | 4.769 | 328.5 | 316.3 | 20661 | 20633 | 136 | 0 | 0 | 0 |
| routing | 128 | akamata-reactor-single-after | 162024 | 92695 | -42.79 | 5.501 | 2.198 | 328.5 | 186.5 | 20661 | 7936 | 9 | 25 | 0 | 0 |
| routing | 128 | akamata-reactor-sharded-after | 162024 | 122937 | -24.12 | 5.501 | 3.228 | 328.5 | 362.7 | 20661 | 8795 | 12 | 0 | 0 | 0 |
| routing | 512 | akamata-threaded-after | 150173 | 164017 | +9.22 | 21.973 | 24.324 | 349.6 | 316.4 | 70097 | 70106 | 520 | 58 | 0 | 0 |
| routing | 512 | akamata-reactor-single-after | 150173 | 92415 | -38.46 | 21.973 | 7.286 | 349.6 | 177.4 | 70097 | 17904 | 9 | 0 | 0 | 0 |
| routing | 512 | akamata-reactor-sharded-after | 150173 | 133391 | -11.18 | 21.973 | 11.622 | 349.6 | 369.6 | 70097 | 18906 | 12 | 0 | 0 | 0 |
| routing | 1024 | akamata-threaded-after | 118471 | 145964 | +23.21 | 39.213 | 38.525 | 335.0 | 363.9 | 135960 | 136420 | 1032 | 1046 | 0 | 0 |
| routing | 1024 | akamata-reactor-single-after | 118471 | 89831 | -24.18 | 39.213 | 14.519 | 335.0 | 179.9 | 135960 | 31216 | 9 | 0 | 0 | 0 |
| routing | 1024 | akamata-reactor-sharded-after | 118471 | 151890 | +28.21 | 39.213 | 18.521 | 335.0 | 390.4 | 135960 | 32188 | 12 | 0 | 0 | 0 |
| db | 1 | akamata-threaded-after | 23340 | 23658 | +1.36 | 0.061 | 0.053 | 29.9 | 30.2 | 4157 | 4221 | 9 | 1 | 0 | 0 |
| db | 1 | akamata-reactor-single-after | 23340 | 20511 | -12.12 | 0.061 | 0.062 | 29.9 | 39.3 | 4157 | 4720 | 9 | 0 | 0 | 0 |
| db | 1 | akamata-reactor-sharded-after | 23340 | 20574 | -11.85 | 0.061 | 0.062 | 29.9 | 39.3 | 4157 | 5358 | 12 | 0 | 0 | 0 |
| db | 8 | akamata-threaded-after | 80460 | 101613 | +26.29 | 0.168 | 0.133 | 200.7 | 208.9 | 5083 | 5147 | 16 | 0 | 0 | 0 |
| db | 8 | akamata-reactor-single-after | 80460 | 79264 | -1.49 | 0.168 | 0.177 | 200.7 | 194.0 | 5083 | 4880 | 9 | 0 | 0 | 0 |
| db | 8 | akamata-reactor-sharded-after | 80460 | 70765 | -12.05 | 0.168 | 0.209 | 200.7 | 208.0 | 5083 | 5722 | 12 | 0 | 0 | 0 |
| db | 32 | akamata-threaded-after | 85302 | 125333 | +46.93 | 1.776 | 1.734 | 299.2 | 345.7 | 8325 | 8172 | 40 | 15 | 0 | 0 |
| db | 32 | akamata-reactor-single-after | 85302 | 75114 | -11.94 | 1.776 | 0.828 | 299.2 | 226.4 | 8325 | 5552 | 9 | 0 | 0 | 0 |
| db | 32 | akamata-reactor-sharded-after | 85302 | 98481 | +15.45 | 1.776 | 0.787 | 299.2 | 363.6 | 8325 | 6458 | 12 | 0 | 0 | 0 |
| db | 128 | akamata-threaded-after | 120300 | 144884 | +20.44 | 10.474 | 8.786 | 339.5 | 357.3 | 20662 | 20571 | 136 | 70 | 0 | 0 |
| db | 128 | akamata-reactor-single-after | 120300 | 80839 | -32.80 | 10.474 | 2.900 | 339.5 | 231.3 | 20662 | 8016 | 9 | 79 | 0 | 0 |
| db | 128 | akamata-reactor-sharded-after | 120300 | 114407 | -4.90 | 10.474 | 3.391 | 339.5 | 360.0 | 20662 | 9009 | 12 | 95 | 0 | 0 |
| db | 512 | akamata-threaded-after | 119150 | 131729 | +10.56 | 34.889 | 33.821 | 353.2 | 349.1 | 68479 | 68801 | 520 | 0 | 0 | 0 |
| db | 512 | akamata-reactor-single-after | 119150 | 82309 | -30.92 | 34.889 | 7.760 | 353.2 | 229.3 | 68479 | 18032 | 9 | 0 | 0 | 0 |
| db | 512 | akamata-reactor-sharded-after | 119150 | 123987 | +4.06 | 34.889 | 15.842 | 353.2 | 381.3 | 68479 | 18988 | 12 | 0 | 0 | 0 |
| db | 1024 | akamata-threaded-after | 106809 | 126368 | +18.31 | 55.277 | 41.619 | 385.8 | 361.9 | 134837 | 133326 | 1032 | 1254 | 0 | 0 |
| db | 1024 | akamata-reactor-single-after | 106809 | 80172 | -24.94 | 55.277 | 15.727 | 385.8 | 222.3 | 134837 | 31328 | 9 | 11 | 0 | 0 |
| db | 1024 | akamata-reactor-sharded-after | 106809 | 143240 | +34.11 | 55.277 | 19.125 | 385.8 | 389.4 | 134837 | 32471 | 12 | 0 | 0 | 0 |
| echo-64 | 1 | akamata-threaded-after | 27227 | 27152 | -0.27 | 0.051 | 0.049 | 24.0 | 23.8 | 4157 | 4221 | 9 | 0 | 0 | 0 |
| echo-64 | 1 | akamata-reactor-single-after | 27227 | 20738 | -23.83 | 0.051 | 0.072 | 24.0 | 36.8 | 4157 | 4624 | 9 | 0 | 0 | 0 |
| echo-64 | 1 | akamata-reactor-sharded-after | 27227 | 20681 | -24.04 | 0.051 | 0.074 | 24.0 | 36.6 | 4157 | 5279 | 12 | 0 | 0 | 0 |
| echo-64 | 8 | akamata-threaded-after | 90557 | 108372 | +19.67 | 0.157 | 0.123 | 174.7 | 173.9 | 5129 | 5162 | 16 | 0 | 0 | 0 |
| echo-64 | 8 | akamata-reactor-single-after | 90557 | 80999 | -10.55 | 0.157 | 0.196 | 174.7 | 161.7 | 5129 | 4784 | 9 | 0 | 0 | 0 |
| echo-64 | 8 | akamata-reactor-sharded-after | 90557 | 72801 | -19.61 | 0.157 | 0.203 | 174.7 | 239.5 | 5129 | 5692 | 12 | 0 | 0 | 0 |
| echo-64 | 32 | akamata-threaded-after | 136583 | 137240 | +0.48 | 1.117 | 1.272 | 322.0 | 302.8 | 8217 | 8511 | 40 | 0 | 0 | 0 |
| echo-64 | 32 | akamata-reactor-single-after | 136583 | 84699 | -37.99 | 1.117 | 0.672 | 322.0 | 176.4 | 8217 | 5456 | 9 | 0 | 0 | 0 |
| echo-64 | 32 | akamata-reactor-sharded-after | 136583 | 103911 | -23.92 | 1.117 | 0.746 | 322.0 | 286.7 | 8217 | 6315 | 12 | 0 | 0 | 0 |
| echo-64 | 128 | akamata-threaded-after | 158434 | 168861 | +6.58 | 5.623 | 6.568 | 325.8 | 303.0 | 20722 | 20972 | 136 | 0 | 0 | 0 |
| echo-64 | 128 | akamata-reactor-single-after | 158434 | 90517 | -42.87 | 5.623 | 2.616 | 325.8 | 164.8 | 20722 | 7936 | 9 | 0 | 0 | 0 |
| echo-64 | 128 | akamata-reactor-sharded-after | 158434 | 116637 | -26.38 | 5.623 | 3.351 | 325.8 | 342.4 | 20722 | 8814 | 12 | 0 | 0 | 0 |
| echo-64 | 512 | akamata-threaded-after | 156314 | 156584 | +0.17 | 21.277 | 23.380 | 330.8 | 317.0 | 69685 | 70213 | 520 | 0 | 0 | 0 |
| echo-64 | 512 | akamata-reactor-single-after | 156314 | 89550 | -42.71 | 21.277 | 8.678 | 330.8 | 161.1 | 69685 | 17920 | 9 | 0 | 0 | 0 |
| echo-64 | 512 | akamata-reactor-sharded-after | 156314 | 120018 | -23.22 | 21.277 | 15.141 | 330.8 | 352.5 | 69685 | 18876 | 12 | 0 | 0 | 0 |
| echo-64 | 1024 | akamata-threaded-after | 118345 | 136752 | +15.55 | 44.103 | 42.243 | 356.1 | 346.2 | 135939 | 135547 | 1032 | 1093 | 0 | 0 |
| echo-64 | 1024 | akamata-reactor-single-after | 118345 | 89221 | -24.61 | 44.103 | 17.974 | 356.1 | 156.6 | 135939 | 31232 | 9 | 0 | 0 | 0 |
| echo-64 | 1024 | akamata-reactor-sharded-after | 118345 | 138153 | +16.74 | 44.103 | 23.679 | 356.1 | 352.4 | 135939 | 32389 | 12 | 0 | 0 | 0 |
| echo-1024 | 1 | akamata-threaded-after | 27129 | 26849 | -1.03 | 0.052 | 0.053 | 23.9 | 23.9 | 4173 | 4221 | 9 | 0 | 0 | 0 |
| echo-1024 | 1 | akamata-reactor-single-after | 27129 | 20482 | -24.50 | 0.052 | 0.073 | 23.9 | 36.8 | 4173 | 4640 | 9 | 0 | 0 | 0 |
| echo-1024 | 1 | akamata-reactor-sharded-after | 27129 | 20481 | -24.50 | 0.052 | 0.074 | 23.9 | 36.8 | 4173 | 5183 | 12 | 0 | 0 | 0 |
| echo-1024 | 8 | akamata-threaded-after | 93172 | 92186 | -1.06 | 0.142 | 0.153 | 177.5 | 175.8 | 5209 | 5257 | 16 | 0 | 0 | 0 |
| echo-1024 | 8 | akamata-reactor-single-after | 93172 | 79621 | -14.54 | 0.142 | 0.203 | 177.5 | 161.5 | 5209 | 5005 | 9 | 0 | 0 | 0 |
| echo-1024 | 8 | akamata-reactor-sharded-after | 93172 | 68870 | -26.08 | 0.142 | 0.220 | 177.5 | 219.4 | 5209 | 5854 | 12 | 0 | 0 | 0 |
| echo-1024 | 32 | akamata-threaded-after | 120336 | 129342 | +7.48 | 1.468 | 1.057 | 293.4 | 315.8 | 8627 | 8597 | 40 | 0 | 0 | 0 |
| echo-1024 | 32 | akamata-reactor-single-after | 120336 | 77193 | -35.85 | 1.468 | 0.820 | 293.4 | 170.6 | 8627 | 6040 | 9 | 0 | 0 | 0 |
| echo-1024 | 32 | akamata-reactor-sharded-after | 120336 | 95808 | -20.38 | 1.468 | 0.863 | 293.4 | 336.3 | 8627 | 6795 | 12 | 0 | 0 | 0 |
| echo-1024 | 128 | akamata-threaded-after | 160172 | 162146 | +1.23 | 5.806 | 5.551 | 317.7 | 302.6 | 22242 | 22119 | 136 | 0 | 0 | 0 |
| echo-1024 | 128 | akamata-reactor-single-after | 160172 | 87927 | -45.10 | 5.806 | 2.787 | 317.7 | 164.6 | 22242 | 9644 | 9 | 0 | 0 | 0 |
| echo-1024 | 128 | akamata-reactor-sharded-after | 160172 | 110017 | -31.31 | 5.806 | 3.671 | 317.7 | 322.3 | 22242 | 10471 | 12 | 0 | 0 | 0 |
| echo-1024 | 512 | akamata-threaded-after | 136893 | 138953 | +1.50 | 23.363 | 23.288 | 328.2 | 323.7 | 74600 | 75098 | 520 | 0 | 0 | 0 |
| echo-1024 | 512 | akamata-reactor-single-after | 136893 | 82653 | -39.62 | 23.363 | 8.757 | 328.2 | 158.8 | 74600 | 23640 | 9 | 0 | 0 | 0 |
| echo-1024 | 512 | akamata-reactor-sharded-after | 136893 | 119857 | -12.44 | 23.363 | 14.136 | 328.2 | 380.1 | 74600 | 24550 | 12 | 0 | 0 | 0 |
| echo-1024 | 1024 | akamata-threaded-after | 102554 | 125718 | +22.59 | 40.973 | 43.403 | 343.6 | 345.6 | 148513 | 147321 | 1032 | 1162 | 0 | 0 |
| echo-1024 | 1024 | akamata-reactor-single-after | 102554 | 82384 | -19.67 | 40.973 | 18.022 | 343.6 | 154.7 | 148513 | 46667 | 9 | 68 | 0 | 0 |
| echo-1024 | 1024 | akamata-reactor-sharded-after | 102554 | 126795 | +23.64 | 40.973 | 22.627 | 343.6 | 371.6 | 148513 | 42774 | 12 | 0 | 0 | 0 |
| echo-65536 | 1 | akamata-threaded-after | 16550 | 16619 | +0.42 | 0.077 | 0.084 | 33.8 | 33.6 | 4327 | 4407 | 9 | 0 | 0 | 0 |
| echo-65536 | 1 | akamata-reactor-single-after | 16550 | 10873 | -34.30 | 0.077 | 0.135 | 33.8 | 65.5 | 4327 | 4779 | 9 | 0 | 0 | 0 |
| echo-65536 | 1 | akamata-reactor-sharded-after | 16550 | 10905 | -34.11 | 0.077 | 0.135 | 33.8 | 65.4 | 4327 | 5307 | 12 | 0 | 0 | 0 |
| echo-65536 | 8 | akamata-threaded-after | 63191 | 56219 | -11.03 | 0.220 | 0.235 | 214.2 | 210.1 | 6602 | 6666 | 16 | 0 | 0 | 0 |
| echo-65536 | 8 | akamata-reactor-single-after | 63191 | 20428 | -67.67 | 0.220 | 0.718 | 214.2 | 117.8 | 6602 | 6099 | 9 | 0 | 0 | 0 |
| echo-65536 | 8 | akamata-reactor-sharded-after | 63191 | 23342 | -63.06 | 0.220 | 0.899 | 214.2 | 245.5 | 6602 | 6991 | 12 | 0 | 0 | 0 |
| echo-65536 | 32 | akamata-threaded-after | 52852 | 51136 | -3.25 | 1.004 | 1.338 | 251.5 | 243.9 | 14059 | 14327 | 40 | 0 | 0 | 0 |
| echo-65536 | 32 | akamata-reactor-single-after | 52852 | 18973 | -64.10 | 1.004 | 2.992 | 251.5 | 119.8 | 14059 | 10341 | 9 | 0 | 0 | 0 |
| echo-65536 | 32 | akamata-reactor-sharded-after | 52852 | 21432 | -59.45 | 1.004 | 3.458 | 251.5 | 270.5 | 14059 | 11363 | 12 | 0 | 0 | 0 |
| echo-65536 | 128 | akamata-threaded-after | 44550 | 36915 | -17.14 | 6.643 | 6.023 | 266.6 | 225.1 | 44456 | 44442 | 136 | 0 | 0 | 0 |
| echo-65536 | 128 | akamata-reactor-single-after | 44550 | 15124 | -66.05 | 6.643 | 11.939 | 266.6 | 118.4 | 44456 | 27046 | 9 | 0 | 0 | 0 |
| echo-65536 | 128 | akamata-reactor-sharded-after | 44550 | 20174 | -54.72 | 6.643 | 20.660 | 266.6 | 261.8 | 44456 | 28121 | 12 | 0 | 0 | 0 |
| echo-65536 | 512 | akamata-threaded-after | 31259 | 29114 | -6.86 | 26.041 | 25.095 | 241.5 | 200.9 | 164522 | 164776 | 520 | 0 | 0 | 0 |
| echo-65536 | 512 | akamata-reactor-single-after | 31259 | 12913 | -58.69 | 26.041 | 55.004 | 241.5 | 115.1 | 164522 | 94596 | 9 | 0 | 0 | 0 |
| echo-65536 | 512 | akamata-reactor-sharded-after | 31259 | 14017 | -55.16 | 26.041 | 366.327 | 241.5 | 181.9 | 164522 | 94597 | 12 | 0 | 0 | 0 |
| echo-65536 | 1024 | akamata-threaded-after | 22403 | 24861 | +10.97 | 476.836 | 459.215 | 161.6 | 183.0 | 329289 | 329489 | 1057 | 613 | 0 | 0 |
| echo-65536 | 1024 | akamata-reactor-single-after | 22403 | 12712 | -43.26 | 476.836 | 97.717 | 161.6 | 114.1 | 329289 | 182437 | 9 | 1231 | 0 | 0 |
| echo-65536 | 1024 | akamata-reactor-sharded-after | 22403 | 8802 | -60.71 | 476.836 | 1013.514 | 161.6 | 93.7 | 329289 | 177194 | 12 | 1 | 0 | 0 |

Full P50/P95/P99/P99.9 and source/binary digests are in the adjacent JSON.
Failed harness attempts remain in JSON; client errors remain in every metric.
This Mac loopback matrix does not establish Linux or live Cloudflare performance.
Runtime production admission requires separate Contract, stress/fault, TSan and idle-retention evidence.
This reporting tool never changes the production gate.
