// CUDA WebShader 0.1.0. Generated from kernel describeCar.
@group(0) @binding(0) var<storage, read_write> b_parts: array<vec4<f32>>;
@group(0) @binding(1) var<storage, read_write> b_count: array<u32>;
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
fn f_cw_buffer_helper_0(cw_buffer_arg_0: i32, cw_arg_i: i32, cw_arg_type: i32, cw_arg_mat: i32, cw_arg_tag: i32, cw_arg_nu: i32, cw_arg_nv: i32, cw_arg_sz: vec3<f32>, cw_arg_p: vec3<f32>, cw_arg_r: vec3<f32>, cw_arg_variant: f32, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) {
  var cw_buffer_offset_0: i32 = cw_buffer_arg_0;
  var v_i: i32 = cw_arg_i;
  var v_type: i32 = cw_arg_type;
  var v_mat: i32 = cw_arg_mat;
  var v_tag: i32 = cw_arg_tag;
  var v_nu: i32 = cw_arg_nu;
  var v_nv: i32 = cw_arg_nv;
  var v_sz: vec3<f32> = cw_arg_sz;
  var v_p: vec3<f32> = cw_arg_p;
  var v_r: vec3<f32> = cw_arg_r;
  var v_variant: f32 = cw_arg_variant;
  var v_o: i32 = (v_i * 10i);
  b_parts[(cw_buffer_offset_0 + v_o)] = vec4<f32>(f32(v_type), f32(v_mat), f32(v_tag), f32(v_nu));
  b_parts[(cw_buffer_offset_0 + (v_o + 1i))] = vec4<f32>(v_sz.x, v_sz.y, v_sz.z, f32(v_nv));
  b_parts[(cw_buffer_offset_0 + (v_o + 2i))] = vec4<f32>(v_p.x, v_p.y, v_p.z, v_variant);
  b_parts[(cw_buffer_offset_0 + (v_o + 3i))] = vec4<f32>(v_r.x, v_r.y, v_r.z, 0.0f);
  {
    var v_j: i32 = 4i;
    loop {
      if (!(v_j < 10i)) { break; }
      b_parts[(cw_buffer_offset_0 + (v_o + v_j))] = vec4<f32>(0.0f, 0.0f, 0.0f, 0.0f);
      continuing {
        v_j += i32(1);
      }
    }
  }
}
fn f_cw_buffer_helper_1(cw_buffer_arg_0: i32, cw_arg_i: i32, cw_arg_mat: i32, cw_arg_tag: i32, cw_arg_radius: f32, cw_arg_a: vec3<f32>, cw_arg_b: vec3<f32>, cw_arg_c: vec3<f32>, cw_arg_e: vec3<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) {
  var cw_buffer_offset_0: i32 = cw_buffer_arg_0;
  var v_i: i32 = cw_arg_i;
  var v_mat: i32 = cw_arg_mat;
  var v_tag: i32 = cw_arg_tag;
  var v_radius: f32 = cw_arg_radius;
  var v_a: vec3<f32> = cw_arg_a;
  var v_b: vec3<f32> = cw_arg_b;
  var v_c: vec3<f32> = cw_arg_c;
  var v_e: vec3<f32> = cw_arg_e;
  f_cw_buffer_helper_0((cw_buffer_offset_0 + 0i), v_i, 35i, v_mat, v_tag, 32i, 10i, f_V(v_radius, 1.0f, 1.0f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.0f, 0.0f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.0f, 0.0f, cw_thread, cw_block, cw_grid), 0.0f, cw_thread, cw_block, cw_grid);
  var v_o: i32 = (v_i * 10i);
  b_parts[(cw_buffer_offset_0 + (v_o + 4i))] = vec4<f32>(v_a.x, v_a.y, v_a.z, 0.0f);
  b_parts[(cw_buffer_offset_0 + (v_o + 5i))] = vec4<f32>(v_b.x, v_b.y, v_b.z, 0.0f);
  b_parts[(cw_buffer_offset_0 + (v_o + 6i))] = vec4<f32>(v_c.x, v_c.y, v_c.z, 0.0f);
  b_parts[(cw_buffer_offset_0 + (v_o + 7i))] = vec4<f32>(v_e.x, v_e.y, v_e.z, 0.0f);
}
fn f_cw_buffer_helper_2(cw_buffer_arg_0: i32, cw_arg_i: i32, cw_arg_mat: i32, cw_arg_tag: i32, cw_arg_sz: vec3<f32>, cw_arg_p: vec3<f32>, cw_arg_r: vec3<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) {
  var cw_buffer_offset_0: i32 = cw_buffer_arg_0;
  var v_i: i32 = cw_arg_i;
  var v_mat: i32 = cw_arg_mat;
  var v_tag: i32 = cw_arg_tag;
  var v_sz: vec3<f32> = cw_arg_sz;
  var v_p: vec3<f32> = cw_arg_p;
  var v_r: vec3<f32> = cw_arg_r;
  f_cw_buffer_helper_0((cw_buffer_offset_0 + 0i), v_i, 31i, v_mat, v_tag, 24i, 16i, v_sz, v_p, v_r, 0.0f, cw_thread, cw_block, cw_grid);
}
fn f_cw_buffer_helper_3(cw_buffer_arg_0: i32, cw_arg_i: i32, cw_arg_mat: i32, cw_arg_tag: i32, cw_arg_radius: f32, cw_arg_a: vec3<f32>, cw_arg_b: vec3<f32>, cw_thread: vec3<u32>, cw_block: vec3<u32>, cw_grid: vec3<u32>) {
  var cw_buffer_offset_0: i32 = cw_buffer_arg_0;
  var v_i: i32 = cw_arg_i;
  var v_mat: i32 = cw_arg_mat;
  var v_tag: i32 = cw_arg_tag;
  var v_radius: f32 = cw_arg_radius;
  var v_a: vec3<f32> = cw_arg_a;
  var v_b: vec3<f32> = cw_arg_b;
  f_cw_buffer_helper_1((cw_buffer_offset_0 + 0i), v_i, v_mat, v_tag, v_radius, v_a, f_mix3(v_a, v_b, 0.33333f, cw_thread, cw_block, cw_grid), f_mix3(v_a, v_b, 0.66667f, cw_thread, cw_block, cw_grid), v_b, cw_thread, cw_block, cw_grid);
  b_parts[(cw_buffer_offset_0 + (v_i * 10i))].w = 4.0f;
}

@compute @workgroup_size(128, 1, 1)
fn main(
  @builtin(local_invocation_id) cw_thread: vec3<u32>,
  @builtin(workgroup_id) cw_block: vec3<u32>,
  @builtin(num_workgroups) cw_grid: vec3<u32>
) {
  if (((cw_block.x != 0u) || (cw_thread.x != 0u))) {
    return;
  }
  var v_id: i32 = 0i;
  var v_O: vec3<f32> = f_V(0.0f, 0.0f, 0.0f, cw_thread, cw_block, cw_grid);
  var v_S: vec3<f32> = f_V(1.0f, 1.0f, 1.0f, cw_thread, cw_block, cw_grid);
  f_cw_buffer_helper_0(0i, v_id, 1i, 0i, 0i, 96i, 40i, v_S, v_O, v_O, 0.0f, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_0(0i, v_id, 2i, 0i, 0i, 64i, 40i, v_S, v_O, v_O, 0.0f, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  {
    var v_si: i32 = 0i;
    loop {
      if (!(v_si < 2i)) { break; }
      var cw_tmp_1: f32;
      if ((v_si == 0i)) {
        cw_tmp_1 = (-1.0f);
      } else {
        cw_tmp_1 = 1.0f;
      }
      var v_s: f32 = cw_tmp_1;
      f_cw_buffer_helper_0(0i, v_id, 3i, 0i, 0i, 160i, 24i, v_S, v_O, v_O, v_s, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_0(0i, v_id, 4i, 0i, 0i, 160i, 32i, v_S, v_O, v_O, v_s, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_0(0i, v_id, 9i, 6i, 0i, 56i, 32i, v_S, v_O, v_O, v_s, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_0(0i, v_id, 10i, 7i, 0i, 64i, 8i, v_S, v_O, v_O, v_s, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_0(0i, v_id, 15i, 1i, 0i, 64i, 12i, v_S, v_O, v_O, v_s, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      {
        var v_axle: i32 = 0i;
        loop {
          if (!(v_axle < 2i)) { break; }
          var cw_tmp_2: f32;
          if ((v_axle == 0i)) {
            cw_tmp_2 = 1.34f;
          } else {
            cw_tmp_2 = (-1.34f);
          }
          var v_z: f32 = cw_tmp_2;
          f_cw_buffer_helper_0(0i, v_id, 11i, 0i, 0i, 64i, 8i, f_V(0.015f, 1.0f, 1.0f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.944f), 0.345f, v_z, cw_thread, cw_block, cw_grid), v_O, v_s, cw_thread, cw_block, cw_grid);
          v_id += i32(1);
          f_cw_buffer_helper_0(0i, v_id, 12i, 7i, 0i, 64i, 8i, f_V(0.15f, 1.0f, 1.0f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.862f), 0.345f, v_z, cw_thread, cw_block, cw_grid), v_O, v_s, cw_thread, cw_block, cw_grid);
          v_id += i32(1);
          continuing {
            v_axle += i32(1);
          }
        }
      }
      f_cw_buffer_helper_1(0i, v_id, 7i, 0i, 0.0028f, f_V((v_s * 0.902f), 0.772f, 0.66f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.929f), 0.47f, 0.59f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.915f), 0.265f, 0.35f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.905f), 0.227f, (-0.1f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_1(0i, v_id, 7i, 0i, 0.0028f, f_V((v_s * 0.905f), 0.227f, (-0.1f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.912f), 0.24f, (-0.48f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.934f), 0.49f, (-0.79f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.938f), 0.808f, (-0.78f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_2(0i, v_id, 7i, 0i, f_V(0.009f, 0.016f, 0.097f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.927f), 0.715f, (-0.53f), cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_2(0i, v_id, 3i, 0i, f_V(0.01f, 0.008f, 0.077f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.939f), 0.719f, (-0.52f), cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_0(0i, v_id, 16i, 7i, 0i, 40i, 24i, v_S, v_O, v_O, v_s, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_1(0i, v_id, 0i, 0i, 0.021f, f_V((v_s * 0.932f), 0.52f, (-0.65f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.992f), 0.6f, (-0.82f), cw_thread, cw_block, cw_grid), f_V((v_s * 1.0f), 0.65f, (-1.06f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.964f), 0.7f, (-1.16f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_3(0i, v_id, 7i, 0i, 0.016f, f_V((v_s * 0.73f), 0.827f, 0.55f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.973f), 0.87f, 0.56f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_0(0i, v_id, 30i, 0i, 0i, 32i, 20i, f_V(0.141f, 0.047f, 0.091f, cw_thread, cw_block, cw_grid), f_V((v_s * 1.026f), 0.9f, 0.56f, cw_thread, cw_block, cw_grid), v_O, 0.0f, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_2(0i, v_id, 17i, 0i, f_V(0.116f, 0.028f, 0.004f, cw_thread, cw_block, cw_grid), f_V((v_s * 1.016f), 0.898f, 0.477f, cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_1(0i, v_id, 0i, 0i, 0.023f, f_V((v_s * 0.737f), 0.79f, 0.845f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.69f), 0.91f, 0.59f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.6f), 1.16f, 0.29f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.568f), 1.192f, 0.17f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_1(0i, v_id, 0i, 0i, 0.023f, f_V((v_s * 0.568f), 1.192f, 0.17f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.585f), 1.23f, (-0.13f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.606f), 1.21f, (-0.43f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.584f), 1.17f, (-0.66f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_1(0i, v_id, 0i, 0i, 0.035f, f_V((v_s * 0.584f), 1.17f, (-0.66f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.645f), 1.05f, (-0.9f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.71f), 0.9f, (-1.11f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.75f), 0.81f, (-1.34f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_3(0i, v_id, 7i, 0i, 0.01f, f_V((v_s * 0.73f), 0.804f, 0.78f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.732f), 0.804f, (-1.15f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      continuing {
        v_si += i32(1);
      }
    }
  }
  f_cw_buffer_helper_0(0i, v_id, 6i, 6i, 0i, 64i, 40i, v_S, v_O, v_O, 0.0f, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_0(0i, v_id, 7i, 0i, 0i, 56i, 40i, v_S, v_O, v_O, 0.0f, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_0(0i, v_id, 8i, 6i, 0i, 56i, 40i, v_S, v_O, v_O, 0.0f, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_0(0i, v_id, 13i, 0i, 0i, 128i, 24i, v_S, v_O, v_O, 0.0f, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_0(0i, v_id, 14i, 0i, 0i, 100i, 24i, v_S, v_O, v_O, 0.0f, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_2(0i, v_id, 1i, 0i, f_V(0.92f, 0.02f, 0.16f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.186f, 2.16f, cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_2(0i, v_id, 1i, 0i, f_V(0.9f, 0.024f, 0.2f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.185f, (-2.08f), cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_2(0i, v_id, 7i, 0i, f_V(0.6f, 0.1f, 0.03f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.409f, 2.199f, cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_2(0i, v_id, 7i, 0i, f_V(0.63f, 0.09f, 0.04f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.39f, (-2.196f), cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  {
    var v_j: i32 = 0i;
    loop {
      if (!(v_j < 32i)) { break; }
      f_cw_buffer_helper_2(0i, v_id, 7i, 0i, f_V(0.004f, 0.083f, 0.008f, cw_thread, cw_block, cw_grid), f_V(((-0.58f) + (f32(v_j) * 0.0375f)), 0.409f, 2.236f, cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      continuing {
        v_j += i32(1);
      }
    }
  }
  {
    var v_j: i32 = 0i;
    loop {
      if (!(v_j < 4i)) { break; }
      f_cw_buffer_helper_2(0i, v_id, 7i, 0i, f_V(0.579f, 0.0025f, 0.007f, cw_thread, cw_block, cw_grid), f_V(0.0f, (0.34f + (f32(v_j) * 0.045f)), 2.241f, cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      continuing {
        v_j += i32(1);
      }
    }
  }
  {
    var v_j: i32 = 0i;
    loop {
      if (!(v_j < 7i)) { break; }
      f_cw_buffer_helper_2(0i, v_id, 1i, 0i, f_V(0.01f, 0.085f, 0.18f, cw_thread, cw_block, cw_grid), f_V(((-0.72f) + (f32(v_j) * 0.24f)), 0.18f, (-2.14f), cw_thread, cw_block, cw_grid), f_V(0.16f, 0.0f, 0.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      continuing {
        v_j += i32(1);
      }
    }
  }
  {
    var v_si: i32 = 0i;
    loop {
      if (!(v_si < 2i)) { break; }
      var cw_tmp_3: f32;
      if ((v_si == 0i)) {
        cw_tmp_3 = (-1.0f);
      } else {
        cw_tmp_3 = 1.0f;
      }
      var v_s: f32 = cw_tmp_3;
      f_cw_buffer_helper_0(0i, v_id, 18i, 14i, 0i, 44i, 24i, v_S, v_O, v_O, v_s, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      {
        var v_l: i32 = 0i;
        loop {
          if (!(v_l < 3i)) { break; }
          var v_x: f32 = (v_s * (0.55f + (0.1f * f32(v_l))));
          var v_y: f32 = (0.624f + (0.012f * f32(v_l)));
          var v_z: f32 = (2.104f - (0.05f * f32(v_l)));
          f_cw_buffer_helper_0(0i, v_id, 30i, 3i, 0i, 24i, 14i, f_V(0.036f, 0.009f, 0.033f, cw_thread, cw_block, cw_grid), f_V(v_x, v_y, v_z, cw_thread, cw_block, cw_grid), v_O, 0.0f, cw_thread, cw_block, cw_grid);
          v_id += i32(1);
          f_cw_buffer_helper_0(0i, v_id, 30i, 8i, 0i, 24i, 14i, f_V(0.02f, 0.005f, 0.019f, cw_thread, cw_block, cw_grid), f_V(v_x, (v_y + 0.006f), (v_z + 0.004f), cw_thread, cw_block, cw_grid), v_O, 0.0f, cw_thread, cw_block, cw_grid);
          v_id += i32(1);
          continuing {
            v_l += i32(1);
          }
        }
      }
      f_cw_buffer_helper_1(0i, v_id, 8i, 0i, 0.005f, f_V((v_s * 0.495f), 0.635f, 2.135f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.63f), 0.655f, 2.1f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.77f), 0.681f, 2.035f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.849f), 0.674f, 1.978f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_1(0i, v_id, 8i, 0i, 0.004f, f_V((v_s * 0.49f), 0.614f, 2.186f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.63f), 0.637f, 2.155f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.76f), 0.652f, 2.091f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.844f), 0.662f, 2.028f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_2(0i, v_id, 14i, 0i, f_V(0.365f, 0.043f, 0.034f, cw_thread, cw_block, cw_grid), f_V((v_s * 0.497f), 0.695f, (-2.148f), cw_thread, cw_block, cw_grid), f_V(0.0f, ((-v_s) * 0.08f), 0.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      {
        var v_j: i32 = 0i;
        loop {
          if (!(v_j < 2i)) { break; }
          f_cw_buffer_helper_1(0i, v_id, 9i, 0i, 0.008f, f_V((v_s * 0.13f), (0.701f + (f32(v_j) * 0.025f)), (-2.191f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.39f), (0.703f + (f32(v_j) * 0.025f)), (-2.199f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.67f), (0.7f + (f32(v_j) * 0.025f)), (-2.187f), cw_thread, cw_block, cw_grid), f_V((v_s * 0.848f), (0.676f + (f32(v_j) * 0.025f)), (-2.129f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
          v_id += i32(1);
          continuing {
            v_j += i32(1);
          }
        }
      }
      {
        var v_ex: i32 = 0i;
        loop {
          if (!(v_ex < 2i)) { break; }
          var v_x: f32 = (v_s * (0.61f + (f32(v_ex) * 0.12f)));
          f_cw_buffer_helper_0(0i, v_id, 32i, 13i, 0i, 48i, 12i, f_V(0.043f, 0.034f, 0.043f, cw_thread, cw_block, cw_grid), f_V(v_x, 0.273f, (-2.246f), cw_thread, cw_block, cw_grid), f_V(0.0f, (3.141592653589793f * 0.5f), 0.0f, cw_thread, cw_block, cw_grid), 0.011f, cw_thread, cw_block, cw_grid);
          v_id += i32(1);
          f_cw_buffer_helper_0(0i, v_id, 34i, 7i, 0i, 36i, 6i, f_V(0.039f, 0.039f, 0.039f, cw_thread, cw_block, cw_grid), f_V(v_x, 0.273f, (-2.239f), cw_thread, cw_block, cw_grid), f_V(0.0f, (3.141592653589793f * 0.5f), 0.0f, cw_thread, cw_block, cw_grid), 0.0f, cw_thread, cw_block, cw_grid);
          v_id += i32(1);
          continuing {
            v_ex += i32(1);
          }
        }
      }
      continuing {
        v_si += i32(1);
      }
    }
  }
  {
    var v_j: i32 = 0i;
    loop {
      if (!(v_j < 8i)) { break; }
      f_cw_buffer_helper_2(0i, v_id, 7i, 0i, f_V(0.455f, 0.007f, 0.019f, cw_thread, cw_block, cw_grid), f_V(0.0f, (0.836f - (f32(v_j) * 0.012f)), ((-1.44f) - (f32(v_j) * 0.055f)), cw_thread, cw_block, cw_grid), f_V((-0.1f), 0.0f, 0.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      continuing {
        v_j += i32(1);
      }
    }
  }
  f_cw_buffer_helper_0(0i, v_id, 17i, 0i, 0i, 64i, 16i, v_S, v_O, v_O, 0.0f, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_2(0i, v_id, 7i, 0i, f_V(0.7f, 0.09f, 1.1f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.245f, (-0.1f), cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  {
    var v_si: i32 = 0i;
    loop {
      if (!(v_si < 2i)) { break; }
      var cw_tmp_4: f32;
      if ((v_si == 0i)) {
        cw_tmp_4 = (-0.355f);
      } else {
        cw_tmp_4 = 0.355f;
      }
      var v_x: f32 = cw_tmp_4;
      f_cw_buffer_helper_0(0i, v_id, 37i, 10i, 0i, 36i, 40i, f_V(0.235f, 0.48f, 0.49f, cw_thread, cw_block, cw_grid), f_V(v_x, 0.3f, (-0.22f), cw_thread, cw_block, cw_grid), v_O, 0.0f, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      {
        var v_b: i32 = 0i;
        loop {
          if (!(v_b < 2i)) { break; }
          var cw_tmp_5: f32;
          if ((v_b == 0i)) {
            cw_tmp_5 = (-1.0f);
          } else {
            cw_tmp_5 = 1.0f;
          }
          var v_s: f32 = cw_tmp_5;
          f_cw_buffer_helper_0(0i, v_id, 30i, 10i, 0i, 28i, 24i, f_V(0.056f, 0.2f, 0.155f, cw_thread, cw_block, cw_grid), f_V((v_x + (v_s * 0.18f)), 0.635f, (-0.385f), cw_thread, cw_block, cw_grid), f_V((-0.23f), 0.0f, 0.0f, cw_thread, cw_block, cw_grid), 0.0f, cw_thread, cw_block, cw_grid);
          v_id += i32(1);
          f_cw_buffer_helper_1(0i, v_id, 11i, 0i, 0.0024f, f_V((v_x + (v_s * 0.163f)), 0.365f, 0.02f, cw_thread, cw_block, cw_grid), f_V((v_x + (v_s * 0.174f)), 0.45f, (-0.2f), cw_thread, cw_block, cw_grid), f_V((v_x + (v_s * 0.173f)), 0.72f, (-0.49f), cw_thread, cw_block, cw_grid), f_V((v_x + (v_s * 0.122f)), 0.87f, (-0.55f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
          v_id += i32(1);
          continuing {
            v_b += i32(1);
          }
        }
      }
      f_cw_buffer_helper_2(0i, v_id, 10i, 0i, f_V(0.145f, 0.123f, 0.081f, cw_thread, cw_block, cw_grid), f_V(v_x, 0.872f, (-0.556f), cw_thread, cw_block, cw_grid), f_V((-0.17f), 0.0f, 0.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_3(0i, v_id, 7i, 0i, 0.012f, f_V((v_x + 0.17f), 0.79f, (-0.59f), cw_thread, cw_block, cw_grid), f_V((v_x - 0.12f), 0.39f, (-0.2f), cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      continuing {
        v_si += i32(1);
      }
    }
  }
  f_cw_buffer_helper_2(0i, v_id, 10i, 0i, f_V(0.685f, 0.077f, 0.199f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.721f, 0.579f, cw_thread, cw_block, cw_grid), f_V((-0.055f), 0.0f, 0.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_1(0i, v_id, 11i, 0i, 0.003f, f_V((-0.63f), 0.78f, 0.433f, cw_thread, cw_block, cw_grid), f_V((-0.32f), 0.803f, 0.402f, cw_thread, cw_block, cw_grid), f_V(0.32f, 0.803f, 0.402f, cw_thread, cw_block, cw_grid), f_V(0.63f, 0.78f, 0.433f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_2(0i, v_id, 1i, 0i, f_V(0.102f, 0.116f, 0.42f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.422f, 0.035f, cw_thread, cw_block, cw_grid), f_V((-0.06f), 0.0f, 0.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_2(0i, v_id, 12i, 0i, f_V(0.12f, 0.065f, 0.006f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.739f, 0.376f, cw_thread, cw_block, cw_grid), f_V((-0.09f), 0.0f, 0.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_2(0i, v_id, 12i, 0i, f_V(0.16f, 0.067f, 0.006f, cw_thread, cw_block, cw_grid), f_V((-0.345f), 0.763f, 0.389f, cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_0(0i, v_id, 32i, 10i, 5i, 64i, 16i, f_V(0.142f, 0.142f, 0.142f, cw_thread, cw_block, cw_grid), f_V((-0.345f), 0.69f, 0.205f, cw_thread, cw_block, cw_grid), f_V(0.0f, (3.141592653589793f * 0.5f), 0.0f, cw_thread, cw_block, cw_grid), 0.022f, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_2(0i, v_id, 7i, 5i, f_V(0.088f, 0.037f, 0.024f, cw_thread, cw_block, cw_grid), f_V((-0.345f), 0.682f, 0.205f, cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  {
    var v_q: i32 = 0i;
    loop {
      if (!(v_q < 3i)) { break; }
      var v_a: f32 = (f32(v_q) * 2.094f);
      f_cw_buffer_helper_3(0i, v_id, 3i, 5i, 0.008f, f_V((-0.345f), 0.68f, 0.205f, cw_thread, cw_block, cw_grid), f_V(((-0.345f) + (sin(v_a) * 0.119f)), (0.69f + (cos(v_a) * 0.119f)), 0.205f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      continuing {
        v_q += i32(1);
      }
    }
  }
  {
    var v_j: i32 = 0i;
    loop {
      if (!(v_j < 5i)) { break; }
      f_cw_buffer_helper_0(0i, v_id, 30i, 3i, 0i, 16i, 10i, f_V(0.012f, 0.006f, 0.012f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.537f, (0.12f - (f32(v_j) * 0.05f)), cw_thread, cw_block, cw_grid), v_O, 0.0f, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      continuing {
        v_j += i32(1);
      }
    }
  }
  {
    var v_w: i32 = 0i;
    loop {
      if (!(v_w < 2i)) { break; }
      var cw_tmp_6: f32;
      if ((v_w == 0i)) {
        cw_tmp_6 = (-0.38f);
      } else {
        cw_tmp_6 = 0.22f;
      }
      var v_x: f32 = cw_tmp_6;
      f_cw_buffer_helper_3(0i, v_id, 7i, 0i, 0.005f, f_V((v_x - 0.15f), 0.823f, 0.826f, cw_thread, cw_block, cw_grid), f_V((v_x + 0.23f), 0.842f, 0.8f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      continuing {
        v_w += i32(1);
      }
    }
  }
  {
    var v_w: i32 = 0i;
    loop {
      if (!(v_w < 4i)) { break; }
      var cw_tmp_7: f32;
      if (((v_w % 2i) == 0i)) {
        cw_tmp_7 = (-1.0f);
      } else {
        cw_tmp_7 = 1.0f;
      }
      var v_side: f32 = cw_tmp_7;
      var cw_tmp_8: f32;
      if ((v_w < 2i)) {
        cw_tmp_8 = 1.34f;
      } else {
        cw_tmp_8 = (-1.34f);
      }
      var v_z: f32 = cw_tmp_8;
      var cw_tmp_9: f32;
      if ((v_w < 2i)) {
        cw_tmp_9 = 0.24f;
      } else {
        cw_tmp_9 = 0.282f;
      }
      var v_width: f32 = cw_tmp_9;
      var v_centre: vec3<f32> = f_V((v_side * 0.852f), 0.345f, v_z, cw_thread, cw_block, cw_grid);
      var v_tag: i32 = (v_w + 1i);
      f_cw_buffer_helper_0(0i, v_id, 39i, 2i, v_tag, 128i, 32i, f_V(v_width, 0.337f, 0.337f, cw_thread, cw_block, cw_grid), v_centre, v_O, v_side, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_0(0i, v_id, 33i, 3i, v_tag, 96i, 8i, f_V((v_width * 0.4f), 0.241f, 0.241f, cw_thread, cw_block, cw_grid), v_centre, v_O, 0.0f, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      {
        var v_f: i32 = 0i;
        loop {
          if (!(v_f < 2i)) { break; }
          var cw_tmp_10: f32;
          if ((v_f == 0i)) {
            cw_tmp_10 = (v_width * 0.42f);
          } else {
            cw_tmp_10 = ((-v_width) * 0.3f);
          }
          var v_x: f32 = (v_centre.x + (v_side * cw_tmp_10));
          f_cw_buffer_helper_0(0i, v_id, 32i, 3i, v_tag, 96i, 12i, f_V(0.237f, 0.237f, 0.237f, cw_thread, cw_block, cw_grid), f_V(v_x, 0.345f, v_z, cw_thread, cw_block, cw_grid), v_O, 0.009f, cw_thread, cw_block, cw_grid);
          v_id += i32(1);
          continuing {
            v_f += i32(1);
          }
        }
      }
      f_cw_buffer_helper_0(0i, v_id, 34i, 4i, v_tag, 96i, 16i, f_V(0.195f, 0.195f, 0.195f, cw_thread, cw_block, cw_grid), f_V((v_centre.x + (v_side * 0.045f)), 0.345f, v_z, cw_thread, cw_block, cw_grid), v_O, 0.0f, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_0(0i, v_id, 33i, 7i, v_tag, 48i, 8i, f_V(0.055f, 0.069f, 0.069f, cw_thread, cw_block, cw_grid), v_centre, v_O, 0.0f, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_0(0i, v_id, 34i, 3i, v_tag, 48i, 8i, f_V(0.058f, 0.058f, 0.058f, cw_thread, cw_block, cw_grid), f_V((v_centre.x + (v_side * ((v_width * 0.43f) + 0.004f))), 0.345f, v_z, cw_thread, cw_block, cw_grid), v_O, 0.0f, cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      {
        var v_k: i32 = 0i;
        loop {
          if (!(v_k < 10i)) { break; }
          var cw_tmp_11: f32;
          if (((v_k % 2i) == 0i)) {
            cw_tmp_11 = (-0.092f);
          } else {
            cw_tmp_11 = 0.092f;
          }
          var v_a: f32 = ((f32((v_k / 2i)) * cw_divide_f32((2.0f * 3.141592653589793f), 5.0f)) + cw_tmp_11);
          f_cw_buffer_helper_0(0i, v_id, 38i, 3i, v_tag, 24i, 12i, f_V(0.03f, 0.03f, 0.03f, cw_thread, cw_block, cw_grid), v_centre, v_O, v_side, cw_thread, cw_block, cw_grid);
          b_parts[((v_id * 10i) + 4i)] = vec4<f32>(v_a, v_width, 0.0f, 0.0f);
          v_id += i32(1);
          continuing {
            v_k += i32(1);
          }
        }
      }
      {
        var v_k: i32 = 0i;
        loop {
          if (!(v_k < 5i)) { break; }
          var v_a: f32 = cw_divide_f32(((f32(v_k) * 2.0f) * 3.141592653589793f), 5.0f);
          f_cw_buffer_helper_0(0i, v_id, 33i, 13i, v_tag, 12i, 2i, f_V(0.01f, 0.008f, 0.008f, cw_thread, cw_block, cw_grid), f_V((v_centre.x + ((v_side * v_width) * 0.46f)), (0.345f + (cos(v_a) * 0.043f)), (v_z + (sin(v_a) * 0.043f)), cw_thread, cw_block, cw_grid), v_O, 0.0f, cw_thread, cw_block, cw_grid);
          v_id += i32(1);
          continuing {
            v_k += i32(1);
          }
        }
      }
      f_cw_buffer_helper_2(0i, v_id, 5i, (v_w + 6i), f_V(0.047f, 0.106f, 0.041f, cw_thread, cw_block, cw_grid), f_V((v_centre.x + (v_side * 0.045f)), 0.383f, (v_z - 0.163f), cw_thread, cw_block, cw_grid), f_V(0.26f, 0.0f, 0.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_3(0i, v_id, 7i, 0i, 0.014f, f_V((v_side * 0.46f), 0.36f, (v_z - 0.17f), cw_thread, cw_block, cw_grid), f_V((v_side * 0.79f), 0.36f, v_z, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      f_cw_buffer_helper_3(0i, v_id, 7i, 0i, 0.014f, f_V((v_side * 0.46f), 0.36f, (v_z + 0.17f), cw_thread, cw_block, cw_grid), f_V((v_side * 0.79f), 0.36f, v_z, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
      v_id += i32(1);
      continuing {
        v_w += i32(1);
      }
    }
  }
  f_cw_buffer_helper_2(0i, v_id, 16i, 0i, f_V(0.032f, 0.002f, 0.04f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.626f, 2.023f, cw_thread, cw_block, cw_grid), f_V(0.12f, 0.0f, 0.0f, cw_thread, cw_block, cw_grid), cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  f_cw_buffer_helper_2(0i, v_id, 16i, 0i, f_V(0.185f, 0.041f, 0.003f, cw_thread, cw_block, cw_grid), f_V(0.0f, 0.535f, (-2.234f), cw_thread, cw_block, cw_grid), v_O, cw_thread, cw_block, cw_grid);
  v_id += i32(1);
  b_count[0i] = u32(v_id);
}
