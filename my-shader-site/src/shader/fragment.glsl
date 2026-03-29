uniform float uTime;
uniform vec2 uResolution;

varying vec2 vUv;

void main(){
    vec2 uv=vUv;
    
    // 波を3層重ねてノイズ感を出す
    float wave1=sin(uv.x*6.+uTime*.8)*.5+.5;
    float wave2=sin(uv.x*3.-uTime*.5+uv.y*4.)*.5+.5;
    float wave3=sin(uv.y*5.+uTime*.6)*.5+.5;
    
    float wave=(wave1+wave2+wave3)/3.;
    
    // 色をグラデーションにマッピング
    vec3 colorA=vec3(.05,.05,.15);// 深い紺
    vec3 colorB=vec3(.1,.4,.8);// 青
    vec3 colorC=vec3(.4,.8,.9);// 水色
    
    vec3 color=mix(colorA,colorB,wave);
    color=mix(color,colorC,wave*wave);
    
    gl_FragColor=vec4(color,1.);
}