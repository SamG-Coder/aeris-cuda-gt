# AERIS R — recorded validation

Generated: 2026-09-15T11:09:45.216927+00:00

Native Dawn / SwiftShader software Vulkan, not a physical GPU benchmark

| Stage | Exit code | Observed checks |
|---|---:|---|
| unit | 0 | See stage log |
| compile | 0 | See stage log |
| gpu | 1 | See stage log |
| render | 1 | See stage log |
| ui | 1 | 48 / 52 |
| server | 0 | See stage log |

An exit code other than 0 is a failure or incomplete run, not a pass.

- No physical-GPU FPS measurement
- No complete live browser-WebGPU driving playthrough
- Browser layout/input checks use locally injected HTML and real keyboard events
- Reduced planar vehicle dynamics; no crash deformation, full suspension contact or open-world streaming
- No Forza fidelity or photographically indistinguishable output claim

Native rendering checks exercise the actual shipping car, stage and GPU dynamics.
A changing render is a functional test, not evidence of photographic realism.
No performance number from SwiftShader is advertised as a graphics-card frame rate.
The independent ZIP extraction checks are recorded in `package-check.json`.
