// CUDA WebShader 0.1.0. Generated from kernel buildPose.
@group(0) @binding(0) var<storage, read> b_state: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read_write> b_poses: array<vec4<f32>>;
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
fn f_cw_buffer_helper_0(cw_buffer_arg_0: i32, cw_arg_p: vec3<f32>, cw_arg_tag: i32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) -> vec3<f32> {
  var cw_buffer_offset_0: i32 = cw_buffer_arg_0;
  var v_p: vec3<f32> = cw_arg_p;
  var v_tag: i32 = cw_arg_tag;
  if ((v_tag == 5i)) {
    v_p.x = (v_p.x + 0.345f);
    v_p.y = (v_p.y - 0.69f);
    v_p.z = (v_p.z - 0.205f);
    v_p = f_rotZ(v_p, ((-b_state[(cw_buffer_offset_0 + 5i)].x) * 4.8f), cw_thread, cw_block, cw_grid);
    v_p.x = (v_p.x - 0.345f);
    v_p.y = (v_p.y + 0.69f);
    v_p.z = (v_p.z + 0.205f);
  }
  if (((v_tag == 0i) || (v_tag == 5i))) {
    v_p.y = (v_p.y - 0.345f);
    v_p = f_rotZ(f_rotX(v_p, b_state[(cw_buffer_offset_0 + 3i)].y, cw_thread, cw_block, cw_grid), b_state[(cw_buffer_offset_0 + 3i)].z, cw_thread, cw_block, cw_grid);
    v_p.y = (v_p.y + (0.345f + b_state[(cw_buffer_offset_0 + 3i)].x));
  } else {
    var cw_tmp_1: i32;
    if ((v_tag >= 6i)) {
      cw_tmp_1 = (v_tag - 6i);
    } else {
      cw_tmp_1 = (v_tag - 1i);
    }
    var v_w: i32 = cw_tmp_1;
    var cw_tmp_2: f32;
    if (((v_w % 2i) == 0i)) {
      cw_tmp_2 = (-0.852f);
    } else {
      cw_tmp_2 = 0.852f;
    }
    var v_x: f32 = cw_tmp_2;
    var cw_tmp_3: f32;
    if ((v_w < 2i)) {
      cw_tmp_3 = 1.34f;
    } else {
      cw_tmp_3 = (-1.34f);
    }
    var v_z: f32 = cw_tmp_3;
    v_p.x = (v_p.x - v_x);
    v_p.y = (v_p.y - 0.345f);
    v_p.z = (v_p.z - v_z);
    if ((v_tag < 5i)) {
      v_p = f_rotX(v_p, b_state[(cw_buffer_offset_0 + (6i + v_w))].x, cw_thread, cw_block, cw_grid);
    }
    if ((v_w < 2i)) {
      v_p = f_rotY(v_p, b_state[(cw_buffer_offset_0 + 5i)].x, cw_thread, cw_block, cw_grid);
    }
    v_p.x = (v_p.x + v_x);
    v_p.y = (v_p.y + 0.345f);
    v_p.z = (v_p.z + v_z);
  }
  v_p = f_rotY(v_p, b_state[(cw_buffer_offset_0 + 0i)].w, cw_thread, cw_block, cw_grid);
  return vec3<f32>((v_p.x + b_state[(cw_buffer_offset_0 + 0i)].x), (v_p.y + b_state[(cw_buffer_offset_0 + 0i)].y), (v_p.z + b_state[(cw_buffer_offset_0 + 0i)].z));
}

@compute @workgroup_size(128, 1, 1)
fn main(
  @builtin(local_invocation_id) cw_thread: vec3<u32>,
  @builtin(workgroup_id) cw_block: vec3<u32>,
  @builtin(num_workgroups) cw_grid: vec3<u32>
) {
  var v_tag: u32 = cw_thread.x;
  if (((cw_block.x != 0u) || (v_tag >= 10u))) {
    return;
  }
  var v_o: vec3<f32> = f_cw_buffer_helper_0(0i, vec3<f32>(0.0f, 0.0f, 0.0f), i32(v_tag), cw_thread, cw_block, cw_grid);
  var v_x: vec3<f32> = f_cw_buffer_helper_0(0i, vec3<f32>(1.0f, 0.0f, 0.0f), i32(v_tag), cw_thread, cw_block, cw_grid);
  var v_y: vec3<f32> = f_cw_buffer_helper_0(0i, vec3<f32>(0.0f, 1.0f, 0.0f), i32(v_tag), cw_thread, cw_block, cw_grid);
  var v_z: vec3<f32> = f_cw_buffer_helper_0(0i, vec3<f32>(0.0f, 0.0f, 1.0f), i32(v_tag), cw_thread, cw_block, cw_grid);
  b_poses[(v_tag * 4u)] = vec4<f32>((v_x.x - v_o.x), (v_x.y - v_o.y), (v_x.z - v_o.z), 0.0f);
  b_poses[((v_tag * 4u) + 1u)] = vec4<f32>((v_y.x - v_o.x), (v_y.y - v_o.y), (v_y.z - v_o.z), 0.0f);
  b_poses[((v_tag * 4u) + 2u)] = vec4<f32>((v_z.x - v_o.x), (v_z.y - v_o.y), (v_z.z - v_o.z), 0.0f);
  b_poses[((v_tag * 4u) + 3u)] = vec4<f32>(v_o.x, v_o.y, v_o.z, 1.0f);
}
