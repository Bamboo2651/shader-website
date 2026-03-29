uniform float uTime;
uniform vec2 uResolution;

varying vec2 vUv;

// Simplex Noise の実装
vec3 mod289(vec3 x){return x-floor(x*(1./289.))*289.;}
vec2 mod289(vec2 x){return x-floor(x*(1./289.))*289.;}
vec3 permute(vec3 x){return mod289(((x*34.)+1.)*x);}

float snoise(vec2 v){
    const vec4 C=vec4(.211324865405187,
        .366025403784439,
        -.577350269189626,
    .024390243902439);
    vec2 i=floor(v+dot(v,C.yy));
    vec2 x0=v-i+dot(i,C.xx);
    vec2 i1=(x0.x>x0.y)?vec2(1.,0.):vec2(0.,1.);
    vec4 x12=x0.xyxy+C.xxzz;
    x12.xy-=i1;
    i=mod289(i);
    vec3 p=permute(permute(i.y+vec3(0.,i1.y,1.))
    +i.x+vec3(0.,i1.x,1.));
    vec3 m=max(.5-vec3(dot(x0,x0),dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)),0.);
    m=m*m;
    m=m*m;
    vec3 x=2.*fract(p*C.www)-1.;
    vec3 h=abs(x)-.5;
    vec3 ox=floor(x+.5);
    vec3 a0=x-ox;
    m*=1.79284291400159-.85373472095314*(a0*a0+h*h);
    vec3 g;
    g.x=a0.x*x0.x+h.x*x0.y;
    g.yz=a0.yz*x12.xz+h.yz*x12.yw;
    return 130.*dot(m,g);
}

void main(){
    vec2 uv=vUv;
    
    // ノイズを大きめのスケールで動かす
    float noise1=snoise(uv*2.5+uTime*.35)*.5+.5;
    float noise2=snoise(uv*5.-uTime*.25+vec2(1.5,.8))*.5+.5;
    float noise3=snoise(uv*1.2+uTime*.15+vec2(3.2,1.4))*.5+.5;
    
    // 合成してコントラストを強める
    float wave=noise1*.5+noise2*.3+noise3*.2;
    wave=pow(wave,1.5);// コントラスト強調
    
    // 色にマッピング（明暗の差を大きく）
    vec3 colorA=vec3(.02,.02,.10);// ほぼ黒に近い紺
    vec3 colorB=vec3(.05,.3,.75);// 青
    vec3 colorC=vec3(.5,.85,1.);// 明るい水色
    
    vec3 color=mix(colorA,colorB,wave);
    color=mix(color,colorC,smoothstep(.4,.9,wave));
    
    gl_FragColor=vec4(color,1.);
}