import * as THREE from 'three'
import vertexShader from './shader/vertex.glsl'
import fragmentShader from './shader/fragment.glsl'

// シーン・カメラ・レンダラーの初期化
const scene = new THREE.Scene()
const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1)
const renderer = new THREE.WebGLRenderer()
renderer.setSize(window.innerWidth, window.innerHeight)
document.body.appendChild(renderer.domElement)

// uniforms（JSからシェーダーへ渡す変数）
const uniforms = {
  uTime: { value: 0 },
  uResolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
  uMouse: { value: new THREE.Vector2(0.5, 0.5) }
}
// 画面全体を覆う板ポリゴン
const geometry = new THREE.PlaneGeometry(2, 2)
const material = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  uniforms
})
const mesh = new THREE.Mesh(geometry, material)
scene.add(mesh)

// ウィンドウリサイズ対応
window.addEventListener('resize', () => {
  renderer.setSize(window.innerWidth, window.innerHeight)
  uniforms.uResolution.value.set(window.innerWidth, window.innerHeight)
})

// アニメーションループ
function animate() {
  requestAnimationFrame(animate)
  uniforms.uTime.value += 0.01
  renderer.render(scene, camera)
}

//マウス
window.addEventListener('mousemove', (e) => {
  // マウス座標を 0〜1 に正規化（Y軸は反転）
  uniforms.uMouse.value.set(
    e.clientX / window.innerWidth,
    1.0 - e.clientY / window.innerHeight
  )
})
animate()