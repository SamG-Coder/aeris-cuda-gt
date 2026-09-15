# Third-party notices — AERIS R

Original AERIS vehicle design, game code, physics, scenery and generated texture
recipes in this package are provided under the MIT license in LICENSE.

## CUDA WebShader
SamG-Coder/cuda-webshader, MIT. Compiler, runtime and original Three.js bridge
are bundled without modification from commit
`c272bb782f8458761af2894e8771517f64ecdae6`.
Upstream: https://github.com/SamG-Coder/cuda-webshader
License: vendor/cuda-webshader/LICENSE.

## Three.js
Three.js r186 (0.186.0), MIT. Includes the WebGPU renderer, TSL and OrbitControls.
Upstream: https://github.com/mrdoob/three.js
License: vendor/three/LICENSE.

## Original assets and naming
The AERIS R is an original procedural concept coupe. No car manufacturer's
badge, model, texture, sound recording or game asset is included. No Forza
Horizon assets, code or soundtrack are used. AERIS is a fictional project name,
not an assertion of trademark clearance. Lighting maps, material maps, scenery
and engine audio are generated from the included code. The title image is an
actual software-WebGPU capture of this renderer, not a separate generated image.

## Optional test software
Native validation uses Dawn node-webgpu plus SwiftShader. The optional native
addon and browser binaries are not shipped. Browser input tests use Playwright.
These are not runtime dependencies of the downloadable project.
