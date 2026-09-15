// Original reduced four-contact vehicle dynamics, all on GPU.
// State is 16 float4 (256 bytes). Fixed 120 Hz steps. Not calibrated vehicle data.
#define PI 3.14159265358979323846f
__device__ float cf(float x,float lo,float hi){return fminf(fmaxf(x,lo),hi);}
__device__ float sg(float x){return x<0.0f?-1.0f:1.0f;}
__device__ float approach(float a,float b,float speed,float dt){return a+cf(b-a,-speed*dt,speed*dt);}
__device__ float ratio(int g){if(g<0)return -2.9f;if(g==1)return 3.10f;if(g==2)return 2.15f;if(g==3)return 1.65f;if(g==4)return 1.31f;if(g==5)return 1.05f;if(g==6)return .85f;return .69f;}
__device__ float roadDist(const float4* road,unsigned int count,float x,float z){float best=100000000.0f;for(unsigned int i=0u;i<count;i++){unsigned int j=i+1u;if(j==count)j=0u;float4 a=road[i],b=road[j];float dx=b.x-a.x,dz=b.z-a.z,t=cf(((x-a.x)*dx+(z-a.z)*dz)/fmaxf(dx*dx+dz*dz,.001f),0.0f,1.0f);float ex=x-a.x-t*dx,ez=z-a.z-t*dz;best=fminf(best,ex*ex+ez*ez);}return sqrtf(best);}
__global__ void resetVehicle(float4* state,float4* smoke,float4* smokeVelocity,float4* marks,unsigned int smokeCount,unsigned int markCount,float x,float z,float yaw){unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i<16u)state[i]=make_float4(0.0f,0.0f,0.0f,0.0f);if(i==0u)state[0]=make_float4(x,.009f,z,yaw);if(i==2u)state[2]=make_float4(950.0f,1.0f,0.0f,0.0f);if(i<smokeCount){smoke[i]=make_float4(0.0f,-20.0f,0.0f,0.0f);smokeVelocity[i]=make_float4(0.0f,0.0f,0.0f,0.0f);}if(i<markCount*2u)marks[i]=make_float4(0.0f,-20.0f,0.0f,0.0f);}
// Prepare a fixed step. Control, drivetrain and road classification are separate
// from the four independent tyre lanes and the final rigid-body integration.
__global__ void stepVehicle(float4* state,const float4* road,unsigned int roadCount,float dt,float drive,float brake,float steering,float handbrake,unsigned int automatic,int shift,float wetness,unsigned int showroom){
 if(threadIdx.x!=0u||blockIdx.x!=0u)return;
 float4 p=state[0],vel=state[1],engine=state[2],ctrl=state[5];
 float sn=sinf(p.w),cs=cosf(p.w),u=cs*vel.x-sn*vel.z,v=sn*vel.x+cs*vel.z,speed=sqrtf(u*u+v*v);
 float off=roadDist(road,roadCount,p.x,p.z)>7.4f?1.0f:0.0f;
 int gear=(int)engine.y;float throttle=0.0f,braking=brake;
 if(drive<-.01f){if(v>.55f)braking=fmaxf(braking,-drive);else{gear=-1;throttle=-drive;}}
 if(drive>.01f){if(v<-.55f)braking=fmaxf(braking,drive);else{gear=gear<1?1:gear;throttle=drive;}}
 if(showroom!=0u){throttle=0.0f;braking=1.0f;}
 ctrl.y=approach(ctrl.y,throttle,3.2f,dt);ctrl.z=approach(ctrl.z,braking,6.0f,dt);ctrl.w=handbrake;
 // Preserve useful steering authority at speed; tyre forces and ESC manage
 // saturation. A practical minimum lock avoids an unresponsive high-speed wheel.
 float rawLock=.50f/(1.0f+speed*.024f);
 float cornerGrip=(off>.5f?.52f:1.65f)*(1.0f-wetness*.34f)*9.81f;
 float roadLock=fmaxf(.10f,atan2f(cornerGrip*2.68f*1.15f,fmaxf(speed*speed,1.0f)));
 float lock=handbrake>.1f?rawLock:fminf(rawLock,roadLock);
 ctrl.x=approach(ctrl.x,steering*lock,1.95f/(1.0f+speed*.014f),dt);
 engine.z=fmaxf(0.0f,engine.z-dt);float gr=ratio(gear);
 float rpm=fmaxf(950.0f,fabsf(v)/.337f*fabsf(gr)*3.35f*9.549297f);
 rpm=fmaxf(rpm,950.0f+ctrl.y*1700.0f*(1.0f-cf(fabsf(v)/8.0f,0.0f,1.0f)));
 if(automatic!=0u&&gear>0&&engine.z==0.0f){if(rpm>7500.0f&&gear<7){gear++;engine.z=.17f;}else if(rpm<2600.0f&&gear>1){gear--;engine.z=.13f;}}
 if(automatic==0u&&shift!=0){gear=(int)cf((float)(gear+shift),1.0f,7.0f);engine.z=.16f;}
 gr=ratio(gear);float rr=(rpm-5600.0f)/3500.0f,torque=640.0f*(.59f+.41f*expf(-rr*rr));
 float demand=torque*gr*3.35f*.9f/.337f*ctrl.y*(engine.z>0.0f?.16f:1.0f)*(rpm>8150.0f?.15f:1.0f);
 engine.x=approach(engine.x,rpm,9500.0f,dt);engine.y=(float)gear;
 state[2]=engine;state[5]=ctrl;state[12]=make_float4(demand,(off>.5f?.52f:1.65f)*(1.0f-wetness*.34f),off,showroom!=0u?0.0f:1.0f);state[13]=make_float4(u,v,speed,vel.w);
}
__global__ void tireForces(float4* state,float4* forces,float dt,unsigned int tractionControl){
 unsigned int w=threadIdx.x+blockIdx.x*blockDim.x;if(w>=4u)return;
 float4 ctrl=state[5],par=state[12],motion=state[13],old=state[10];
 float wx=w%2u==0u?-.852f:.852f,wz=w<2u?1.34f:-1.34f,delta=w<2u?ctrl.x:0.0f;
 float sn=sinf(delta),cs=cosf(delta),lat=motion.x+motion.w*wz,lon=motion.y-motion.w*wx;
 float tl=lat*cs-lon*sn,tv=lat*sn+lon*cs;
 float load=1490.0f*9.81f*.25f-(w<2u?1.0f:-1.0f)*1490.0f*old.y*.42f/5.36f-(wx<0.0f?-1.0f:1.0f)*1490.0f*old.x*.42f/3.408f;
 load=cf(load,1490.0f*9.81f*.09f,1490.0f*9.81f*.46f)+.28f*motion.z*motion.z;
 float grip=par.y*load,alpha=atan2f(tl,fmaxf(fabsf(tv),3.5f));
 float lateral=-40000.0f*alpha*(w<2u?1.0f:1.12f)*(w<2u?1.0f:1.0f-ctrl.w*.78f);
 float longitudinal=w>=2u?par.x*.5f:0.0f;
 float braking=fminf(fabsf(tv)*1490.0f/(4.0f*dt),ctrl.z*grip*.96f+(w>=2u?ctrl.w*grip*1.1f:0.0f));longitudinal-=sg(tv)*braking;
 float requested=sqrtf(lateral*lateral+longitudinal*longitudinal),slip=fmaxf(0.0f,requested/fmaxf(grip,1.0f)-1.0f);
 if(tractionControl!=0u&&w>=2u&&ctrl.y>.1f)longitudinal=cf(longitudinal,-grip*.92f,grip*.92f);
 float amount=sqrtf(lateral*lateral+longitudinal*longitudinal),limit=fminf(1.0f,grip/fmaxf(amount,1.0f));lateral*=limit;longitudinal*=limit;
 float fx=lateral*cs+longitudinal*sn,fz=-lateral*sn+longitudinal*cs;
 float4 wheel=state[6u+w];float target=tv/.337f;
 if(w>=2u){target+=(tractionControl!=0u?fminf(slip,.12f):fminf(slip,1.4f))*ctrl.y*sg(par.x)*28.0f;target*=1.0f-ctrl.w*.93f;}
 wheel.y=approach(wheel.y,target,230.0f,dt)*par.w;wheel.x+=wheel.y*dt;wheel.x-=floorf(wheel.x/(2.0f*PI))*2.0f*PI;wheel.z=cf(fabsf(tl)*.13f+slip*.18f,0.0f,1.0f);wheel.w=alpha;
 state[6u+w]=wheel;forces[w]=make_float4(fx,fz,wz*fx-wx*fz,wheel.z);
}
__global__ void integrateVehicle(float4* state,const float4* forces,const float4* obstacles,float4* marks,unsigned int obstacleCount,unsigned int markCount,float dt,unsigned int stabilityControl){
 if(threadIdx.x!=0u||blockIdx.x!=0u)return;
 float4 p=state[0],vel=state[1],att=state[3],av=state[4],ctrl=state[5],par=state[12],motion=state[13],e=state[2];
 float4 a=forces[0],b=forces[1],c=forces[2],d=forces[3];float fx=a.x+b.x+c.x+d.x,fz=a.y+b.y+c.y+d.y,m=a.z+b.z+c.z+d.z;
 float u=motion.x,v=motion.y,speed=motion.z,sn=sinf(p.w),cs=cosf(p.w);
 fz-=.39f*v*fabsf(v)+sg(v)*fminf(fabsf(v)*120.0f,220.0f)*(par.z>.5f?3.0f:1.0f);fz-=ctrl.y<.03f?v*28.0f:0.0f;fx-=u*(par.z>.5f?190.0f:35.0f);
 // Align yaw with the steered path and damp sideslip. Positive local lateral
 // velocity needs positive yaw correction, not the destabilizing opposite sign.
 if(stabilityControl!=0u&&ctrl.w<.1f){
  float targetYaw=v*sinf(ctrl.x)/fmaxf(cosf(ctrl.x)*2.68f,.5f);
  float yawLimit=par.y*9.81f/fmaxf(fabsf(v),3.5f);
  targetYaw=cf(targetYaw,-yawLimit,yawLimit);
  m+=cf((targetYaw-vel.w)*1800.0f+u*fabsf(v)*100.0f,-6500.0f,6500.0f);
 }
 float ax=fx/1490.0f,az=fz/1490.0f;
 vel.x+=(cs*ax+sn*az)*dt;vel.z+=(-sn*ax+cs*az)*dt;vel.w=cf(vel.w+m/2180.0f*dt,-2.7f,2.7f);
 if(par.w<.5f||(speed<.08f&&ctrl.y<.03f)){vel.x=0.0f;vel.z=0.0f;vel.w=0.0f;}
 p.x+=vel.x*dt;p.z+=vel.z*dt;p.w+=vel.w*dt;p.w-=floorf((p.w+PI)/(2.0f*PI))*2.0f*PI;
 float impact=0.0f;
 for(unsigned int j=0u;j<obstacleCount;j++){float4 ob=obstacles[j];float dx=p.x-ob.x,dz=p.z-ob.z,dist=sqrtf(dx*dx+dz*dz),rr=ob.w+1.02f;
 if(dist<rr){float nx=dx/fmaxf(dist,.001f),nz=dz/fmaxf(dist,.001f),vn=fminf(0.0f,vel.x*nx+vel.z*nz);p.x=ob.x+nx*rr;p.z=ob.z+nz*rr;vel.x-=1.12f*vn*nx;vel.z-=1.12f*vn*nz;impact=fmaxf(impact,-vn);}}
 p.x=cf(p.x,-440.0f,440.0f);p.z=cf(p.z,-500.0f,500.0f);if(fabsf(p.x)>=440.0f||fabsf(p.z)>=500.0f){vel.x*=.90f;vel.z*=.90f;}
 float pitch=cf(-az*.0035f,-.042f,.042f),roll=cf(-ax*.006f,-.064f,.064f),heave=(par.z>.5f?.012f:.0015f)*sinf(p.z*3.0f+p.x*1.5f)*fminf(speed*.12f,1.0f);
 av.x+=((heave-att.x)*120.0f-av.x*16.0f)*dt;av.y+=((pitch-att.y)*95.0f-av.y*14.0f)*dt;av.z+=((roll-att.z)*110.0f-av.z*15.0f)*dt;
 att.x+=av.x*dt;att.y+=av.y*dt;att.z+=av.z*dt;att.w+=dt;av.w=cf(av.w+ctrl.z*speed*.055f*dt-(av.w-20.0f)*.03f*dt,20.0f,650.0f);e.w+=speed*dt;
 state[0]=p;state[1]=vel;state[2]=e;state[3]=att;state[4]=av;state[10]=make_float4(ax,az,speed,par.z);state[11]=make_float4(fabsf(par.x)>par.y*7300.0f?1.0f:0.0f,ctrl.z>.5f?1.0f:0.0f,impact,fmaxf(fmaxf(a.w,b.w),fmaxf(c.w,d.w)));
 unsigned int tick=(unsigned int)(att.w/dt);
 for(unsigned int w=0u;w<4u;w++){float slip=forces[w].w;if(speed>.9f&&slip>.2f){unsigned int slot=(tick*4u+w)%markCount;float wx=w%2u==0u?-.852f:.852f,wz=w<2u?1.34f:-1.34f;marks[slot*2u]=make_float4(p.x+cs*wx+sn*wz,.017f,p.z-sn*wx+cs*wz,cf(slip*.6f,.04f,.55f));marks[slot*2u+1u]=make_float4(p.w,.245f,fmaxf(speed*dt,.035f),att.w);}}
}

__device__ float3 rotX(float3 p,float a){float c=cosf(a),s=sinf(a);return make_float3(p.x,c*p.y-s*p.z,s*p.y+c*p.z);}
__device__ float3 rotY(float3 p,float a){float c=cosf(a),s=sinf(a);return make_float3(c*p.x+s*p.z,p.y,-s*p.x+c*p.z);}
__device__ float3 rotZ(float3 p,float a){float c=cosf(a),s=sinf(a);return make_float3(c*p.x-s*p.y,s*p.x+c*p.y,p.z);}
__device__ float3 localTransform(const float4* state,float3 p,int tag){
 if(tag==5){p.x+=.345f;p.y-=.69f;p.z-=.205f;p=rotZ(p,-state[5].x*4.8f);p.x-=.345f;p.y+=.69f;p.z+=.205f;}
 if(tag==0||tag==5){p.y-=.345f;p=rotZ(rotX(p,state[3].y),state[3].z);p.y+=.345f+state[3].x;}
 else{int w=tag>=6?tag-6:tag-1;float x=w%2==0?-.852f:.852f,z=w<2?1.34f:-1.34f;p.x-=x;p.y-=.345f;p.z-=z;if(tag<5)p=rotX(p,state[6+w].x);if(w<2)p=rotY(p,state[5].x);p.x+=x;p.y+=.345f;p.z+=z;}
 p=rotY(p,state[0].w);return make_float3(p.x+state[0].x,p.y+state[0].y,p.z+state[0].z);
}
__global__ void buildPose(const float4* state,float4* poses){unsigned int tag=threadIdx.x;if(blockIdx.x!=0u||tag>=10u)return;
 float3 o=localTransform(state,make_float3(0.0f,0.0f,0.0f),(int)tag),x=localTransform(state,make_float3(1.0f,0.0f,0.0f),(int)tag),y=localTransform(state,make_float3(0.0f,1.0f,0.0f),(int)tag),z=localTransform(state,make_float3(0.0f,0.0f,1.0f),(int)tag);
 poses[tag*4u]=make_float4(x.x-o.x,x.y-o.y,x.z-o.z,0.0f);poses[tag*4u+1u]=make_float4(y.x-o.x,y.y-o.y,y.z-o.z,0.0f);poses[tag*4u+2u]=make_float4(z.x-o.x,z.y-o.y,z.z-o.z,0.0f);poses[tag*4u+3u]=make_float4(o.x,o.y,o.z,1.0f);
}
__device__ unsigned int hashFx(unsigned int x){x^=x>>16u;x*=2146121005u;x^=x>>15u;x*=2221713035u;x^=x>>16u;return x;}
__device__ float rf(unsigned int i){return (float)(hashFx(i)&16777215u)/16777216.0f;}
__global__ void updateEffects(const float4* state,float4* smoke,float4* smokeVelocity,unsigned int count,float dt){unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;float4 p=smoke[i],v=smokeVelocity[i],pose=state[0],stats=state[10],traction=state[11];p.w=fmaxf(0.0f,p.w-dt*.55f);
 if(p.w<=0.0f){unsigned int tick=(unsigned int)(state[3].w*120.0f);if((i+tick)%31u==0u&&stats.z>3.0f&&(traction.w>.35f||stats.w>.5f)){float side=i%2u==0u?-1.0f:1.0f,sy=sinf(pose.w),cy=cosf(pose.w);p=make_float4(pose.x+cy*side*.852f-sy*1.34f,.22f,pose.z-sy*side*.852f-cy*1.34f,.6f+rf(i+tick)*.35f);v=make_float4((rf(i+tick+1u)-.5f)*.5f,.2f+rf(i+tick+2u)*.4f,(rf(i+tick+3u)-.5f)*.5f,stats.w);}}
 else{p.x+=v.x*dt;p.y+=v.y*dt;p.z+=v.z*dt;v.y+=.1f*dt;}smoke[i]=p;smokeVelocity[i]=v;
}
