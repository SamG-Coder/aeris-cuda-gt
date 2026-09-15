// CUDA WebShader 0.1.0. Generated from kernel integrateVehicle.
@group(0) @binding(0) var<storage, read_write> b_state: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read> b_forces: array<vec4<f32>>;
@group(0) @binding(2) var<storage, read> b_obstacles: array<vec4<f32>>;
@group(0) @binding(3) var<storage, read_write> b_marks: array<vec4<f32>>;
struct CWParams {
  p_obstacleCount: u32,
  p_markCount: u32,
  p_dt: f32,
  p_stabilityControl: u32,
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
  if (((cw_thread.x != 0u) || (cw_block.x != 0u))) {
    return;
  }
  var v_p: vec4<f32> = b_state[0i];
  var v_vel: vec4<f32> = b_state[1i];
  var v_att: vec4<f32> = b_state[3i];
  var v_av: vec4<f32> = b_state[4i];
  var v_ctrl: vec4<f32> = b_state[5i];
  var v_par: vec4<f32> = b_state[12i];
  var v_motion: vec4<f32> = b_state[13i];
  var v_e: vec4<f32> = b_state[2i];
  var v_a: vec4<f32> = b_forces[0i];
  var v_b: vec4<f32> = b_forces[1i];
  var v_c: vec4<f32> = b_forces[2i];
  var v_d: vec4<f32> = b_forces[3i];
  var v_fx: f32 = (((v_a.x + v_b.x) + v_c.x) + v_d.x);
  var v_fz: f32 = (((v_a.y + v_b.y) + v_c.y) + v_d.y);
  var v_m: f32 = (((v_a.z + v_b.z) + v_c.z) + v_d.z);
  var v_u: f32 = v_motion.x;
  var v_v: f32 = v_motion.y;
  var v_speed: f32 = v_motion.z;
  var v_sn: f32 = sin(v_p.w);
  var v_cs: f32 = cos(v_p.w);
  var cw_tmp_1: f32;
  if ((v_par.z > 0.5f)) {
    cw_tmp_1 = 3.0f;
  } else {
    cw_tmp_1 = 1.0f;
  }
  v_fz = (v_fz - (((0.39f * v_v) * abs(v_v)) + ((f_sg(v_v, cw_thread, cw_block, cw_grid) * min((abs(v_v) * 120.0f), 220.0f)) * cw_tmp_1)));
  var cw_tmp_2: f32;
  if ((v_ctrl.y < 0.03f)) {
    cw_tmp_2 = (v_v * 28.0f);
  } else {
    cw_tmp_2 = 0.0f;
  }
  v_fz = (v_fz - cw_tmp_2);
  var cw_tmp_3: f32;
  if ((v_par.z > 0.5f)) {
    cw_tmp_3 = 190.0f;
  } else {
    cw_tmp_3 = 35.0f;
  }
  v_fx = (v_fx - (v_u * cw_tmp_3));
  if (((cw_params.p_stabilityControl != 0u) && (v_ctrl.w < 0.1f))) {
    var v_targetYaw: f32 = cw_divide_f32((v_v * sin(v_ctrl.x)), max((cos(v_ctrl.x) * 2.68f), 0.5f));
    var v_yawLimit: f32 = cw_divide_f32((v_par.y * 9.81f), max(abs(v_v), 3.5f));
    v_targetYaw = f_cf(v_targetYaw, (-v_yawLimit), v_yawLimit, cw_thread, cw_block, cw_grid);
    v_m = (v_m + f_cf((((v_targetYaw - v_vel.w) * 1800.0f) + ((v_u * abs(v_v)) * 100.0f)), (-6500.0f), 6500.0f, cw_thread, cw_block, cw_grid));
  }
  var v_ax: f32 = cw_divide_f32(v_fx, 1490.0f);
  var v_az: f32 = cw_divide_f32(v_fz, 1490.0f);
  v_vel.x = (v_vel.x + (((v_cs * v_ax) + (v_sn * v_az)) * cw_params.p_dt));
  v_vel.z = (v_vel.z + ((((-v_sn) * v_ax) + (v_cs * v_az)) * cw_params.p_dt));
  v_vel.w = f_cf((v_vel.w + (cw_divide_f32(v_m, 2180.0f) * cw_params.p_dt)), (-2.7f), 2.7f, cw_thread, cw_block, cw_grid);
  if (((v_par.w < 0.5f) || ((v_speed < 0.08f) && (v_ctrl.y < 0.03f)))) {
    v_vel.x = 0.0f;
    v_vel.z = 0.0f;
    v_vel.w = 0.0f;
  }
  v_p.x = (v_p.x + (v_vel.x * cw_params.p_dt));
  v_p.z = (v_p.z + (v_vel.z * cw_params.p_dt));
  v_p.w = (v_p.w + (v_vel.w * cw_params.p_dt));
  v_p.w = (v_p.w - ((floor(cw_divide_f32((v_p.w + 3.141592653589793f), (2.0f * 3.141592653589793f))) * 2.0f) * 3.141592653589793f));
  var v_impact: f32 = 0.0f;
  {
    var v_j: u32 = 0u;
    loop {
      if (!(v_j < cw_params.p_obstacleCount)) { break; }
      var v_ob: vec4<f32> = b_obstacles[v_j];
      var v_dx: f32 = (v_p.x - v_ob.x);
      var v_dz: f32 = (v_p.z - v_ob.z);
      var v_dist: f32 = sqrt(((v_dx * v_dx) + (v_dz * v_dz)));
      var v_rr: f32 = (v_ob.w + 1.02f);
      if ((v_dist < v_rr)) {
        var v_nx: f32 = cw_divide_f32(v_dx, max(v_dist, 0.001f));
        var v_nz: f32 = cw_divide_f32(v_dz, max(v_dist, 0.001f));
        var v_vn: f32 = min(0.0f, ((v_vel.x * v_nx) + (v_vel.z * v_nz)));
        v_p.x = (v_ob.x + (v_nx * v_rr));
        v_p.z = (v_ob.z + (v_nz * v_rr));
        v_vel.x = (v_vel.x - ((1.12f * v_vn) * v_nx));
        v_vel.z = (v_vel.z - ((1.12f * v_vn) * v_nz));
        v_impact = max(v_impact, (-v_vn));
      }
      continuing {
        v_j += u32(1);
      }
    }
  }
  v_p.x = f_cf(v_p.x, (-440.0f), 440.0f, cw_thread, cw_block, cw_grid);
  v_p.z = f_cf(v_p.z, (-500.0f), 500.0f, cw_thread, cw_block, cw_grid);
  if (((abs(v_p.x) >= 440.0f) || (abs(v_p.z) >= 500.0f))) {
    v_vel.x = (v_vel.x * 0.9f);
    v_vel.z = (v_vel.z * 0.9f);
  }
  var v_pitch: f32 = f_cf(((-v_az) * 0.0035f), (-0.042f), 0.042f, cw_thread, cw_block, cw_grid);
  var v_roll: f32 = f_cf(((-v_ax) * 0.006f), (-0.064f), 0.064f, cw_thread, cw_block, cw_grid);
  var cw_tmp_4: f32;
  if ((v_par.z > 0.5f)) {
    cw_tmp_4 = 0.012f;
  } else {
    cw_tmp_4 = 0.0015f;
  }
  var v_heave: f32 = ((cw_tmp_4 * sin(((v_p.z * 3.0f) + (v_p.x * 1.5f)))) * min((v_speed * 0.12f), 1.0f));
  v_av.x = (v_av.x + ((((v_heave - v_att.x) * 120.0f) - (v_av.x * 16.0f)) * cw_params.p_dt));
  v_av.y = (v_av.y + ((((v_pitch - v_att.y) * 95.0f) - (v_av.y * 14.0f)) * cw_params.p_dt));
  v_av.z = (v_av.z + ((((v_roll - v_att.z) * 110.0f) - (v_av.z * 15.0f)) * cw_params.p_dt));
  v_att.x = (v_att.x + (v_av.x * cw_params.p_dt));
  v_att.y = (v_att.y + (v_av.y * cw_params.p_dt));
  v_att.z = (v_att.z + (v_av.z * cw_params.p_dt));
  v_att.w = (v_att.w + cw_params.p_dt);
  v_av.w = f_cf(((v_av.w + (((v_ctrl.z * v_speed) * 0.055f) * cw_params.p_dt)) - (((v_av.w - 20.0f) * 0.03f) * cw_params.p_dt)), 20.0f, 650.0f, cw_thread, cw_block, cw_grid);
  v_e.w = (v_e.w + (v_speed * cw_params.p_dt));
  b_state[0i] = v_p;
  b_state[1i] = v_vel;
  b_state[2i] = v_e;
  b_state[3i] = v_att;
  b_state[4i] = v_av;
  b_state[10i] = vec4<f32>(v_ax, v_az, v_speed, v_par.z);
  var cw_tmp_5: f32;
  if ((abs(v_par.x) > (v_par.y * 7300.0f))) {
    cw_tmp_5 = 1.0f;
  } else {
    cw_tmp_5 = 0.0f;
  }
  var cw_tmp_6: f32;
  if ((v_ctrl.z > 0.5f)) {
    cw_tmp_6 = 1.0f;
  } else {
    cw_tmp_6 = 0.0f;
  }
  b_state[11i] = vec4<f32>(cw_tmp_5, cw_tmp_6, v_impact, max(max(v_a.w, v_b.w), max(v_c.w, v_d.w)));
  var v_tick: u32 = u32(cw_divide_f32(v_att.w, cw_params.p_dt));
  {
    var v_w: u32 = 0u;
    loop {
      if (!(v_w < 4u)) { break; }
      var v_slip: f32 = b_forces[v_w].w;
      if (((v_speed > 0.9f) && (v_slip > 0.2f))) {
        var v_slot: u32 = (((v_tick * 4u) + v_w) % cw_params.p_markCount);
        var cw_tmp_7: f32;
        if (((v_w % 2u) == 0u)) {
          cw_tmp_7 = (-0.852f);
        } else {
          cw_tmp_7 = 0.852f;
        }
        var v_wx: f32 = cw_tmp_7;
        var cw_tmp_8: f32;
        if ((v_w < 2u)) {
          cw_tmp_8 = 1.34f;
        } else {
          cw_tmp_8 = (-1.34f);
        }
        var v_wz: f32 = cw_tmp_8;
        b_marks[(v_slot * 2u)] = vec4<f32>(((v_p.x + (v_cs * v_wx)) + (v_sn * v_wz)), 0.017f, ((v_p.z - (v_sn * v_wx)) + (v_cs * v_wz)), f_cf((v_slip * 0.6f), 0.04f, 0.55f, cw_thread, cw_block, cw_grid));
        b_marks[((v_slot * 2u) + 1u)] = vec4<f32>(v_p.w, 0.245f, max((v_speed * cw_params.p_dt), 0.035f), v_att.w);
      }
      continuing {
        v_w += u32(1);
      }
    }
  }
}
