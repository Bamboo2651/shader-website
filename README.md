# shader-website

Three.js の ShaderMaterial を使って、GLSLシェーダーによる波・ノイズ背景を実装する学習リポジトリ。

## 技術スタック

- Vite
- Three.js
- GLSL（vite-plugin-glsl で `.glsl` ファイルを直接 import）

## 環境構築
```bash
cd my-shader-site
npm install
```

## 起動方法
```bash
npm run dev
```

ブラウザで `http://localhost:5173` を開く。

## ファイル構成
```
my-shader-site/
├─ index.html
├─ main.js               # Three.js 初期化・アニメーションループ
├─ vite.config.js        # vite-plugin-glsl の設定
└─ src/
    └─ shader/
        ├─ vertex.glsl   # 頂点シェーダー
        └─ fragment.glsl # フラグメントシェーダー（波ノイズの本体）
```

---

## 学習メモ

### シェーダーの仕組み

GPUは2段階でピクセルを描画する。

1. **頂点シェーダー**：各頂点の位置を計算して `gl_Position` に書く
2. **フラグメントシェーダー**：頂点間を補間した各ピクセルの色を計算して `gl_FragColor` に書く
```
JavaScript → 頂点シェーダー → （ラスタライズ） → フラグメントシェーダー → 画面
```

Three.js の `ShaderMaterial` を使うと、この2つのシェーダーを自分で書ける。

---

### GLSLの文法メモ

JavaScriptと似ているが、以下の点が異なる。

**型宣言が必須**
```glsl
float x = 1.0;   // 小数は必ず .0 をつける
int n = 3;
bool flag = true;
```

**vec型（ベクトル）を多用する**
```glsl
vec2 uv = vec2(0.5, 0.5);   // x, y
vec3 color = vec3(1.0, 0.0, 0.0); // R, G, B（赤）
vec4 col = vec4(color, 1.0);     // R, G, B, A
```

スウィズリングでコンポーネントにアクセスできる。
```glsl
vec3 c = vec3(0.1, 0.4, 0.8);
float r = c.r; // 0.1
float g = c.g; // 0.4
```

**組み込み関数**
```glsl
sin(x)        // サイン
mix(a, b, t)  // aとbをtで線形補間（t=0でa、t=1でb）
abs(x)        // 絶対値
fract(x)      // 小数部分のみ取り出す
```

---

### uniform の渡し方

`uniform` は JavaScript 側から GPU に渡す読み取り専用の変数。毎フレーム更新することで「動き」を作れる。

**GLSL 側で宣言**
```glsl
uniform float uTime;
uniform vec2 uResolution;
```

**JavaScript 側で定義・更新**
```js
const uniforms = {
  uTime: { value: 0 },
  uResolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) }
}

// アニメーションループ内で毎フレーム更新
uniforms.uTime.value += 0.01
```

`ShaderMaterial` に渡すだけで自動的にシェーダーへ届く。
```js
const material = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  uniforms
})
```

---

### 波ノイズの作り方

**基本：sin で波を作る**
```glsl
float wave = sin(uv.x * 6.0 + uTime);
```

- `uv.x * 6.0`：波の周波数（数字が大きいほど細かい波）
- `+ uTime`：時間を加えることで波が横に動く

**sin の値域を 0〜1 に正規化する**

`sin` の出力は `-1〜1` なので、色として使うために `0〜1` に変換する。
```glsl
float wave = sin(uv.x * 6.0 + uTime) * 0.5 + 0.5;
```

**複数の波を重ねてノイズ感を出す**

周波数・速度・方向の異なる波を複数重ねると、自然なゆらぎになる。
```glsl
float wave1 = sin(uv.x * 6.0 + uTime * 0.8) * 0.5 + 0.5;
float wave2 = sin(uv.x * 3.0 - uTime * 0.5 + uv.y * 4.0) * 0.5 + 0.5;
float wave3 = sin(uv.y * 5.0 + uTime * 0.6) * 0.5 + 0.5;

float wave = (wave1 + wave2 + wave3) / 3.0;
```

**色にマッピングする**

`mix()` で2色の間を補間する。
```glsl
vec3 colorA = vec3(0.05, 0.05, 0.15); // 深い紺
vec3 colorB = vec3(0.1, 0.4, 0.8);   // 青
vec3 colorC = vec3(0.4, 0.8, 0.9);   // 水色

vec3 color = mix(colorA, colorB, wave);
color = mix(color, colorC, wave * wave);

gl_FragColor = vec4(color, 1.0);
```

`wave * wave` で波の強い部分だけ水色が強調され、メリハリが出る。