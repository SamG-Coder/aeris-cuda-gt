// CUDA WebShader 0.1.0. Generated from kernel bakeSurface.
@group(0) @binding(0) var<storage, read_write> b_colorMap: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read_write> b_normalRough: array<vec4<f32>>;
struct CWParams {
  p_width: u32,
  p_kind: u32,
  cw_pad_8: u32,
  cw_pad_12: u32,
}
@group(0) @binding(2) var<uniform> cw_params: CWParams;
const cw_block_size: vec3<u32> = vec3<u32>(128u, 1u, 1u);

fn cw_divide_f32(a: f32, b: f32) -> f32 { let q = a / b; if ((bitcast<u32>(q) & 0x7f800000u) == 0x7f800000u || (bitcast<u32>(q) & 0x7fffffffu) == 0u || (bitcast<u32>(b) & 0x7f800000u) == 0x7f800000u) { return q; } let residual = fma(-q, b, a); return q + residual / b; }
fn f_clampf(cw_arg_x: f32, cw_arg_lo: f32, cw_arg_hi: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_lo: f32 = cw_arg_lo;
  var v_hi: f32 = cw_arg_hi;
  return min(max(v_x, v_lo), v_hi);
}
fn f_mixf(cw_arg_a: f32, cw_arg_b: f32, cw_arg_t: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_a: f32 = cw_arg_a;
  var v_b: f32 = cw_arg_b;
  var v_t: f32 = cw_arg_t;
  return (v_a + ((v_b - v_a) * v_t));
}
fn f_ease(cw_arg_t: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_t: f32 = cw_arg_t;
  v_t = f_clampf(v_t, 0.0f, 1.0f, cw_thread, cw_block, cw_grid);
  return ((v_t * v_t) * (3.0f - (2.0f * v_t)));
}
fn f_bump(cw_arg_x: f32, cw_arg_c: f32, cw_arg_w: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_c: f32 = cw_arg_c;
  var v_w: f32 = cw_arg_w;
  var v_d: f32 = cw_divide_f32((v_x - v_c), v_w);
  return exp(((-v_d) * v_d));
}
fn f_ppow(cw_arg_x: f32, cw_arg_e: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_e: f32 = cw_arg_e;
  return exp((log(max(v_x, 1e-9f)) * v_e));
}
fn f_spow(cw_arg_x: f32, cw_arg_e: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_e: f32 = cw_arg_e;
  var cw_tmp_0: f32;
  if ((v_x < 0.0f)) {
    cw_tmp_0 = (-1.0f);
  } else {
    cw_tmp_0 = 1.0f;
  }
  return (cw_tmp_0 * f_ppow(abs(v_x), v_e, cw_thread, cw_block, cw_grid));
}
fn f_V(cw_arg_x: f32, cw_arg_y: f32, cw_arg_z: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_x: f32 = cw_arg_x;
  var v_y: f32 = cw_arg_y;
  var v_z: f32 = cw_arg_z;
  return vec3<f32>(v_x, v_y, v_z);
}
fn f_xyz(cw_arg_p: vec4<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_p: vec4<f32> = cw_arg_p;
  return f_V(v_p.x, v_p.y, v_p.z, cw_thread, cw_block, cw_grid);
}
fn f_add(cw_arg_a: vec3<f32>, cw_arg_b: vec3<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_a: vec3<f32> = cw_arg_a;
  var v_b: vec3<f32> = cw_arg_b;
  return f_V((v_a.x + v_b.x), (v_a.y + v_b.y), (v_a.z + v_b.z), cw_thread, cw_block, cw_grid);
}
fn f_sub(cw_arg_a: vec3<f32>, cw_arg_b: vec3<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_a: vec3<f32> = cw_arg_a;
  var v_b: vec3<f32> = cw_arg_b;
  return f_V((v_a.x - v_b.x), (v_a.y - v_b.y), (v_a.z - v_b.z), cw_thread, cw_block, cw_grid);
}
fn f_mul(cw_arg_a: vec3<f32>, cw_arg_s: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_a: vec3<f32> = cw_arg_a;
  var v_s: f32 = cw_arg_s;
  return f_V((v_a.x * v_s), (v_a.y * v_s), (v_a.z * v_s), cw_thread, cw_block, cw_grid);
}
fn f_cross3(cw_arg_a: vec3<f32>, cw_arg_b: vec3<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_a: vec3<f32> = cw_arg_a;
  var v_b: vec3<f32> = cw_arg_b;
  return f_V(((v_a.y * v_b.z) - (v_a.z * v_b.y)), ((v_a.z * v_b.x) - (v_a.x * v_b.z)), ((v_a.x * v_b.y) - (v_a.y * v_b.x)), cw_thread, cw_block, cw_grid);
}
fn f_unit(cw_arg_a: vec3<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_a: vec3<f32> = cw_arg_a;
  return f_mul(v_a, inverseSqrt(max((((v_a.x * v_a.x) + (v_a.y * v_a.y)) + (v_a.z * v_a.z)), 1e-9f)), cw_thread, cw_block, cw_grid);
}
fn f_mix3(cw_arg_a: vec3<f32>, cw_arg_b: vec3<f32>, cw_arg_t: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_a: vec3<f32> = cw_arg_a;
  var v_b: vec3<f32> = cw_arg_b;
  var v_t: f32 = cw_arg_t;
  return f_add(v_a, f_mul(f_sub(v_b, v_a, cw_thread, cw_block, cw_grid), v_t, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
}
fn f_rot(cw_arg_p: vec3<f32>, cw_arg_r: vec3<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_p: vec3<f32> = cw_arg_p;
  var v_r: vec3<f32> = cw_arg_r;
  var v_c: f32 = cos(v_r.x);
  var v_s: f32 = sin(v_r.x);
  v_p = f_V(v_p.x, ((v_c * v_p.y) - (v_s * v_p.z)), ((v_s * v_p.y) + (v_c * v_p.z)), cw_thread, cw_block, cw_grid);
  v_c = cos(v_r.y);
  v_s = sin(v_r.y);
  v_p = f_V(((v_c * v_p.x) + (v_s * v_p.z)), v_p.y, (((-v_s) * v_p.x) + (v_c * v_p.z)), cw_thread, cw_block, cw_grid);
  v_c = cos(v_r.z);
  v_s = sin(v_r.z);
  return f_V(((v_c * v_p.x) - (v_s * v_p.y)), ((v_s * v_p.x) + (v_c * v_p.y)), v_p.z, cw_thread, cw_block, cw_grid);
}
fn f_bez(cw_arg_a: vec3<f32>, cw_arg_b: vec3<f32>, cw_arg_c: vec3<f32>, cw_arg_d: vec3<f32>, cw_arg_t: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_a: vec3<f32> = cw_arg_a;
  var v_b: vec3<f32> = cw_arg_b;
  var v_c: vec3<f32> = cw_arg_c;
  var v_d: vec3<f32> = cw_arg_d;
  var v_t: f32 = cw_arg_t;
  var v_s: f32 = (1.0f - v_t);
  return f_add(f_add(f_mul(v_a, ((v_s * v_s) * v_s), cw_thread, cw_block, cw_grid), f_mul(v_b, (((3.0f * v_s) * v_s) * v_t), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid), f_add(f_mul(v_c, (((3.0f * v_s) * v_t) * v_t), cw_thread, cw_block, cw_grid), f_mul(v_d, ((v_t * v_t) * v_t), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
}
fn f_widthAt(cw_arg_z: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_z: f32 = cw_arg_z;
  return (((((0.91f + (0.057f * f_bump(v_z, (-1.35f), 0.6f, cw_thread, cw_block, cw_grid))) + (0.049f * f_bump(v_z, 1.31f, 0.54f, cw_thread, cw_block, cw_grid))) - (0.12f * f_bump(v_z, 2.45f, 0.42f, cw_thread, cw_block, cw_grid))) - (0.053f * f_bump(v_z, (-2.4f), 0.43f, cw_thread, cw_block, cw_grid))) - (0.018f * f_bump(v_z, 0.0f, 0.7f, cw_thread, cw_block, cw_grid)));
}
fn f_shoulder(cw_arg_z: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_z: f32 = cw_arg_z;
  return ((((0.732f + (0.092f * f_bump(v_z, 1.34f, 0.55f, cw_thread, cw_block, cw_grid))) + (0.12f * f_bump(v_z, (-1.34f), 0.58f, cw_thread, cw_block, cw_grid))) - (0.14f * f_bump(v_z, 2.45f, 0.46f, cw_thread, cw_block, cw_grid))) - (0.047f * f_bump(v_z, (-2.45f), 0.49f, cw_thread, cw_block, cw_grid)));
}
fn f_hash32(cw_arg_x: u32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> u32 {
  var v_x: u32 = cw_arg_x;
  v_x = (v_x ^ (v_x >> 16u));
  v_x = (v_x * 2146121005u);
  v_x = (v_x ^ (v_x >> 15u));
  v_x = (v_x * 2221713035u);
  v_x = (v_x ^ (v_x >> 16u));
  return v_x;
}
fn f_rnd(cw_arg_n: u32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_n: u32 = cw_arg_n;
  return cw_divide_f32(f32((f_hash32(v_n, cw_thread, cw_block, cw_grid) & 16777215u)), 16777216.0f);
}

@compute @workgroup_size(128, 1, 1)
fn main(
  @builtin(local_invocation_id) cw_thread: vec3<u32>,
  @builtin(workgroup_id) cw_block: vec3<u32>,
  @builtin(num_workgroups) cw_grid: vec3<u32>
) {
  var v_i: u32 = ((cw_block.x * cw_block_size.x) + cw_thread.x);
  if ((v_i >= (cw_params.p_width * cw_params.p_width))) {
    return;
  }
  var v_u: f32 = cw_divide_f32((f32((v_i % cw_params.p_width)) + 0.5f), f32(cw_params.p_width));
  var v_v: f32 = cw_divide_f32((f32((v_i / cw_params.p_width)) + 0.5f), f32(cw_params.p_width));
  var v_n: f32 = f_rnd((v_i + (cw_params.p_kind * 3271u)), cw_thread, cw_block, cw_grid);
  var v_shade: f32 = 0.1f;
  var v_rough: f32 = 0.6f;
  var v_dx: f32 = 0.0f;
  var v_dy: f32 = 0.0f;
  if ((cw_params.p_kind == 0u)) {
    var v_a: f32 = (floor((v_u * 16.0f)) + floor((v_v * 16.0f)));
    var v_stripe: f32 = (v_a - (2.0f * floor((v_a * 0.5f))));
    var cw_tmp_1: f32;
    if ((v_stripe < 1.0f)) {
      cw_tmp_1 = sin(((v_u * 16.0f) * 3.141592653589793f));
    } else {
      cw_tmp_1 = sin(((v_v * 16.0f) * 3.141592653589793f));
    }
    var v_s: f32 = cw_tmp_1;
    v_shade = ((0.017f + (0.034f * abs(v_s))) + (0.004f * v_n));
    v_rough = 0.31f;
    v_dx = (0.13f * cos(((v_u * 128.0f) * 3.141592653589793f)));
    v_dy = (0.13f * cos(((v_v * 128.0f) * 3.141592653589793f)));
  }
  if ((cw_params.p_kind == 1u)) {
    v_shade = (0.018f + (0.012f * v_n));
    if (((abs(sin(((v_v * 8.0f) * 3.141592653589793f))) < 0.1f) || (abs(sin((((v_u * 72.0f) * 3.141592653589793f) + (v_v * 15.0f)))) < 0.08f))) {
      v_shade = (v_shade * 0.25f);
    }
    v_rough = 0.82f;
    v_dx = (0.1f * cos(((v_u * 144.0f) * 3.141592653589793f)));
    v_dy = (0.15f * cos(((v_v * 16.0f) * 3.141592653589793f)));
  }
  if ((cw_params.p_kind == 2u)) {
    v_shade = (0.04f + (0.01f * v_n));
    v_rough = 0.62f;
    v_dx = ((v_n - 0.5f) * 0.25f);
    v_dy = ((f_rnd((v_i + 79u), cw_thread, cw_block, cw_grid) - 0.5f) * 0.25f);
  }
  if ((cw_params.p_kind == 3u)) {
    v_shade = (0.085f + (0.07f * v_n));
    v_rough = 0.93f;
    v_dx = ((v_n - 0.5f) * 0.45f);
    v_dy = ((f_rnd((v_i + 711u), cw_thread, cw_block, cw_grid) - 0.5f) * 0.45f);
  }
  if ((cw_params.p_kind == 4u)) {
    var v_x: f32 = ((v_u * 2.0f) - 1.0f);
    var v_y: f32 = ((v_v * 2.0f) - 1.0f);
    var v_rr: f32 = sqrt(((v_x * v_x) + (v_y * v_y)));
    v_shade = ((0.21f + (0.1f * v_n)) + (0.035f * sin((v_rr * 600.0f))));
    v_rough = 0.36f;
    v_dx = (0.045f * sin((v_rr * 550.0f)));
    v_dy = v_dx;
  }
  if ((cw_params.p_kind == 5u)) {
    v_shade = (0.78f + (0.22f * v_n));
    v_rough = (0.21f + (0.05f * v_n));
    v_dx = ((v_n - 0.5f) * 0.024f);
    v_dy = ((f_rnd((v_i + 177u), cw_thread, cw_block, cw_grid) - 0.5f) * 0.024f);
  }
  var v_nn: vec3<f32> = f_unit(f_V(v_dx, v_dy, 1.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  b_colorMap[v_i] = vec4<f32>(v_shade, v_shade, v_shade, 1.0f);
  b_normalRough[v_i] = vec4<f32>(((v_nn.x * 0.5f) + 0.5f), ((v_nn.y * 0.5f) + 0.5f), ((v_nn.z * 0.5f) + 0.5f), v_rough);
}
