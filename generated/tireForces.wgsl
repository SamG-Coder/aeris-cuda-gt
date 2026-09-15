// CUDA WebShader 0.1.0. Generated from kernel tireForces.
@group(0) @binding(0) var<storage, read_write> b_state: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read_write> b_forces: array<vec4<f32>>;
struct CWParams {
  p_dt: f32,
  p_tractionControl: u32,
  cw_pad_8: u32,
  cw_pad_12: u32,
}
@group(0) @binding(2) var<uniform> cw_params: CWParams;
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
  var v_w: u32 = (cw_thread.x + (cw_block.x * cw_block_size.x));
  if ((v_w >= 4u)) {
    return;
  }
  var v_ctrl: vec4<f32> = b_state[5i];
  var v_par: vec4<f32> = b_state[12i];
  var v_motion: vec4<f32> = b_state[13i];
  var v_old: vec4<f32> = b_state[10i];
  var cw_tmp_1: f32;
  if (((v_w % 2u) == 0u)) {
    cw_tmp_1 = (-0.852f);
  } else {
    cw_tmp_1 = 0.852f;
  }
  var v_wx: f32 = cw_tmp_1;
  var cw_tmp_2: f32;
  if ((v_w < 2u)) {
    cw_tmp_2 = 1.34f;
  } else {
    cw_tmp_2 = (-1.34f);
  }
  var v_wz: f32 = cw_tmp_2;
  var cw_tmp_3: f32;
  if ((v_w < 2u)) {
    cw_tmp_3 = v_ctrl.x;
  } else {
    cw_tmp_3 = 0.0f;
  }
  var v_delta: f32 = cw_tmp_3;
  var v_sn: f32 = sin(v_delta);
  var v_cs: f32 = cos(v_delta);
  var v_lat: f32 = (v_motion.x + (v_motion.w * v_wz));
  var v_lon: f32 = (v_motion.y - (v_motion.w * v_wx));
  var v_tl: f32 = ((v_lat * v_cs) - (v_lon * v_sn));
  var v_tv: f32 = ((v_lat * v_sn) + (v_lon * v_cs));
  var cw_tmp_4: f32;
  if ((v_w < 2u)) {
    cw_tmp_4 = 1.0f;
  } else {
    cw_tmp_4 = (-1.0f);
  }
  var cw_tmp_5: f32;
  if ((v_wx < 0.0f)) {
    cw_tmp_5 = (-1.0f);
  } else {
    cw_tmp_5 = 1.0f;
  }
  var v_load: f32 = ((((1490.0f * 9.81f) * 0.25f) - cw_divide_f32((((cw_tmp_4 * 1490.0f) * v_old.y) * 0.42f), 5.36f)) - cw_divide_f32((((cw_tmp_5 * 1490.0f) * v_old.x) * 0.42f), 3.408f));
  v_load = (f_cf(v_load, ((1490.0f * 9.81f) * 0.09f), ((1490.0f * 9.81f) * 0.46f), cw_thread, cw_block, cw_grid) + ((0.28f * v_motion.z) * v_motion.z));
  var v_grip: f32 = (v_par.y * v_load);
  var v_alpha: f32 = atan2(v_tl, max(abs(v_tv), 3.5f));
  var cw_tmp_6: f32;
  if ((v_w < 2u)) {
    cw_tmp_6 = 1.0f;
  } else {
    cw_tmp_6 = 1.12f;
  }
  var cw_tmp_7: f32;
  if ((v_w < 2u)) {
    cw_tmp_7 = 1.0f;
  } else {
    cw_tmp_7 = (1.0f - (v_ctrl.w * 0.78f));
  }
  var v_lateral: f32 = ((((-40000.0f) * v_alpha) * cw_tmp_6) * cw_tmp_7);
  var cw_tmp_8: f32;
  if ((v_w >= 2u)) {
    cw_tmp_8 = (v_par.x * 0.5f);
  } else {
    cw_tmp_8 = 0.0f;
  }
  var v_longitudinal: f32 = cw_tmp_8;
  var cw_tmp_9: f32;
  if ((v_w >= 2u)) {
    cw_tmp_9 = ((v_ctrl.w * v_grip) * 1.1f);
  } else {
    cw_tmp_9 = 0.0f;
  }
  var v_braking: f32 = min(cw_divide_f32((abs(v_tv) * 1490.0f), (4.0f * cw_params.p_dt)), (((v_ctrl.z * v_grip) * 0.96f) + cw_tmp_9));
  v_longitudinal = (v_longitudinal - (f_sg(v_tv, cw_thread, cw_block, cw_grid) * v_braking));
  var v_requested: f32 = sqrt(((v_lateral * v_lateral) + (v_longitudinal * v_longitudinal)));
  var v_slip: f32 = max(0.0f, (cw_divide_f32(v_requested, max(v_grip, 1.0f)) - 1.0f));
  if ((((cw_params.p_tractionControl != 0u) && (v_w >= 2u)) && (v_ctrl.y > 0.1f))) {
    v_longitudinal = f_cf(v_longitudinal, ((-v_grip) * 0.92f), (v_grip * 0.92f), cw_thread, cw_block, cw_grid);
  }
  var v_amount: f32 = sqrt(((v_lateral * v_lateral) + (v_longitudinal * v_longitudinal)));
  var v_limit: f32 = min(1.0f, cw_divide_f32(v_grip, max(v_amount, 1.0f)));
  v_lateral = (v_lateral * v_limit);
  v_longitudinal = (v_longitudinal * v_limit);
  var v_fx: f32 = ((v_lateral * v_cs) + (v_longitudinal * v_sn));
  var v_fz: f32 = (((-v_lateral) * v_sn) + (v_longitudinal * v_cs));
  var v_wheel: vec4<f32> = b_state[(6u + v_w)];
  var v_target: f32 = cw_divide_f32(v_tv, 0.337f);
  if ((v_w >= 2u)) {
    var cw_tmp_10: f32;
    if ((cw_params.p_tractionControl != 0u)) {
      cw_tmp_10 = min(v_slip, 0.12f);
    } else {
      cw_tmp_10 = min(v_slip, 1.4f);
    }
    v_target = (v_target + (((cw_tmp_10 * v_ctrl.y) * f_sg(v_par.x, cw_thread, cw_block, cw_grid)) * 28.0f));
    v_target = (v_target * (1.0f - (v_ctrl.w * 0.93f)));
  }
  v_wheel.y = (f_approach(v_wheel.y, v_target, 230.0f, cw_params.p_dt, cw_thread, cw_block, cw_grid) * v_par.w);
  v_wheel.x = (v_wheel.x + (v_wheel.y * cw_params.p_dt));
  v_wheel.x = (v_wheel.x - ((floor(cw_divide_f32(v_wheel.x, (2.0f * 3.141592653589793f))) * 2.0f) * 3.141592653589793f));
  v_wheel.z = f_cf(((abs(v_tl) * 0.13f) + (v_slip * 0.18f)), 0.0f, 1.0f, cw_thread, cw_block, cw_grid);
  v_wheel.w = v_alpha;
  b_state[(6u + v_w)] = v_wheel;
  b_forces[v_w] = vec4<f32>(v_fx, v_fz, ((v_wz * v_fx) - (v_wx * v_fz)), v_wheel.z);
}
