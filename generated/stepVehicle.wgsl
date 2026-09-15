// CUDA WebShader 0.1.0. Generated from kernel stepVehicle.
@group(0) @binding(0) var<storage, read_write> b_state: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read> b_road: array<vec4<f32>>;
struct CWParams {
  p_roadCount: u32,
  p_dt: f32,
  p_drive: f32,
  p_brake: f32,
  p_steering: f32,
  p_handbrake: f32,
  p_automatic: u32,
  p_shift: i32,
  p_wetness: f32,
  p_showroom: u32,
  cw_pad_40: u32,
  cw_pad_44: u32,
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
fn f_cw_buffer_helper_0(cw_buffer_arg_0: i32, cw_arg_count: u32, cw_arg_x: f32, cw_arg_z: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> f32 {
  var cw_buffer_offset_0: i32 = cw_buffer_arg_0;
  var v_count: u32 = cw_arg_count;
  var v_x: f32 = cw_arg_x;
  var v_z: f32 = cw_arg_z;
  var v_best: f32 = 100000000.0f;
  {
    var v_i: u32 = 0u;
    loop {
      if (!(v_i < v_count)) { break; }
      var v_j: u32 = (v_i + 1u);
      if ((v_j == v_count)) {
        v_j = 0u;
      }
      var v_a: vec4<f32> = b_road[(cw_buffer_offset_0 + i32(v_i))];
      var v_b: vec4<f32> = b_road[(cw_buffer_offset_0 + i32(v_j))];
      var v_dx: f32 = (v_b.x - v_a.x);
      var v_dz: f32 = (v_b.z - v_a.z);
      var v_t: f32 = f_cf(cw_divide_f32((((v_x - v_a.x) * v_dx) + ((v_z - v_a.z) * v_dz)), max(((v_dx * v_dx) + (v_dz * v_dz)), 0.001f)), 0.0f, 1.0f, cw_thread, cw_block, cw_grid);
      var v_ex: f32 = ((v_x - v_a.x) - (v_t * v_dx));
      var v_ez: f32 = ((v_z - v_a.z) - (v_t * v_dz));
      v_best = min(v_best, ((v_ex * v_ex) + (v_ez * v_ez)));
      continuing {
        v_i += u32(1);
      }
    }
  }
  return sqrt(v_best);
}

@compute @workgroup_size(128, 1, 1)
fn main(
  @builtin(local_invocation_id) cw_thread: vec3<u32>,
  @builtin(workgroup_id) cw_block: vec3<u32>,
  @builtin(num_workgroups) cw_grid: vec3<u32>
) {
  if (((cw_thread.x != 0u) || (cw_block.x != 0u))) {
    return;
  }
  var v_p: vec4<f32> = b_state[0i];
  var v_vel: vec4<f32> = b_state[1i];
  var v_engine: vec4<f32> = b_state[2i];
  var v_ctrl: vec4<f32> = b_state[5i];
  var v_sn: f32 = sin(v_p.w);
  var v_cs: f32 = cos(v_p.w);
  var v_u: f32 = ((v_cs * v_vel.x) - (v_sn * v_vel.z));
  var v_v: f32 = ((v_sn * v_vel.x) + (v_cs * v_vel.z));
  var v_speed: f32 = sqrt(((v_u * v_u) + (v_v * v_v)));
  var cw_tmp_1: f32;
  if ((f_cw_buffer_helper_0(0i, cw_params.p_roadCount, v_p.x, v_p.z, cw_thread, cw_block, cw_grid) > 7.4f)) {
    cw_tmp_1 = 1.0f;
  } else {
    cw_tmp_1 = 0.0f;
  }
  var v_off: f32 = cw_tmp_1;
  var v_gear: i32 = i32(v_engine.y);
  var v_throttle: f32 = 0.0f;
  var v_braking: f32 = cw_params.p_brake;
  if ((cw_params.p_drive < (-0.01f))) {
    if ((v_v > 0.55f)) {
      v_braking = max(v_braking, (-cw_params.p_drive));
    } else {
      v_gear = (-1i);
      v_throttle = (-cw_params.p_drive);
    }
  }
  if ((cw_params.p_drive > 0.01f)) {
    if ((v_v < (-0.55f))) {
      v_braking = max(v_braking, cw_params.p_drive);
    } else {
      var cw_tmp_2: i32;
      if ((v_gear < 1i)) {
        cw_tmp_2 = 1i;
      } else {
        cw_tmp_2 = v_gear;
      }
      v_gear = cw_tmp_2;
      v_throttle = cw_params.p_drive;
    }
  }
  if ((cw_params.p_showroom != 0u)) {
    v_throttle = 0.0f;
    v_braking = 1.0f;
  }
  v_ctrl.y = f_approach(v_ctrl.y, v_throttle, 3.2f, cw_params.p_dt, cw_thread, cw_block, cw_grid);
  v_ctrl.z = f_approach(v_ctrl.z, v_braking, 6.0f, cw_params.p_dt, cw_thread, cw_block, cw_grid);
  v_ctrl.w = cw_params.p_handbrake;
  var v_rawLock: f32 = cw_divide_f32(0.5f, (1.0f + (v_speed * 0.024f)));
  var cw_tmp_3: f32;
  if ((v_off > 0.5f)) {
    cw_tmp_3 = 0.52f;
  } else {
    cw_tmp_3 = 1.18f;
  }
  var v_cornerGrip: f32 = ((cw_tmp_3 * (1.0f - (cw_params.p_wetness * 0.34f))) * 9.81f);
  var v_roadLock: f32 = atan2(((v_cornerGrip * 2.68f) * 0.85f), max((v_speed * v_speed), 1.0f));
  var cw_tmp_4: f32;
  if ((cw_params.p_handbrake > 0.1f)) {
    cw_tmp_4 = v_rawLock;
  } else {
    cw_tmp_4 = min(v_rawLock, v_roadLock);
  }
  var v_lock: f32 = cw_tmp_4;
  v_ctrl.x = f_approach(v_ctrl.x, (cw_params.p_steering * v_lock), cw_divide_f32(1.95f, (1.0f + (v_speed * 0.014f))), cw_params.p_dt, cw_thread, cw_block, cw_grid);
  v_engine.z = max(0.0f, (v_engine.z - cw_params.p_dt));
  var v_gr: f32 = f_ratio(v_gear, cw_thread, cw_block, cw_grid);
  var v_rpm: f32 = max(950.0f, (((cw_divide_f32(abs(v_v), 0.337f) * abs(v_gr)) * 3.35f) * 9.549297f));
  v_rpm = max(v_rpm, (950.0f + ((v_ctrl.y * 1700.0f) * (1.0f - f_cf(cw_divide_f32(abs(v_v), 8.0f), 0.0f, 1.0f, cw_thread, cw_block, cw_grid)))));
  if ((((cw_params.p_automatic != 0u) && (v_gear > 0i)) && (v_engine.z == 0.0f))) {
    if (((v_rpm > 7500.0f) && (v_gear < 7i))) {
      v_gear += i32(1);
      v_engine.z = 0.17f;
    } else {
      if (((v_rpm < 2600.0f) && (v_gear > 1i))) {
        v_gear -= i32(1);
        v_engine.z = 0.13f;
      }
    }
  }
  if (((cw_params.p_automatic == 0u) && (cw_params.p_shift != 0i))) {
    v_gear = i32(f_cf(f32((v_gear + cw_params.p_shift)), 1.0f, 7.0f, cw_thread, cw_block, cw_grid));
    v_engine.z = 0.16f;
  }
  v_gr = f_ratio(v_gear, cw_thread, cw_block, cw_grid);
  var v_rr: f32 = cw_divide_f32((v_rpm - 5600.0f), 3500.0f);
  var v_torque: f32 = (640.0f * (0.59f + (0.41f * exp(((-v_rr) * v_rr)))));
  var cw_tmp_5: f32;
  if ((v_engine.z > 0.0f)) {
    cw_tmp_5 = 0.16f;
  } else {
    cw_tmp_5 = 1.0f;
  }
  var cw_tmp_6: f32;
  if ((v_rpm > 8150.0f)) {
    cw_tmp_6 = 0.15f;
  } else {
    cw_tmp_6 = 1.0f;
  }
  var v_demand: f32 = (((cw_divide_f32((((v_torque * v_gr) * 3.35f) * 0.9f), 0.337f) * v_ctrl.y) * cw_tmp_5) * cw_tmp_6);
  v_engine.x = f_approach(v_engine.x, v_rpm, 9500.0f, cw_params.p_dt, cw_thread, cw_block, cw_grid);
  v_engine.y = f32(v_gear);
  b_state[2i] = v_engine;
  b_state[5i] = v_ctrl;
  var cw_tmp_7: f32;
  if ((v_off > 0.5f)) {
    cw_tmp_7 = 0.52f;
  } else {
    cw_tmp_7 = 1.18f;
  }
  var cw_tmp_8: f32;
  if ((cw_params.p_showroom != 0u)) {
    cw_tmp_8 = 0.0f;
  } else {
    cw_tmp_8 = 1.0f;
  }
  b_state[12i] = vec4<f32>(v_demand, (cw_tmp_7 * (1.0f - (cw_params.p_wetness * 0.34f))), v_off, cw_tmp_8);
  b_state[13i] = vec4<f32>(v_u, v_v, v_speed, v_vel.w);
}
