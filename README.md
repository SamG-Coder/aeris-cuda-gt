# AERIS R — CUDA Grand Tour / 1.1

[Launch AERIS](https://samg-coder.github.io/aeris-cuda-gt/) · [Source](https://github.com/SamG-Coder/aeris-cuda-gt) · [CUDA WebShader](https://github.com/SamG-Coder/cuda-webshader)

## Driving polish

A/left and D/right now steer in the driver’s frame of reference across keyboard, touch and gamepad. Fixed outdoor environment selection and restored the GPU diagnostics entry point. Tab hiding displays a clear pause/resume banner.

**Guided coastal tour** drives the circuit through the live GPU vehicle dynamics; WASD takes over immediately. **Record 60s** saves the rendered canvas as WebM at its actual frame timing. Keep the browser foreground during capture. Select **High** before entering the atelier for maximum detail.


An original, drivable sports coupe. The bodywork, glazing, wheels, brakes,
cockpit, lamps and material maps are authored in CUDA source and generated in
the browser by the bundled **SamG-Coder/cuda-webshader** compiler. A GPU vehicle
model drives the car around a closed coastal proving circuit. Three.js r186
handles rendering and the JavaScript application handles input, presentation,
cameras, timing and the static environment.

This is a complete standalone interactive prototype and source project. It is
**not Forza Horizon, a licensed car, a calibrated vehicle simulator or a claim
of photographically indistinguishable graphics**. The car is the focus; the
finite circuit and scenery are deliberately much simpler than a AAA open world.

## Run

Use **Node.js 20 or newer** and a WebGPU-enabled browser.

```sh
npm start
```

Open **http://localhost:8080**. Windows: double-click `START.bat`.
macOS/Linux: `./START.sh`.

**No `npm install` is needed to run the application.** All runtime dependencies,
source and assets are included locally. Do not open the HTML directly. Extract
to a fresh folder and stop other servers using port 8080. Another local port:

```sh
# PowerShell
$env:PORT=8090; npm start
# macOS/Linux
PORT=8090 npm start
```

The server binds to `127.0.0.1` by default. It is a static development server,
not a public production server. `npm run build` creates a self-contained `dist/`
for an HTTPS static host, including subdirectory hosting. A physical phone
cannot access your desktop's localhost; deploy through HTTPS for phone testing.
There is no silent WebGL or CPU geometry/physics fallback.

## First drive

Select Balanced, then **Enter the atelier**. The real CUDA compiler creates the
geometry, textures and vehicle kernels at startup. The first graphics pipeline
compilation can take substantially longer than later frames.

Inspect the car with the mouse, change paint and wheel finish, then click
**Drive the circuit**. You spawn on the start line pointing along the track.
The road curves left beyond the pit buildings. Accelerate with W, steer gently
with A/D, and brake with S. Hold S near a standstill to reverse.

| Control | Action |
|---|---|
| W / up | Throttle; brakes if still travelling backwards |
| S / down | Brake while moving forward; reverse near a standstill |
| A / D or left / right | Steer |
| Space | Rear handbrake |
| C | Chase → bonnet → cockpit camera |
| Q / E | Shift down/up with automatic gearbox disabled |
| R | Reset car at the start line; clear current lap |
| P | Pause/resume driving |
| Escape | Settings (driving pauses while settings are open) |
| G | Return to the atelier |
| M | Mute/unmute synthesized engine audio |
| H | Toggle car lamp emission |
| Mouse drag / right drag / wheel | Orbit / pan / zoom in atelier and photo mode |

Touch steering, brake/reverse, throttle and handbrake buttons appear on coarse
pointer devices. Standard gamepad left stick steers, right trigger accelerates,
left trigger brakes/reverses, A applies handbrake, and Y cycles cameras.
Different controller mappings and physical-phone behavior are not certified.

Keyboard controls use physical key codes, with a letter fallback. Typing in
form fields does not drive the car. Blur/tab hiding clears held controls;
hiding the tab pauses driving. There is no pointer-lock requirement to drive.

## Atelier, setup and photography

Seven paint finishes, three wheel finishes, front/rear/profile/wheel/cockpit
inspection cameras, and an optional orbiting turntable are included. The
cockpit contains modeled seats, bolsters, stitching, a steering wheel,
console, vents and simple emissive instrument surfaces. There is no animated
driver, working door/bonnet mechanism, or licensed dashboard reproduction.

Photo pauses dynamics and enables free orbit around the car at its current
position. Lens/FOV, exposure and rendered PNG capture are available. These
are live rendered views, not prebuilt photographic car cards.

Settings expose daylight/late-afternoon/night lighting, road wetness,
traction/stability assistance, automatic/manual shifting, sound and
clay/normal views. Wetness changes grip and asphalt darkening; it is not
water-film hydrodynamics or planar puddle reflection simulation.

Setup export/import writes a small validated JSON file. It does not save the
current vehicle trajectory or create a replay. Timed laps use four ordered
quarter gates; sustained off-road driving invalidates the lap. Best lap is
kept for the current session, not a server leaderboard. Resetting the current
run retains the session best. There is no multiplayer, AI traffic or damage.

## CUDA versus host work

### `kernels/car.cu`

- `describeCar`: procedural CAD component records: surfaces, dimensions,
  transforms, materials, Bezier tubes, wheel and steering animation tags.
- `sampleCar`: evaluate curved parametric surfaces on the selected grids.
- `buildCar`: assemble actual triangle vertices, smooth finite-difference
  normals and UVs into material-contiguous shared GPU buffers.
- `bakeSurface`: generate colour and normal/roughness pixels for metallic
  paint variation, carbon weave, rubber tread, leather, asphalt and rotor metal.

The host reads the small initialization descriptor table to group parts by
material and allocate exact workloads. It does **not** evaluate car surfaces
or produce the car's vertices on the CPU. Texture pixels are GPU-written and
copied directly to GPU textures; Three.js creates their mip chains.

### `kernels/vehicle.cu`

- `resetVehicle`: initialize vehicle, tyre-smoke and skid-history state.
- `stepVehicle`: fixed-step four-contact planar driving, steering, tyre forces,
  load-transfer approximation, gearing, drag, braking/reverse, obstacle bounds
  and damped chassis attitude. Writes tyre marks to a GPU ring buffer.
- `buildPose`: GPU affine transforms for chassis, four rotating/steering wheels,
  calipers and the steering wheel.
- `updateEffects`: integrate a GPU pool of tyre smoke/dust.

The rendering node graph consumes the generated geometry and pose buffers.
There are no per-frame CPU wheel matrices or regenerated car vertices.

**One car's dynamics run in one compute invocation.** This keeps the source
workflow on the GPU, but is not presented as a speed advantage over a CPU for
one vehicle. The parallel work is the parametric geometry/material generation
and effect pools. No unsupported CUDA host API is being emulated.

JavaScript constructs the lightweight road ribbons, obstacles, landscape,
buildings and lighting rig. The static obstacle circles passed to CUDA match
the visible tyre stacks. There is no CPU fallback driving solver. Lighting
maps and synthesized engine audio are original procedural assets, not
photographic HDR captures or recorded engines.

## Driving model and limitations

A 1490 kg body, 2.68 m wheelbase, 1.704 m track, and 0.337 m rolling radius are
chosen design parameters, not measured specifications of a real vehicle.
The rear-drive torque curve, seven forward ratios, combined tyre-force limit,
load-transfer estimate and steering rate are tuned for interactive control.
Traction control limits excess longitudinal demand; stability assistance adds
yaw damping. Braking is bounded near rest to avoid oscillating between signs.

The chassis pitch/roll/heave are damped visual responses to planar acceleration
and a small road-bump function. There is **no 6-DOF suspension contact solver,
raycast wheel suspension, airborne vehicle motion, deformation or crash
fracture**. Obstacles use circular planar collision. The world boundary is
finite. All drivable ground is approximately flat; distant hills are scenery.

The modeled audio is a filtered harmonic/noise synthesis, not a sampled engine.
Screen instrument surfaces are stylized, not a complete instrument-cluster OS.

## Frame scheduling and readbacks

Dynamics step at 1/120 s, with up to eight substeps per submitted frame. If the
GPU falls behind, the time accumulator is capped; simulation slows rather than
queuing unbounded work. The HUD distinguishes render FPS and simulated-time
speed. The main loop has one application frame in flight.

The chasing camera and HUD use a **256-byte vehicle-state readback per completed
simulation frame**. At 60 frames/s that is 15 KiB/s before protocol overhead.
This introduces synchronization; it is intentional and not called zero-readback.
Actual cumulative runtime readback bytes are shown in the HUD. Startup reads the
CAD count and descriptors. Device diagnostics deliberately perform more reads.
Small input/uniform updates are still uploaded each step.

There is no recurring generated-car mesh or texture pixel download/upload.
This does not mean there are no CPU uploads anywhere: the environment, camera,
lighting, UI and initial resource setup have ordinary renderer/host traffic.

## Workloads

Light/Balanced/High vary CAD surface tessellation, material-bake size, pixel
ratio and shadow resolution. The original body shape is retained. Changing
this preset requires reloading into the title screen. Exact generated counts
are reported on screen and in `docs/render-validation.json`.

Balanced generates approximately 300,000 car triangles in 17 nonempty
material groups; the exact validated counts are recorded rather than used as
an FPS promise. Geometry buffers contain three float4 records per vertex.
The smoke pool has 2,048 slots; the skid pool has 8,192 quads. These slots are
not all necessarily active. Shadow passes and scenery add rendering work.

The lighting/material implementation requires `float32-filterable` WebGPU
support. Individual storage-buffer limits are checked when the car allocates.
Free VRAM and driver watchdog budgets cannot be predicted. Device loss stops
the application with a reload path; it does not silently lower quality.

## Testing

Dependency-free tests and static build:

```sh
npm test
npm run compile
npm run test:server
npm run build
```

Actual compute/render tests use optional Dawn node-webgpu:

```sh
# Or set AERIS_DAWN_PATH to an installed matching dawn.node addon.
npm run test:gpu
npm run test:render
```

The Linux reference run uses `VK_ICD_FILENAMES` pointing to the SwiftShader
Vulkan ICD. No native binary is shipped. The render test writes raw captures
under docs/raw; use scripts/convert-captures.py (Pillow + NumPy) to convert them.

Browser DOM/input tests require Python Playwright and Chromium, with a local
server running. `AERIS_TEST_URL` changes its origin; `CHROMIUM_PATH` changes the
browser executable.

```sh
PORT=8086 npm start
AERIS_TEST_URL=http://localhost:8086 npm run test:ui
```

The included device checks run small isolated CUDA workloads in the live
application and export JSON. They check acceleration, braking, reverse, pose
matrices and finite values, not hardware frame-rate targets. They do not
modify the active vehicle state.

See `docs/VALIDATION.md` for the exact results and test environment. In
particular, native software-WebGPU renders and Chromium keyboard tests are
not falsely presented as a completed physical-GPU browser playthrough.

## Layout

```text
kernels/car.cu          Geometry and GPU material recipes
kernels/vehicle.cu      Dynamics, wheel/chassis transforms and effects
src/car.js             Shared GPU geometry / material render bridge
src/simulation.js      Fixed-step kernel scheduling and buffer ownership
src/stage.js           Atelier, track, scenery, lights and GPU effects
src/app.js              Lifecycle, cameras, settings, HUD and capture
src/input.js           Keyboard / gamepad / touch controls
src/diagnostics.js     Isolated device checks
src/audio.js           Synthesized engine audio
vendor/                Pinned, unmodified Three.js and CUDA WebShader
```

The original authored source is MIT. Vendor copyright/license notices remain
in the package. No game assets, car manufacturer models, external font files,
native executables, credentials or telemetry endpoints are included.

## Rendering implementation notes

Car materials use a compact explicit GGX/Schlick shader with an original
equirectangular lighting map and a clearcoat approximation, rather than the
very large stock multi-light CubeUV shader. The same shader runs in shipping
browsers and native reference tests. This is not a hidden test-only substitute.
Metallic paint, clearcoat, carbon, rubber, leather and emissive light elements
have different responses. Glazing uses alpha blending and reflection, not
physical refraction or a ray-traced multi-layer glass model.

Colour and roughness are sampled from the CUDA-baked maps. The RGB normal
channels are provided in those bakes for inspection and extension; the default
look uses the smooth geometric normals calculated from CUDA surface samples.
Shadows are cast onto the circuit/atelier ground. The custom car shader does
not include the full stock Three.js shadow-receiver lighting graph. Scenery
uses simpler diffuse materials; road wetness darkens its surface and changes
tyre grip. This is an intentional car-focused, portable rendering compromise,
not a claim of AAA reflection, weather or photorealism parity.

## Renderer and solver details

Balanced and High use Three.js MeshPhysicalNodeMaterial with environment-filtered
reflections and clearcoat. Light uses a compact explicit GGX/environment shader.
All quality levels receive the same CUDA-produced geometry and vehicle state;
quality changes geometry tessellation, shadow resolution and pixel ratio.

Normals are generated in CUDA and interpolated as vertex varyings. CUDA textures
provide colour and roughness, with additional tyre/rotor patterns in the material.
The baked normal-map RGB channels are retained for further development but are
not used for tangent-space perturbation by the current renderer. Glass is layered
alpha-blended reflective glazing, not an accurate multiple-refraction solve.
The environment is an original generated lighting map, not a scanned HDRI or a
real-time ray-traced reflection of the circuit. Static scenery is intentionally
simpler than the car. No claim of Forza visual or simulation parity is made.

`stepVehicle` prepares controls, gear changes, engine demand and road grip.
`tireForces` evaluates four independent combined-grip tyre contacts.
`integrateVehicle` sums their forces and moments, handles planar obstacle
contacts and updates damped cosmetic body movement. `buildPose` creates the
shared animation matrices; `updateEffects` advects wheel smoke. There is no
CPU replacement for these dynamics. This is a reduced planar driving model,
not six-degree-of-freedom suspension or a calibrated real-car model.

The CPU reads 256 bytes of vehicle state per completed simulation frame for the
cameras, HUD and audio. The car geometry and animation matrices stay GPU-resident.
This is explicitly not a zero-readback application.

Tests requiring native GPU execution use the optional `webgpu` Node addon, or
`AERIS_DAWN_PATH` pointing at a matching Dawn addon. They are not dependencies
needed to run the browser app. In the build environment, Chromium HTTP navigation
was policy-blocked. The browser tests therefore inject the actual local HTML/CSS
and input module into Chromium and exercise real keyboard events. They test
layout and input handling, not a complete browser-WebGPU driving session.
See `docs/VALIDATION.md` and `docs/validation.json` for the actual run results.

## Frame pacing

The driving renderer queues graphics without a second whole-GPU completion wait. Vehicle telemetry uses one reusable 256-byte staging buffer, with mapping as the synchronization point. HUD updates run at 10 Hz while lap timing and physics still advance each simulation frame. The FPS display includes the rolling 95th-percentile frame interval (p95); around 16.7 ms corresponds to 60 Hz pacing. High geometry, texture detail and shadow resolution remain unchanged.

### High-speed steering

Normal steering lock follows available road grip and speed, preventing a held digital steering key from demanding an impossible cornering force. It does not apply brakes or reduce throttle. Stability assistance corrects sideslip toward the direction of travel and follows a grip-limited yaw target. The handbrake retains the wider steering range for deliberate slides. Guided-tour speed behavior is unchanged.
