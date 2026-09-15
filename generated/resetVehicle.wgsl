// CUDA WebShader 0.1.0. Generated from kernel resetVehicle.
@group(0) @binding(0) var<storage, read_write> b_state: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read_write> b_smoke: array<vec4<f32>>;
@group(0) @binding(2) var<storage, read_write> b_smokeVelocity: array<vec4<f32>>;
@group(0) @binding(3) var<storage, read_write> b_marks: array<vec4<f32>>;
struct CWParams {
  p_smokeCount: u32,
  p_markCount: u32,
  p_x: f32,
  p_z: f32,
  p_yaw: f32,
  cw_pad_20: u32,
  cw_pad_24: u32,
  cw_pad_28: u32,
}
@group(0) @binding(4) var<uniform> cw_params: CWParams;
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
  if ((v_i < 16u)) {
    b_state[v_i] = vec4<f32>(0.0f, 0.0f, 0.0f, 0.0f);
  }
  if ((v_i == 0u)) {
    b_state[0i] = vec4<f32>(cw_params.p_x, 0.009f, cw_params.p_z, cw_params.p_yaw);
  }
  if ((v_i == 2u)) {
    b_state[2i] = vec4<f32>(950.0f, 1.0f, 0.0f, 0.0f);
  }
  if ((v_i < cw_params.p_smokeCount)) {
    b_smoke[v_i] = vec4<f32>(0.0f, (-20.0f), 0.0f, 0.0f);
    b_smokeVelocity[v_i] = vec4<f32>(0.0f, 0.0f, 0.0f, 0.0f);
  }
  if ((v_i < (cw_params.p_markCount * 2u))) {
    b_marks[v_i] = vec4<f32>(0.0f, (-20.0f), 0.0f, 0.0f);
  }
}
