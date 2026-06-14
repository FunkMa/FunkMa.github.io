<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { projects } from '@/data/projects.js'
import ShaderViewer from '@/components/ShaderViewer.vue'

const route = useRoute()
const router = useRouter()

const project = computed(() => projects.find((p) => p.slug === route.params.slug))

const activeShader = ref(null)
const imageLoaded = ref(false)
const lightboxOpen = ref(false)

function openLightbox() { lightboxOpen.value = true }
function closeLightbox() { lightboxOpen.value = false }

watch(
  project,
  (p) => {
    activeShader.value = p?.shaders?.[0] ?? null
    imageLoaded.value = false
  },
  { immediate: true },
)
</script>

<template>
  <div class="pt-16 min-h-screen">
    <div v-if="project" class="max-w-3xl mx-auto px-6 py-16">

      <!-- Back -->
      <button
        @click="router.push('/projekte')"
        class="flex items-center gap-2 text-slate-500 hover:text-sky-400 transition-colors text-sm mb-12 group"
      >
        <svg
          class="w-4 h-4 group-hover:-translate-x-0.5 transition-transform"
          fill="none" stroke="currentColor" viewBox="0 0 24 24"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
        Alle Projekte
      </button>

      <!-- Header -->
      <div class="mb-12">
        <p v-if="project.subheading" class="text-sky-400 text-xs font-mono tracking-widest mb-3">
          {{ project.subheading }}
        </p>
        <h1 class="text-4xl font-bold text-slate-100 mb-4">{{ project.title }}</h1>
        <div class="flex gap-3">
          <a
            v-if="project.links?.live"
            :href="project.links.live"
            target="_blank"
            rel="noopener noreferrer"
            class="flex items-center gap-2 px-4 py-2 bg-sky-400 text-slate-950 hover:bg-sky-300 rounded-lg transition-colors text-sm font-semibold"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
            </svg>
            Live ansehen
          </a>
          <a
            v-if="project.links?.github"
            :href="project.links.github"
            target="_blank"
            rel="noopener noreferrer"
            class="flex items-center gap-2 px-4 py-2 border border-slate-700 text-slate-300 hover:border-sky-400 hover:text-sky-400 rounded-lg transition-colors text-sm font-medium"
          >
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 0C5.374 0 0 5.373 0 12c0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z" />
            </svg>
            GitHub
          </a>
        </div>
      </div>

      <!-- Image with loading spinner -->
      <div v-if="project.image" class="mb-12 relative rounded-xl overflow-hidden border border-slate-800 bg-slate-900">
        <div
          v-show="!imageLoaded"
          class="absolute inset-0 flex items-center justify-center"
          style="min-height: 200px"
        >
          <div class="w-8 h-8 border-2 border-sky-400 border-t-transparent rounded-full animate-spin" />
        </div>
        <img
          :src="`/images/${project.image}`"
          :alt="project.title"
          v-show="imageLoaded"
          @load="imageLoaded = true"
          class="w-full"
        >
      </div>

      <!-- NEW STRUCTURE: projects with goals field -->
      <template v-if="project.goals">

        <!-- Projekt & Ziele -->
        <section v-if="project.goals" class="mb-12">
          <h2 class="text-xl font-semibold text-slate-100 mb-4">Projekt &amp; Ziele</h2>
          <p
            v-for="(para, i) in project.goals.trim().split('\n\n')"
            :key="i"
            class="text-slate-300 leading-relaxed mb-4 last:mb-0"
          >{{ para }}</p>
        </section>

        <div class="w-full h-px bg-slate-800 mb-12" />

        <!-- Anforderungen -->
        <section v-if="project.requirements?.length" class="mb-12">
          <h2 class="text-xl font-semibold text-slate-100 mb-4">Anforderungen</h2>
          <p class="text-slate-300 leading-relaxed mb-6">Zu Beginn des Projekts wurden folgende Anforderungen ausgearbeitet:</p>
          <ul class="space-y-3">
            <li
              v-for="req in project.requirements"
              :key="req.title"
              class="flex gap-3 text-slate-300 leading-relaxed"
            >
              <span class="text-sky-400 shrink-0 mt-1">▸</span>
              <span>{{ req.description }}</span>
            </li>
          </ul>
        </section>

        <div class="w-full h-px bg-slate-800 mb-12" />

        <!-- Software -->
        <section class="mb-12">
          <h2 class="text-xl font-semibold text-slate-100 mb-6">Software</h2>
          <img
            v-if="project.architectureDiagram"
            :src="`/images/${project.architectureDiagram}`"
            :alt="`${project.title} Übersicht`"
            class="w-full rounded-xl border border-slate-800 mb-8 cursor-zoom-in"
            @click="openLightbox"
          >

          <!-- New: softwareSections -->
          <template v-if="project.softwareSections">
            <div v-for="(section, i) in project.softwareSections" :key="i" class="mb-8 last:mb-0">
              <h3 v-if="section.heading" class="text-slate-200 font-semibold mb-3">{{ section.heading }}</h3>
              <p
                v-for="(para, j) in section.text.trim().split('\n\n')"
                :key="'t' + j"
                class="text-slate-300 leading-relaxed mb-3 last:mb-0"
              >{{ para }}</p>
              <pre v-if="section.code" class="bg-slate-900 border border-slate-800 rounded-lg p-4 text-sm text-sky-300 font-mono overflow-x-auto my-4 whitespace-pre">{{ section.code }}</pre>
              <p
                v-if="section.textAfter"
                class="text-slate-300 leading-relaxed mt-3"
              >{{ section.textAfter }}</p>
            </div>
          </template>

          <!-- Fallback: plain architecture text -->
          <template v-else>
            <p
              v-for="(para, i) in project.architecture.trim().split('\n\n')"
              :key="i"
              class="text-slate-300 leading-relaxed mb-4 last:mb-0"
            >{{ para }}</p>
          </template>

        </section>


      </template>

      <!-- LEGACY STRUCTURE: projects without motivation field -->
      <template v-else>

        <!-- Description -->
        <section v-if="project.fullDescription" class="mb-12">
          <h2 class="text-xl font-semibold text-slate-100 mb-4">Beschreibung</h2>
          <p
            v-for="(para, i) in project.fullDescription.trim().split('\n\n')"
            :key="i"
            class="text-slate-300 leading-relaxed mb-4 last:mb-0"
          >{{ para }}</p>
        </section>

        <!-- Shader live view -->
        <section v-if="project.shaders?.length" class="mb-12">
          <div class="w-full h-px bg-slate-800 mb-12" />
          <h2 class="text-xl font-semibold text-slate-100 mb-5">Live Vorschau</h2>

          <div class="flex flex-wrap gap-2 mb-5">
            <button
              v-for="shader in project.shaders"
              :key="shader.file"
              @click="activeShader = shader"
              :class="[
                'px-3 py-1.5 rounded-lg text-xs font-mono transition-colors border',
                activeShader?.file === shader.file
                  ? 'bg-sky-400/20 border-sky-400/50 text-sky-400'
                  : 'border-slate-700 text-slate-400 hover:border-slate-600 hover:text-slate-300',
              ]"
            >
              {{ shader.name }}
            </button>
          </div>

          <ShaderViewer
            v-if="activeShader"
            :src="activeShader.file"
            :key="activeShader.file"
          />

          <div class="mt-3 flex flex-col gap-1.5">
            <p v-if="activeShader?.description" class="text-slate-500 text-sm">
              {{ activeShader.description }}
            </p>
            <p
              v-if="activeShader?.heavy"
              class="text-amber-500/70 text-xs flex items-center gap-1.5"
            >
              <svg class="w-3.5 h-3.5 shrink-0" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 2a10 10 0 100 20A10 10 0 0012 2zm1 14.93V17a1 1 0 11-2 0v-.07A8.002 8.002 0 014 9h1a7 7 0 0014 0h1a8.002 8.002 0 01-7 7.93zM11 7V5a1 1 0 112 0v2a1 1 0 11-2 0z"/>
              </svg>
              Rechenintensiver Shader (eventuell niedrige Framerate)
            </p>
          </div>
        </section>

        <div class="w-full h-px bg-slate-800 mb-12" />

        <!-- Shader techniques -->
        <section v-if="project.shaderTechniques?.length" class="mb-12">
          <h2 class="text-xl font-semibold text-slate-100 mb-8">Shader Demos</h2>
          <div class="space-y-8">
            <div v-for="(s, i) in project.shaderTechniques" :key="i">
              <h3 class="text-slate-200 font-semibold mb-2">{{ s.name }}</h3>
              <p class="text-slate-400 text-sm leading-relaxed">{{ s.description }}</p>
            </div>
          </div>
        </section>

      </template>

    </div>

    <!-- Not found -->
    <div v-else class="max-w-3xl mx-auto px-6 py-32 text-center">
      <p class="text-slate-500 mb-4">Projekt nicht gefunden.</p>
      <button
        @click="router.push('/projekte')"
        class="text-sky-400 hover:text-sky-300 transition-colors text-sm"
      >
        Zurück zur Übersicht
      </button>
    </div>
  </div>

  <!-- Lightbox -->
  <Teleport to="body">
    <div
      v-if="lightboxOpen"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/90 p-4"
      @click.self="closeLightbox"
      @keydown.esc="closeLightbox"
      tabindex="0"
    >
      <button
        @click="closeLightbox"
        class="absolute top-4 right-4 text-slate-400 hover:text-white transition-colors"
        aria-label="Schließen"
      >
        <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
      <img
        v-if="project?.architectureDiagram"
        :src="`/images/${project.architectureDiagram}`"
        :alt="`${project.title} Übersicht`"
        class="max-w-full max-h-full rounded-xl object-contain"
      >
    </div>
  </Teleport>
</template>
