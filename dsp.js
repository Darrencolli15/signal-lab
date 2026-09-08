(function(root){
function coefficients(n,lo,hi,fs,type){const m=(n-1)/2;const lp=(f,k)=>k===0?2*f/fs:Math.sin(2*Math.PI*f*k/fs)/(Math.PI*k);let h=Array.from({length:n},(_,i)=>{let k=i-m,v=type==='low'?lp(lo,k):type==='high'?(k===0?1:0)-lp(lo,k):lp(hi,k)-lp(lo,k);return v*(.54-.46*Math.cos(2*Math.PI*i/(n-1)))});const at=type==='low'?0:type==='high'?fs/2:(lo+hi)/2;let re=0,im=0;h.forEach((v,i)=>{re+=v*Math.cos(2*Math.PI*at*i/fs);im-=v*Math.sin(2*Math.PI*at*i/fs)});const gain=Math.hypot(re,im);return h.map(v=>v/gain)}
const q=x=>Math.max(-32768,Math.min(32767,Math.floor(x*32768+.5)));
function process(x,h){let y=new Float32Array(x.length),f=new Float32Array(x.length),qi=Int16Array.from(x,q),qh=h.map(q),clips=0,e=0;for(let i=0;i<x.length;i++){let a=0,b=0;for(let k=0;k<h.length&&k<=i;k++){a+=x[i-k]*h[k];b+=qi[i-k]*qh[k]}let v=Math.floor(b/32768);if(v>32767||v< -32768)clips++;v=Math.max(-32768,Math.min(32767,v));y[i]=a;f[i]=v/32768;e+=(a-f[i])**2}return {y,f,clips,error:Math.sqrt(e/x.length)}}
function magnitude(h,f,fs){let re=0,im=0;h.forEach((v,i)=>{re+=v*Math.cos(2*Math.PI*f*i/fs);im-=v*Math.sin(2*Math.PI*f*i/fs)});return Math.max(-100,20*Math.log10(Math.max(1e-5,Math.hypot(re,im))))}
root.DSP={coefficients,process,q,magnitude};if(typeof module!=='undefined')module.exports=root.DSP;
})(typeof window==='undefined'?globalThis:window);
