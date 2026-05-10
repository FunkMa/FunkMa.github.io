<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const scrolled = ref(false)
const menuOpen = ref(false)

const navLinks = [
  { label: 'Über mich', to: '/ueber-mich' },
  { label: 'Projekte', to: '/projekte' },
]

function handleScroll() {
  scrolled.value = window.scrollY > 20
}

onMounted(() => window.addEventListener('scroll', handleScroll))
onUnmounted(() => window.removeEventListener('scroll', handleScroll))
</script>

<template>
  <nav
    :class="[
      'fixed top-0 inset-x-0 z-50 transition-all duration-300',
      scrolled
        ? 'bg-slate-950/90 backdrop-blur-sm border-b border-slate-800'
        : 'bg-transparent',
    ]"
  >
    <div class="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between">
      <RouterLink to="/" class="text-sky-400 font-bold text-xl tracking-tight font-mono">
        Portfolio
      </RouterLink>

      <ul class="hidden md:flex items-center gap-8">
        <li v-for="link in navLinks" :key="link.to">
          <RouterLink
            :to="link.to"
            class="text-sm transition-colors"
            :class="route.path === link.to ? 'text-sky-400' : 'text-slate-400 hover:text-sky-400'"
          >
            {{ link.label }}
          </RouterLink>
        </li>
      </ul>

      <button
        @click="menuOpen = !menuOpen"
        class="md:hidden text-slate-400 hover:text-white transition-colors"
        aria-label="Menü öffnen"
      >
        <svg v-if="!menuOpen" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
        <svg v-else class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>

    <Transition
      enter-active-class="transition-all duration-200 ease-out"
      enter-from-class="opacity-0 -translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition-all duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-2"
    >
      <div v-if="menuOpen" class="md:hidden bg-slate-900 border-b border-slate-800 px-6 py-4">
        <ul class="flex flex-col gap-4">
          <li v-for="link in navLinks" :key="link.to">
            <RouterLink
              :to="link.to"
              @click="menuOpen = false"
              class="transition-colors"
              :class="route.path === link.to ? 'text-sky-400' : 'text-slate-300 hover:text-sky-400'"
            >
              {{ link.label }}
            </RouterLink>
          </li>
        </ul>
      </div>
    </Transition>
  </nav>
</template>
