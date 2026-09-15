import {DrivingInput} from './input.js';
import {createTrackData} from './track.js';
import {bindDriving,recordDriving,VEHICLE_ENTRIES} from './simulation.js';
/** Isolated state: diagnostic driving never changes the visible car. */
export async function runDeviceChecks(runtime,source){
 const checks=[],owned=[],k={},record=(name,passed,detail)=>checks.push({name,passed:!!passed,detail});
 const make=(v,label)=>{const r=runtime.createBuffer(v,{label:'Diagnostic / '+label});owned.push(r);return r;};
 const t=createTrackData(),start=performance.now();
 try{
  for(const e of VEHICLE_ENTRIES)k[e]=await runtime.kernel(source,{entry:e,workgroupSize:[e==='stepVehicle'||e==='integrateVehicle'?1:128,1,1]});
  const r={state:make(256,'state'),poses:make(640,'poses'),forces:make(64,'tyre forces'),smoke:make(16*16,'smoke'),smokeVelocity:make(16*16,'smoke velocity'),marks:make(256*32,'skids'),road:make(t.road,'road'),obstacles:make(t.obstacles,'obstacles')};
  const b=bindDriving(k,r,{smokeCount:16,markCount:256,roadCount:t.count,obstacleCount:t.obstacles.length/4});
  const read=()=>runtime.read(r.state,Float32Array);
  const reset=()=>runtime.batch().dispatch(b.init.setScalars(t.spawn),[4]).dispatch(b.pose,[1]).submit();
  const drive=async(steps,values={})=>{const input={drive:0,brake:0,steering:0,handbrake:0,shift:0,...values};for(let n=0;n<steps;n+=8){const batch=runtime.batch();recordDriving(batch,b,input,{automatic:1,tractionControl:1,stabilityControl:1,wetness:0,showroom:0},Math.min(8,steps-n));batch.dispatch(b.pose,[1]).submit();}await runtime.idle();};
  reset();let a=await read();record('Reset state finite and stationary',a.every(Number.isFinite)&&a[8]===950&&a[4]===0&&a[6]===0);
  await drive(180,{drive:1});let fast=await read(),speed=Math.hypot(fast[4],fast[6]);record('CUDA throttle advances position',fast[2]>t.spawn.z+2&&speed>3,{speedMps:speed,z:fast[2]});record('Engine speed and gear respond',fast[8]>1200&&fast[9]>=1);record('Driven wheels rotate',Math.abs(fast[25])+Math.abs(fast[33])>1);record('Driving state remains finite',fast.every(Number.isFinite));
  await drive(100,{drive:0,brake:1});a=await read();record('Braking reduces speed',Math.hypot(a[4],a[6])<speed*.72,{speedMps:Math.hypot(a[4],a[6])});
  reset();await drive(160,{drive:-1});a=await read();record('Reverse gear and reverse motion',a[9]===-1&&a[2]<t.spawn.z-1);
  const input=new DrivingInput({},{},{addEventListener(){},removeEventListener(){},document:{addEventListener(){},removeEventListener(){}}});
  for(const [code,direction] of [['KeyA',1],['KeyD',-1]]){input.clear();input.key({code,target:{tagName:'CANVAS'},preventDefault(){}},true);reset();await drive(180,{drive:1,steering:input.sample([]).steering*.35});a=await read();record(code+' turns toward driver '+(direction===1?'left':'right'),a[3]*direction>.01&&(a[0]-t.spawn.x)*direction>.05,{yaw:a[3],x:a[0]});}input.dispose();
  const p=await runtime.read(r.poses,Float32Array);record('Animated GPU matrices finite and affine',p.every(Number.isFinite)&&p[15]===1&&p[31]===1);const len=Math.hypot(p[0],p[1],p[2]);record('Body transform basis normalized',Math.abs(len-1)<1e-4);
  return {kind:'Actual WebGPU kernel execution; not FPS measurements',device:runtime.describe(),elapsedWallMs:performance.now()-start,passed:checks.filter(c=>c.passed).length,checks};
 }finally{await runtime.idle().catch(()=>{});owned.forEach(r=>runtime.destroyBuffer(r));}
}

export async function runDiagnostics(runtime,sources){const report=await runDeviceChecks(runtime,sources.vehicle);return {...report,results:report.checks,failed:report.checks.length-report.passed};}
