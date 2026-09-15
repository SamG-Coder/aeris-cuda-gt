// CUDA WebShader 0.1.0. Generated from kernel updateEffects.
@group(0) @binding(0) var<storage, read> b_state: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read_write> b_smoke: array<vec4<f32>>;
@group(0) @binding(2) var<storage, read_write> b_smokeVelocity: array<vec4<f32>>;
struct CWParams {
  p_count: u32,
  p_dt: f32,
  cw_pad_8: u32,
  cw_pad_12: u32,
}
@group(0) @binding(3) var<uniform> cw_params: CWParams;
const cw_block_size: vec3<u32> = vec3<u32>(128u, 1u, 1u);

fn cw_divide_f32(a: f32, b: f32) -> f32 { let q = a / b; if ((bitcast<u32>(q) & 0x7f800000u) == 0x7f800000u || (bitcast<u32>(q) & 0x7fffffffu) == 0u || (bitcast<u32>(b) & 0x7f800000u) == 0x7f800000u) { return q; } let residual = fma(-q, b, a); return q + residual / b; }
fn f_cf(cw_arg_x: f32, cw_arg_lo: f32, cw_arg_hi: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var v_lo: f32 = cw_arg_lo;
  var v_hi: f32 = cw_arg_hi;
  return min(max(v_x, v_lo), v_hi);
}
fn f_sg(cw_arg_x: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_x: f32 = cw_arg_x;
  var cw_tmp_0: f32;
  if ((v_x < 0.0f)) {
    cw_tmp_0 = (-1.0f);
  } else {
    cw_tmp_0 = 1.0f;
  }
  return cw_tmp_0;
}
fn f_approach(cw_arg_a: f32, cw_arg_b: f32, cw_arg_speed: f32, cw_arg_dt: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_a: f32 = cw_arg_a;
  var v_b: f32 = cw_arg_b;
  var v_speed: f32 = cw_arg_speed;
  var v_dt: f32 = cw_arg_dt;
  return (v_a + f_cf((v_b - v_a), ((-v_speed) * v_dt), (v_speed * v_dt), cw_thread, cw_block, cw_grid));
}
fn f_ratio(cw_arg_g: i32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_g: i32 = cw_arg_g;
  if ((v_g < 0i)) {
    return (-2.9f);
  }
  if ((v_g == 1i)) {
    return 3.1f;
  }
  if ((v_g == 2i)) {
    return 2.15f;
  }
  if ((v_g == 3i)) {
    return 1.65f;
  }
  if ((v_g == 4i)) {
    return 1.31f;
  }
  if ((v_g == 5i)) {
    return 1.05f;
  }
  if ((v_g == 6i)) {
    return 0.85f;
  }
  return 0.69f;
}
fn f_rotX(cw_arg_p: vec3<f32>, cw_arg_a: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_p: vec3<f32> = cw_arg_p;
  var v_a: f32 = cw_arg_a;
  var v_c: f32 = cos(v_a);
  var v_s: f32 = sin(v_a);
  return vec3<f32>(v_p.x, ((v_c * v_p.y) - (v_s * v_p.z)), ((v_s * v_p.y) + (v_c * v_p.z)));
}
fn f_rotY(cw_arg_p: vec3<f32>, cw_arg_a: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_p: vec3<f32> = cw_arg_p;
  var v_a: f32 = cw_arg_a;
  var v_c: f32 = cos(v_a);
  var v_s: f32 = sin(v_a);
  return vec3<f32>(((v_c * v_p.x) + (v_s * v_p.z)), v_p.y, (((-v_s) * v_p.x) + (v_c * v_p.z)));
}
fn f_rotZ(cw_arg_p: vec3<f32>, cw_arg_a: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var v_p: vec3<f32> = cw_arg_p;
  var v_a: f32 = cw_arg_a;
  var v_c: f32 = cos(v_a);
  var v_s: f32 = sin(v_a);
  return vec3<f32>(((v_c * v_p.x) - (v_s * v_p.y)), ((v_s * v_p.x) + (v_c * v_p.y)), v_p.z);
}
fn f_hashFx(cw_arg_x: u32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> u32 {
  var v_x: u32 = cw_arg_x;
  v_x = (v_x ^ (v_x >> 16u));
  v_x = (v_x * 2146121005u);
  v_x = (v_x ^ (v_x >> 15u));
  v_x = (v_x * 2221713035u);
  v_x = (v_x ^ (v_x >> 16u));
  return v_x;
}
fn f_rf(cw_arg_i: u32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var v_i: u32 = cw_arg_i;
  return cw_divide_f32(f32((f_hashFx(v_i, cw_thread, cw_block, cw_grid) & 16777215u)), 16777216.0f);
}

@compute @workgroup_size(128, 1, 1)
fn main(
  @builtin(local_invocation_id) cw_thread: vec3<u32>,
  @builtin(workgroup_id) cw_block: vec3<u32>,
  @builtin(num_workgroups) cw_grid: vec3<u32>
) {
  var v_i: u32 = ((cw_block.x * cw_block_size.x) + cw_thread.x);
  if ((v_i >= cw_params.p_count)) {
    return;
  }
  var v_p: vec4<f32> = b_smoke[v_i];
  var v_v: vec4<f32> = b_smokeVelocity[v_i];
  var v_pose: vec4<f32> = b_state[0i];
  var v_stats: vec4<f32> = b_state[10i];
  var v_traction: vec4<f32> = b_state[11i];
  v_p.w = max(0.0f, (v_p.w - (cw_params.p_dt * 0.55f)));
  if ((v_p.w <= 0.0f)) {
    var v_tick: u32 = u32((b_state[3i].w * 120.0f));
    if ((((((v_i + v_tick) % 31u) == 0u) && (v_stats.z > 3.0f)) && ((v_traction.w > 0.35f) || (v_stats.w > 0.5f)))) {
      var cw_tmp_1: f32;
      if (((v_i % 2u) == 0u)) {
        cw_tmp_1 = (-1.0f);
      } else {
        cw_tmp_1 = 1.0f;
      }
      var v_side: f32 = cw_tmp_1;
      var v_sy: f32 = sin(v_pose.w);
      var v_cy: f32 = cos(v_pose.w);
      v_p = vec4<f32>(((v_pose.x + ((v_cy * v_side) * 0.852f)) - (v_sy * 1.34f)), 0.22f, ((v_pose.z - ((v_sy * v_side) * 0.852f)) - (v_cy * 1.34f)), (0.6f + (f_rf((v_i + v_tick), cw_thread, cw_block, cw_grid) * 0.35f)));
      v_v = vec4<f32>(((f_rf(((v_i + v_tick) + 1u), cw_thread, cw_block, cw_grid) - 0.5f) * 0.5f), (0.2f + (f_rf(((v_i + v_tick) + 2u), cw_thread, cw_block, cw_grid) * 0.4f)), ((f_rf(((v_i + v_tick) + 3u), cw_thread, cw_block, cw_grid) - 0.5f) * 0.5f), v_stats.w);
    }
  } else {
    v_p.x = (v_p.x + (v_v.x * cw_params.p_dt));
    v_p.y = (v_p.y + (v_v.y * cw_params.p_dt));
    v_p.z = (v_p.z + (v_v.z * cw_params.p_dt));
    v_v.y = (v_v.y + (0.1f * cw_params.p_dt));
  }
  b_smoke[v_i] = v_p;
  b_smokeVelocity[v_i] = v_v;
}
