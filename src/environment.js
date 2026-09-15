import * as THREE from 'three/webgpu';
// Procedural HDR lighting rig, not a photograph of the car.
export function makeEnvironment(mode='studio'){
 const w=1024,h=512,p=new Float32Array(w*h*4),box=(x,y,wx,wy)=>Math.exp(-Math.pow(x/wx,8)-Math.pow(y/wy,8));
 for(let y=0;y<h;y++)for(let x=0;x<w;x++){const phi=(x+.5)/w*Math.PI*2-Math.PI,th=(y+.5)/h*Math.PI,dx=-Math.sin(th)*Math.cos(phi),dy=Math.cos(th),dz=Math.sin(th)*Math.sin(phi);let r,g,b;
 if(mode==='studio'){r=.12;g=.14;b=.16;const top=box(dx+.2,dz-.14,.16,.72)*Math.max(0,dy)*7,left=box(dy-.33,dz+.36,.22,.48)*Math.max(0,-dx)*4,rim=box(dy-.44,dx-.38,.28,.11)*Math.max(0,-dz)*8,fill=box(dy-.18,dx-.16,.45,.72)*Math.max(0,dz)*1.4;r+=top+left*1.08+rim*.79+fill;g+=top+left+rim*.9+fill;b+=top*.99+left*.9+rim+fill;
 }else{const t=Math.max(0,dy),gold=mode==='golden',night=mode==='night';r=(.23+.32*(1-t))*(night?.04:1);g=(.40+.21*(1-t))*(night?.045:1);b=(.70+.11*(1-t))*(night?.075:1);if(dy<0){r=.08;g=.085;b=.075;}const cloud=Math.max(0,Math.sin(dx*8+dz*3)+Math.sin(dz*16+dx*4)*.4-.48)*Math.max(0,dy)*.40;r+=cloud;g+=cloud;b+=cloud;let sun=Math.pow(Math.max(0,(-.45*dx+(gold?.36:.70)*dy+.56*dz)/Math.hypot(.45,gold?.36:.7,.56)),400)*25;if(night)sun*=.015;r+=sun;g+=sun*(gold?.7:.95);b+=sun*(gold?.4:.84);}
 const i=(y*w+x)*4;p[i]=r;p[i+1]=g;p[i+2]=b;p[i+3]=1;}
 const t=new THREE.DataTexture(p,w,h,THREE.RGBAFormat,THREE.FloatType);t.mapping=THREE.EquirectangularReflectionMapping;t.minFilter=t.magFilter=THREE.LinearFilter;t.needsUpdate=true;return t;
}
