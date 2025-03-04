# TestCache

## Description

Test drawing of cached bitmaps and pure draw. In projects used BGRABitmap.

## System Information

- **Operating system:** Alt Linux 11 (x86_64)
- **CPU:** AMD Ryzen 7 7700 (16) @ 5.389GHz
- **GPU:** AMD ATI 0f:00.0 Raphael
- **Compiler version:** FPC 3.3.1 x86_64-linux-gtk2
- **Compiler version:** Lazarus 4.99 (rev main_4_99-1386-gf90db81742) 
- **Device:** Computer

## Results

| Mode             | First draw time    | Min time   | Max time   |
| ---------------- | ------------------ |----------  |----------  |
| Pure draw        | `64 mcs`           | `63 mcs`   | `91 mcs`
| Draw with cache  | `48272 mcs`        | `2654 mcs` | `4431 mcs` |