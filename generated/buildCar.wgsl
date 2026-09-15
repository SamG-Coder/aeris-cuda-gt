// CUDA WebShader 0.1.0. Generated from kernel buildCar.
@group(0) @binding(0) var<storage, read> b_parts: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read> b_jobs: array<vec4<f32>>;
@group(0) @binding(2) var<storage, read> b_samples: array<vec4<f32>>;
@group(0) @binding(3) var<storage, read_write> b_positions: array<vec4<f32>>;
@group(0) @binding(4) var<storage, read_write> b_normals: array<vec4<f32>>;
@group(0) @binding(5) var<storage, read_write> b_uvMeta: array<vec4<f32>>;
struct CWParams {
  p_partCount: u32,
  cw_pad_4: u32,
  cw_pad_8: u32,
  cw_pad_12: u32,
}
@group(0) @binding(6) var<uniform> cw_params: CWParams;
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
  var v_id: u32 = cw_block.x;
  if ((v_id >= cw_params.p_partCount)) {
    return;
  }
  var v_j: vec4<f32> = b_jobs[v_id];
  var v_info: vec4<f32> = b_parts[(v_id * 10u)];
  var v_start: u32 = u32(v_j.x);
  var v_nu: u32 = u32(v_j.y);
  var v_nv: u32 = u32(v_j.z);
  var v_base: u32 = u32(v_j.w);
  var v_type: i32 = i32(v_info.x);
  var v_side: f32 = b_parts[((v_id * 10u) + 2u)].w;
  var v_orient: f32 = 1.0f;
  if (((((v_type == 3i) || (v_type == 11i)) || (v_type == 15i)) || (v_type == 38i))) {
    v_orient = v_side;
  }
  if (((((v_type == 4i) || (v_type == 9i)) || (v_type == 10i)) || (v_type == 16i))) {
    v_orient = (-v_side);
  }
  if ((((((((v_type == 8i) || (v_type == 13i)) || (v_type == 14i)) || (v_type == 30i)) || (v_type == 31i)) || (v_type == 35i)) || (v_type == 39i))) {
    v_orient = (-1.0f);
  }
  if ((v_type == 34i)) {
    var cw_tmp_1: f32;
    if ((b_parts[((v_id * 10u) + 2u)].x < 0.0f)) {
      cw_tmp_1 = 1.0f;
    } else {
      cw_tmp_1 = (-1.0f);
    }
    v_orient = cw_tmp_1;
  }
  {
    var v_k: u32 = cw_thread.x;
    loop {
      if (!(v_k < ((v_nu * v_nv) * 6u))) { break; }
      var v_cell: u32 = (v_k / 6u);
      var v_c: u32 = (v_k % 6u);
      var v_ix: u32 = (v_cell % v_nu);
      var v_iy: u32 = (v_cell / v_nu);
      var cw_tmp_2: u32;
      if ((((v_c == 1u) || (v_c == 2u)) || (v_c == 4u))) {
        cw_tmp_2 = 1u;
      } else {
        cw_tmp_2 = 0u;
      }
      var v_gx: u32 = (v_ix + cw_tmp_2);
      var cw_tmp_3: u32;
      if ((((v_c == 2u) || (v_c == 4u)) || (v_c == 5u))) {
        cw_tmp_3 = 1u;
      } else {
        cw_tmp_3 = 0u;
      }
      var v_gy: u32 = (v_iy + cw_tmp_3);
      var v_si: u32 = ((v_base + (v_gy * (v_nu + 1u))) + v_gx);
      var cw_tmp_4: u32;
      if ((v_gx > 0u)) {
        cw_tmp_4 = (v_si - 1u);
      } else {
        cw_tmp_4 = v_si;
      }
      var v_left: u32 = cw_tmp_4;
      var cw_tmp_5: u32;
      if ((v_gx < v_nu)) {
        cw_tmp_5 = (v_si + 1u);
      } else {
        cw_tmp_5 = v_si;
      }
      var v_right: u32 = cw_tmp_5;
      var cw_tmp_6: u32;
      if ((v_gy > 0u)) {
        cw_tmp_6 = ((v_si - v_nu) - 1u);
      } else {
        cw_tmp_6 = v_si;
      }
      var v_down: u32 = cw_tmp_6;
      var cw_tmp_7: u32;
      if ((v_gy < v_nv)) {
        cw_tmp_7 = ((v_si + v_nu) + 1u);
      } else {
        cw_tmp_7 = v_si;
      }
      var v_up: u32 = cw_tmp_7;
      let cw_argument_index_8 = v_si;
      var v_p: vec3<f32> = f_xyz(b_samples[cw_argument_index_8], cw_thread, cw_block, cw_grid);
      let cw_argument_index_9 = v_right;
      let cw_argument_index_10 = v_left;
      let cw_argument_index_11 = v_up;
      let cw_argument_index_12 = v_down;
      var v_n: vec3<f32> = f_mul(f_unit(f_cross3(f_sub(f_xyz(b_samples[cw_argument_index_9], cw_thread, cw_block, cw_grid), f_xyz(b_samples[cw_argument_index_10], cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid), f_sub(f_xyz(b_samples[cw_argument_index_11], cw_thread, cw_block, cw_grid), f_xyz(b_samples[cw_argument_index_12], cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid), v_orient, cw_thread, cw_block, cw_grid);
      var v_dest: u32 = v_k;
      if ((v_orient < 0.0f)) {
        var v_t: u32 = (v_k % 3u);
        var cw_tmp_14: u32;
        if ((v_t == 1u)) {
          cw_tmp_14 = 2u;
        } else {
          var cw_tmp_13: u32;
          if ((v_t == 2u)) {
            cw_tmp_13 = 1u;
          } else {
            cw_tmp_13 = 0u;
          }
          cw_tmp_14 = cw_tmp_13;
        }
        v_dest = ((v_k - v_t) + cw_tmp_14);
      }
      var v_o: u32 = (v_start + v_dest);
      b_positions[v_o] = vec4<f32>(v_p.x, v_p.y, v_p.z, v_info.z);
      b_normals[v_o] = vec4<f32>(v_n.x, v_n.y, v_n.z, 0.0f);
      b_uvMeta[v_o] = vec4<f32>(cw_divide_f32(f32(v_gx), f32(v_nu)), cw_divide_f32(f32(v_gy), f32(v_nv)), f32(v_type), v_info.y);
      continuing {
        v_k = (v_k + cw_block_size.x);
      }
    }
  }
}
