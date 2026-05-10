<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'

const props = defineProps({
  src: { type: String, required: true },
})

const canvas = ref(null)
const loading = ref(true)
const error = ref(null)
const running = ref(false)

let gl = null
let program = null
let animId = null
let startTime = 0
let lastW = 0
let lastH = 0

const VERTEX_SRC = `
  attribute vec2 a_position;
  void main() {
    gl_Position = vec4(a_position, 0.0, 1.0);
  }
`

function compileShader(type, src) {
  const shader = gl.createShader(type)
  gl.shaderSource(shader, src)
  gl.compileShader(shader)
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    console.error(gl.getShaderInfoLog(shader))
    gl.deleteShader(shader)
    return null
  }
  return shader
}

async function init() {
  loading.value = true
  error.value = null
  running.value = false
  cancelAnimationFrame(animId)

  let fragSrc
  try {
    const res = await fetch(props.src)
    if (!res.ok) throw new Error(res.statusText)
    fragSrc = await res.text()
  } catch {
    error.value = 'Shader konnte nicht geladen werden.'
    loading.value = false
    return
  }

  gl = canvas.value.getContext('webgl')
  if (!gl) {
    error.value = 'WebGL wird von diesem Browser nicht unterstützt.'
    loading.value = false
    return
  }

  const vs = compileShader(gl.VERTEX_SHADER, VERTEX_SRC)
  const fs = compileShader(gl.FRAGMENT_SHADER, fragSrc)
  if (!vs || !fs) {
    error.value = 'Shader-Kompilierung fehlgeschlagen.'
    loading.value = false
    return
  }

  program = gl.createProgram()
  gl.attachShader(program, vs)
  gl.attachShader(program, fs)
  gl.linkProgram(program)
  gl.deleteShader(vs)
  gl.deleteShader(fs)

  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    error.value = 'Shader-Linking fehlgeschlagen.'
    loading.value = false
    return
  }

  gl.useProgram(program)

  const buf = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, buf)
  gl.bufferData(
    gl.ARRAY_BUFFER,
    new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]),
    gl.STATIC_DRAW,
  )
  const pos = gl.getAttribLocation(program, 'a_position')
  gl.enableVertexAttribArray(pos)
  gl.vertexAttribPointer(pos, 2, gl.FLOAT, false, 0, 0)

  loading.value = false
  startTime = performance.now()
  running.value = true
  lastW = 0
  lastH = 0
  render()
}

function render() {
  if (!running.value || !canvas.value || !gl || !program) return

  const w = canvas.value.clientWidth
  const h = canvas.value.clientHeight
  if (w !== lastW || h !== lastH) {
    canvas.value.width = w
    canvas.value.height = h
    gl.viewport(0, 0, w, h)
    lastW = w
    lastH = h
  }

  gl.uniform2f(gl.getUniformLocation(program, 'u_resolution'), w, h)
  gl.uniform1f(
    gl.getUniformLocation(program, 'u_time'),
    (performance.now() - startTime) / 1000,
  )
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)

  animId = requestAnimationFrame(render)
}

function togglePlay() {
  if (running.value) {
    running.value = false
    cancelAnimationFrame(animId)
  } else {
    running.value = true
    render()
  }
}

onMounted(init)
onUnmounted(() => {
  running.value = false
  cancelAnimationFrame(animId)
})
watch(() => props.src, init)
</script>

<template>
  <div
    class="relative rounded-xl overflow-hidden bg-slate-900 border border-slate-800"
    style="aspect-ratio: 16/9"
  >
    <canvas ref="canvas" class="w-full h-full block" />

    <!-- Loading -->
    <div
      v-if="loading"
      class="absolute inset-0 flex items-center justify-center"
    >
      <div class="w-8 h-8 border-2 border-sky-400 border-t-transparent rounded-full animate-spin" />
    </div>

    <!-- Error -->
    <div
      v-else-if="error"
      class="absolute inset-0 flex items-center justify-center text-slate-500 text-sm px-6 text-center"
    >
      {{ error }}
    </div>

    <!-- Controls -->
    <div v-else class="absolute bottom-3 right-3">
      <button
        @click="togglePlay"
        class="flex items-center gap-1.5 px-3 py-1.5 bg-slate-950/70 backdrop-blur-sm text-slate-300 hover:text-sky-400 rounded-lg text-xs transition-colors border border-slate-700/50"
      >
        <!-- Pause icon -->
        <svg v-if="running" class="w-3 h-3" fill="currentColor" viewBox="0 0 24 24">
          <path d="M6 4h4v16H6V4zm8 0h4v16h-4V4z" />
        </svg>
        <!-- Play icon -->
        <svg v-else class="w-3 h-3" fill="currentColor" viewBox="0 0 24 24">
          <path d="M8 5v14l11-7z" />
        </svg>
        {{ running ? 'Pause' : 'Play' }}
      </button>
    </div>
  </div>
</template>
