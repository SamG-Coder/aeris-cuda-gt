// CUDA WebShader 0.1.0. Generated from kernel sampleCar.
@group(0) @binding(0) var<storage, read> b_parts: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read> b_jobs: array<vec4<f32>>;
@group(0) @binding(2) var<storage, read_write> b_samples: array<vec4<f32>>;
struct CWParams {
  p_partCount: u32,
  cw_pad_4: u32,
  cw_pad_8: u32,
  cw_pad_12: u32,
}
@group(0) @binding(3) var<uniform> cw_params: CWParams;
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
fn f_cw_buffer_helper_0(cw_buffer_arg_0: i32, cw_arg_id: i32, cw_arg_u: f32, cw_arg_v: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var cw_buffer_offset_0: i32 = cw_buffer_arg_0;
  var v_id: i32 = cw_arg_id;
  var v_u: f32 = cw_arg_u;
  var v_v: f32 = cw_arg_v;
  var v_o: i32 = (v_id * 10i);
  var v_type: i32 = i32(b_parts[(cw_buffer_offset_0 + v_o)].x);
  let cw_argument_index_1 = (cw_buffer_offset_0 + (v_o + 1i));
  var v_sz: vec3<f32> = f_xyz(b_parts[cw_argument_index_1], cw_thread, cw_block, cw_grid);
  let cw_argument_index_2 = (cw_buffer_offset_0 + (v_o + 2i));
  var v_p: vec3<f32> = f_xyz(b_parts[cw_argument_index_2], cw_thread, cw_block, cw_grid);
  let cw_argument_index_3 = (cw_buffer_offset_0 + (v_o + 3i));
  var v_r: vec3<f32> = f_xyz(b_parts[cw_argument_index_3], cw_thread, cw_block, cw_grid);
  var v_side: f32 = b_parts[(cw_buffer_offset_0 + (v_o + 2i))].w;
  var v_t: f32 = ((2.0f * v_v) - 1.0f);
  var v_q: vec3<f32> = f_V(0.0f, 0.0f, 0.0f, cw_thread, cw_block, cw_grid);
  if ((v_type == 1i)) {
    var v_z: f32 = f_mixf(0.83f, 2.258f, v_u, cw_thread, cw_block, cw_grid);
    var v_w: f32 = f_mixf(0.716f, 0.658f, f_ease(v_u, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    var v_y: f32 = (((f_mixf(0.788f, 0.582f, f_ease(v_u, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid) + (0.032f * (1.0f - (v_t * v_t)))) - ((0.012f * f_bump(v_t, 0.0f, 0.45f, cw_thread, cw_block, cw_grid)) * sin((3.141592653589793f * v_u)))) + ((0.028f * f_bump(abs(v_t), 0.81f, 0.1f, cw_thread, cw_block, cw_grid)) * sin((3.141592653589793f * v_u))));
    v_q = f_V((v_t * v_w), v_y, v_z, cw_thread, cw_block, cw_grid);
  } else {
    if ((v_type == 2i)) {
      v_q = f_V((v_t * 0.729f), (f_mixf(0.742f, 0.812f, f_ease(v_u, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid) + (0.024f * (1.0f - (v_t * v_t)))), f_mixf((-2.235f), (-1.3f), v_u, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
    } else {
      if ((v_type == 3i)) {
        var v_z: f32 = f_mixf((-2.23f), 2.26f, v_u, cw_thread, cw_block, cw_grid);
        var v_inner: f32 = 0.716f;
        var v_center: f32 = 0.765f;
        if ((v_z > 0.83f)) {
          v_inner = f_mixf(0.716f, 0.658f, f_ease(cw_divide_f32((v_z - 0.83f), 1.428f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
          v_center = f_mixf(0.788f, 0.582f, f_ease(cw_divide_f32((v_z - 0.83f), 1.428f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
        }
        if ((v_z < (-1.3f))) {
          v_inner = 0.729f;
          v_center = f_mixf(0.742f, 0.812f, f_ease(cw_divide_f32((v_z + 2.235f), 0.935f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
        }
        var v_y: f32 = ((f_shoulder(v_z, cw_thread, cw_block, cw_grid) + (0.032f * sin((v_v * 3.141592653589793f)))) - (0.012f * v_v));
        v_q = f_V((v_side * f_mixf(v_inner, f_widthAt(v_z, cw_thread, cw_block, cw_grid), v_v, cw_thread, cw_block, cw_grid)), f_mixf(v_center, v_y, f_ease(v_v, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid), v_z, cw_thread, cw_block, cw_grid);
      } else {
        if ((v_type == 4i)) {
          var v_z: f32 = f_mixf((-2.23f), 2.26f, v_u, cw_thread, cw_block, cw_grid);
          var v_b: f32 = 0.215f;
          var v_top: f32 = (f_shoulder(v_z, cw_thread, cw_block, cw_grid) - 0.01f);
          var v_dz: f32 = min(abs((v_z - 1.34f)), abs((v_z + 1.34f)));
          if ((v_dz < 0.395f)) {
            v_b = (0.345f + sqrt(max(0.0f, ((0.395f * 0.395f) - (v_dz * v_dz)))));
          }
          v_b = min(v_b, (v_top - 0.003f));
          var v_x: f32 = (((f_widthAt(v_z, cw_thread, cw_block, cw_grid) - (0.017f * (1.0f - v_v))) + (0.022f * sin((v_v * 3.141592653589793f)))) - ((0.04f * f_bump(v_v, 0.35f, 0.22f, cw_thread, cw_block, cw_grid)) * f_bump(v_z, (-0.3f), 0.7f, cw_thread, cw_block, cw_grid)));
          v_q = f_V((v_side * v_x), f_mixf(v_b, v_top, v_v, cw_thread, cw_block, cw_grid), v_z, cw_thread, cw_block, cw_grid);
        } else {
          if ((v_type == 6i)) {
            var v_a: f32 = ((v_u * 2.0f) - 1.0f);
            v_q = f_V((v_a * f_mixf(0.715f, 0.564f, v_v, cw_thread, cw_block, cw_grid)), (f_mixf(0.802f, 1.194f, v_v, cw_thread, cw_block, cw_grid) + (0.027f * (1.0f - (v_a * v_a)))), (f_mixf(0.846f, 0.171f, v_v, cw_thread, cw_block, cw_grid) + (0.035f * (1.0f - (v_a * v_a)))), cw_thread, cw_block, cw_grid);
          } else {
            if ((v_type == 7i)) {
              v_q = f_V((v_t * (0.573f + (0.014f * sin((v_u * 3.141592653589793f))))), ((1.182f + (0.041f * (1.0f - (v_t * v_t)))) + (0.016f * sin((v_u * 3.141592653589793f)))), f_mixf((-0.66f), 0.18f, v_u, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
            } else {
              if ((v_type == 8i)) {
                var v_a: f32 = ((v_u * 2.0f) - 1.0f);
                v_q = f_V((v_a * f_mixf(0.723f, 0.573f, v_v, cw_thread, cw_block, cw_grid)), (f_mixf(0.813f, 1.174f, v_v, cw_thread, cw_block, cw_grid) + (0.02f * (1.0f - (v_a * v_a)))), (f_mixf((-1.32f), (-0.655f), v_v, cw_thread, cw_block, cw_grid) - (0.025f * (1.0f - (v_a * v_a)))), cw_thread, cw_block, cw_grid);
              } else {
                if ((v_type == 9i)) {
                  v_q = f_V((v_side * (f_mixf(0.723f, 0.573f, v_v, cw_thread, cw_block, cw_grid) + (0.016f * sin((3.141592653589793f * v_v))))), (f_mixf(0.807f, 1.182f, v_v, cw_thread, cw_block, cw_grid) + (0.01f * sin((3.141592653589793f * v_u)))), f_mixf(f_mixf((-1.145f), 0.793f, v_u, cw_thread, cw_block, cw_grid), f_mixf((-0.65f), 0.172f, v_u, cw_thread, cw_block, cw_grid), v_v, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
                } else {
                  if ((v_type == 10i)) {
                    v_q = f_V((v_side * 0.727f), (0.798f + (v_v * 0.014f)), f_mixf((-1.16f), 0.82f, v_u, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
                  } else {
                    if (((v_type == 11i) || (v_type == 12i))) {
                      var v_a: f32 = f_mixf((-0.135f), (3.141592653589793f + 0.135f), v_u, cw_thread, cw_block, cw_grid);
                      var cw_tmp_4: f32;
                      if ((v_type == 11i)) {
                        cw_tmp_4 = (v_v * 0.017f);
                      } else {
                        cw_tmp_4 = 0.0f;
                      }
                      var v_rad: f32 = (0.399f + cw_tmp_4);
                      var cw_tmp_5: f32;
                      if ((v_type == 12i)) {
                        cw_tmp_5 = ((v_v - 0.5f) * v_sz.x);
                      } else {
                        cw_tmp_5 = 0.0f;
                      }
                      return f_add(v_p, f_V(cw_tmp_5, (sin(v_a) * v_rad), (cos(v_a) * v_rad), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
                    } else {
                      if ((v_type == 13i)) {
                        var v_a: f32 = ((v_u * 2.0f) * 3.141592653589793f);
                        var v_x: f32 = (f_spow(cos(v_a), 0.38f, cw_thread, cw_block, cw_grid) * f_mixf(0.59f, 0.886f, v_v, cw_thread, cw_block, cw_grid));
                        var v_y: f32 = (0.409f + (f_spow(sin(v_a), 0.55f, cw_thread, cw_block, cw_grid) * f_mixf(0.105f, 0.208f, v_v, cw_thread, cw_block, cw_grid)));
                        v_q = f_V(v_x, v_y, (((2.264f - (0.065f * (1.0f - v_v))) - ((((0.12f * v_x) * v_x) * v_x) * v_x)) + (0.007f * sin((v_v * 3.141592653589793f)))), cw_thread, cw_block, cw_grid);
                      } else {
                        if ((v_type == 14i)) {
                          var v_x: f32 = (((v_u * 2.0f) - 1.0f) * 0.933f);
                          var v_a: f32 = cw_divide_f32(v_x, 0.933f);
                          v_q = f_V(v_x, f_mixf(0.503f, 0.75f, v_v, cw_thread, cw_block, cw_grid), ((-2.23f) + ((((0.08f * v_a) * v_a) * v_a) * v_a)), cw_thread, cw_block, cw_grid);
                        } else {
                          if ((v_type == 15i)) {
                            v_q = f_V((v_side * (0.899f + (0.042f * v_v))), (0.203f - (0.021f * sin((3.141592653589793f * v_v)))), f_mixf((-0.92f), 0.93f, v_u, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
                          } else {
                            if ((v_type == 16i)) {
                              v_q = f_V((v_side * (0.967f + (0.003f * sin((v_v * 3.141592653589793f))))), f_mixf(0.335f, (0.35f + (0.3f * (1.0f - v_u))), v_v, cw_thread, cw_block, cw_grid), f_mixf((-1.17f), (-0.67f), v_u, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
                            } else {
                              if ((v_type == 17i)) {
                                var v_x: f32 = (((v_u * 2.0f) - 1.0f) * 0.879f);
                                v_q = f_V(v_x, ((0.764f + (0.042f * v_v)) + (0.013f * (1.0f - (v_x * v_x)))), f_mixf((-2.13f), (-2.29f), v_v, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
                              } else {
                                if ((v_type == 18i)) {
                                  v_q = f_V((v_side * f_mixf(0.482f, 0.856f, v_u, cw_thread, cw_block, cw_grid)), (f_mixf(0.612f, 0.662f, v_u, cw_thread, cw_block, cw_grid) + (v_v * 0.022f)), (f_mixf(2.181f, 2.023f, v_u, cw_thread, cw_block, cw_grid) - (v_v * 0.06f)), cw_thread, cw_block, cw_grid);
                                } else {
                                  if (((v_type == 30i) || (v_type == 31i))) {
                                    var v_a: f32 = ((v_u * 2.0f) * 3.141592653589793f);
                                    var v_b: f32 = ((v_v - 0.5f) * 3.141592653589793f);
                                    var v_dir: vec3<f32> = f_V((cos(v_b) * cos(v_a)), sin(v_b), (cos(v_b) * sin(v_a)), cw_thread, cw_block, cw_grid);
                                    if ((v_type == 30i)) {
                                      v_q = f_V((v_dir.x * v_sz.x), (v_dir.y * v_sz.y), (v_dir.z * v_sz.z), cw_thread, cw_block, cw_grid);
                                    } else {
                                      var v_m: f32 = max(abs(v_dir.x), max(abs(v_dir.y), abs(v_dir.z)));
                                      var v_rr: f32 = (min(v_sz.x, min(v_sz.y, v_sz.z)) * 0.62f);
                                      v_q = f_V(((cw_divide_f32(v_dir.x, v_m) * (v_sz.x - v_rr)) + (v_dir.x * v_rr)), ((cw_divide_f32(v_dir.y, v_m) * (v_sz.y - v_rr)) + (v_dir.y * v_rr)), ((cw_divide_f32(v_dir.z, v_m) * (v_sz.z - v_rr)) + (v_dir.z * v_rr)), cw_thread, cw_block, cw_grid);
                                    }
                                  } else {
                                    if ((v_type == 32i)) {
                                      var v_a: f32 = ((v_u * 2.0f) * 3.141592653589793f);
                                      var v_b: f32 = ((v_v * 2.0f) * 3.141592653589793f);
                                      v_q = f_V((v_side * sin(v_b)), ((v_sz.y + (v_side * cos(v_b))) * cos(v_a)), ((v_sz.z + (v_side * cos(v_b))) * sin(v_a)), cw_thread, cw_block, cw_grid);
                                    } else {
                                      if ((v_type == 33i)) {
                                        var v_a: f32 = ((v_u * 2.0f) * 3.141592653589793f);
                                        v_q = f_V((((v_v * 2.0f) - 1.0f) * v_sz.x), (cos(v_a) * v_sz.y), (sin(v_a) * v_sz.z), cw_thread, cw_block, cw_grid);
                                      } else {
                                        if ((v_type == 34i)) {
                                          var v_a: f32 = ((v_u * 2.0f) * 3.141592653589793f);
                                          v_q = f_V(0.0f, ((cos(v_a) * v_v) * v_sz.y), ((sin(v_a) * v_v) * v_sz.z), cw_thread, cw_block, cw_grid);
                                        } else {
                                          if ((v_type == 35i)) {
                                            let cw_argument_index_6 = (cw_buffer_offset_0 + (v_o + 4i));
                                            var v_a: vec3<f32> = f_xyz(b_parts[cw_argument_index_6], cw_thread, cw_block, cw_grid);
                                            let cw_argument_index_7 = (cw_buffer_offset_0 + (v_o + 5i));
                                            var v_b: vec3<f32> = f_xyz(b_parts[cw_argument_index_7], cw_thread, cw_block, cw_grid);
                                            let cw_argument_index_8 = (cw_buffer_offset_0 + (v_o + 6i));
                                            var v_c: vec3<f32> = f_xyz(b_parts[cw_argument_index_8], cw_thread, cw_block, cw_grid);
                                            let cw_argument_index_9 = (cw_buffer_offset_0 + (v_o + 7i));
                                            var v_e: vec3<f32> = f_xyz(b_parts[cw_argument_index_9], cw_thread, cw_block, cw_grid);
                                            var v_centre: vec3<f32> = f_bez(v_a, v_b, v_c, v_e, v_u, cw_thread, cw_block, cw_grid);
                                            var v_tangent: vec3<f32> = f_unit(f_sub(f_bez(v_a, v_b, v_c, v_e, (v_u + 0.001f), cw_thread, cw_block, cw_grid), f_bez(v_a, v_b, v_c, v_e, (v_u - 0.001f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
                                            var cw_tmp_10: vec3<f32>;
                                            if ((abs(v_tangent.y) > 0.9f)) {
                                              cw_tmp_10 = f_V(1.0f, 0.0f, 0.0f, cw_thread, cw_block, cw_grid);
                                            } else {
                                              cw_tmp_10 = f_V(0.0f, 1.0f, 0.0f, cw_thread, cw_block, cw_grid);
                                            }
                                            var v_ref: vec3<f32> = cw_tmp_10;
                                            var v_x: vec3<f32> = f_unit(f_cross3(v_tangent, v_ref, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
                                            var v_y: vec3<f32> = f_cross3(v_tangent, v_x, cw_thread, cw_block, cw_grid);
                                            return f_add(v_centre, f_mul(f_add(f_mul(v_x, cos(((v_v * 2.0f) * 3.141592653589793f)), cw_thread, cw_block, cw_grid), f_mul(v_y, sin(((v_v * 2.0f) * 3.141592653589793f)), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid), v_sz.x, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
                                          } else {
                                            if ((v_type == 37i)) {
                                              var v_a: f32 = ((v_u * 2.0f) - 1.0f);
                                              var v_z: f32 = 0.0f;
                                              var v_y: f32 = 0.0f;
                                              if ((v_v < 0.46f)) {
                                                var v_f: f32 = cw_divide_f32(v_v, 0.46f);
                                                v_z = f_mixf(0.26f, (-0.15f), v_f, cw_thread, cw_block, cw_grid);
                                                v_y = (0.062f + (0.048f * f_bump(v_f, 0.04f, 0.4f, cw_thread, cw_block, cw_grid)));
                                              } else {
                                                var v_f: f32 = cw_divide_f32((v_v - 0.46f), 0.54f);
                                                v_z = f_mixf((-0.15f), (-0.34f), v_f, cw_thread, cw_block, cw_grid);
                                                v_y = f_mixf(0.07f, 0.5f, v_f, cw_thread, cw_block, cw_grid);
                                              }
                                              v_q = f_V((v_a * v_sz.x), (v_y + ((((0.041f * v_a) * v_a) * v_a) * v_a)), v_z, cw_thread, cw_block, cw_grid);
                                            } else {
                                              if ((v_type == 38i)) {
                                                var v_a: f32 = (b_parts[(cw_buffer_offset_0 + (v_o + 4i))].x + (0.19f * sin((3.141592653589793f * v_u))));
                                                var v_width: f32 = b_parts[(cw_buffer_offset_0 + (v_o + 4i))].y;
                                                var v_rad: f32 = f_mixf(0.045f, 0.231f, v_u, cw_thread, cw_block, cw_grid);
                                                var v_lat: f32 = (((v_v * 2.0f) - 1.0f) * f_mixf(0.015f, 0.02f, v_u, cw_thread, cw_block, cw_grid));
                                                v_q = f_V((v_side * ((v_width * 0.42f) - (0.045f * sin((3.141592653589793f * v_u))))), ((cos(v_a) * v_rad) - (sin(v_a) * v_lat)), ((sin(v_a) * v_rad) + (cos(v_a) * v_lat)), cw_thread, cw_block, cw_grid);
                                              } else {
                                                if ((v_type == 39i)) {
                                                  var v_a: f32 = ((v_u * 2.0f) * 3.141592653589793f);
                                                  var v_b: f32 = (v_v * 3.141592653589793f);
                                                  var v_rad: f32 = (0.235f + (0.102f * f_ppow(max(0.0f, sin(v_b)), 0.38f, cw_thread, cw_block, cw_grid)));
                                                  v_q = f_V(((cos(v_b) * v_sz.x) * 0.5f), (cos(v_a) * v_rad), (sin(v_a) * v_rad), cw_thread, cw_block, cw_grid);
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  if ((v_type < 30i)) {
    return v_q;
  }
  return f_add(f_rot(v_q, v_r, cw_thread, cw_block, cw_grid), v_p, cw_thread, cw_block, cw_grid);
}

@compute @workgroup_size(128, 1, 1)
fn main(
  @builtin(local_invocation_id) cw_thread: vec3<u32>,
  @builtin(workgroup_id) cw_block: vec3<u32>,
  @builtin(num_workgroups) cw_grid: vec3<u32>
) {
  var v_id: u32 = cw_block.x;
  if ((v_id >= cw_params.p_partCount)) {
    return;
  }
  var v_j: vec4<f32> = b_jobs[v_id];
  var v_nu: u32 = u32(v_j.y);
  var v_nv: u32 = u32(v_j.z);
  var v_start: u32 = u32(v_j.w);
  {
    var v_k: u32 = cw_thread.x;
    loop {
      if (!(v_k < ((v_nu + 1u) * (v_nv + 1u)))) { break; }
      var v_p: vec3<f32> = f_cw_buffer_helper_0(0i, i32(v_id), cw_divide_f32(f32((v_k % (v_nu + 1u))), f32(v_nu)), cw_divide_f32(f32((v_k / (v_nu + 1u))), f32(v_nv)), cw_thread, cw_block, cw_grid);
      b_samples[(v_start + v_k)] = vec4<f32>(v_p.x, v_p.y, v_p.z, 0.0f);
      continuing {
        v_k = (v_k + cw_block_size.x);
      }
    }
  }
}
