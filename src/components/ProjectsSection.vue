<script setup>
import { reactive, computed } from 'vue'
import { projects } from '@/data/projects.js'

const imageLoaded = reactive({})

const projectsByYear = computed(() => {
  const years = [...new Set(projects.map(p => p.year))].sort((a, b) => b - a)
  return years.map(year => ({
    year,
    projects: projects.filter(p => p.year === year),
  }))
})
</script>

<template>
  <section id="projects" class="py-24 border-t border-slate-800">
    <div class="max-w-5xl mx-auto px-6">
      <p class="text-sky-400 text-xs font-mono tracking-widest mb-2">Portfolio</p>
      <h3 class="text-3xl font-bold text-slate-100 mb-12">Projekte</h3>

      <div class="space-y-12">
        <div v-for="group in projectsByYear" :key="group.year">
          <p class="text-slate-500 text-xs font-mono tracking-widest mb-5">{{ group.year }}</p>
          <div class="grid md:grid-cols-2 gap-6">
        <RouterLink
          v-for="project in group.projects"
          :key="project.slug"
          :to="`/projekte/${project.slug}`"
          class="bg-slate-900 border border-slate-800 rounded-xl overflow-hidden hover:border-sky-400/30 transition-colors group flex flex-col"
        >
          <div class="relative overflow-hidden h-44 bg-slate-800">
            <template v-if="project.image">
              <!-- Spinner shown until image loads -->
              <div
                v-show="!imageLoaded[project.slug]"
                class="absolute inset-0 flex items-center justify-center"
              >
                <div class="w-7 h-7 border-2 border-sky-400 border-t-transparent rounded-full animate-spin" />
              </div>
              <img
                :src="`/images/${project.image}`"
                :alt="project.title"
                v-show="imageLoaded[project.slug]"
                @load="imageLoaded[project.slug] = true"
                class="w-full h-44 object-cover opacity-70 group-hover:opacity-90 group-hover:scale-105 transition-all duration-500"
              >
            </template>
            <div v-else class="absolute inset-0 flex items-center justify-center">
              <svg class="w-14 h-14 text-sky-400/20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
              </svg>
            </div>
          </div>

          <div class="p-5 flex flex-col flex-1">
            <div class="flex items-start justify-between gap-3 mb-1">
              <h4 class="text-slate-100 font-semibold group-hover:text-sky-400 transition-colors">
                {{ project.title }}
              </h4>
              <a
                v-if="project.links?.live"
                :href="project.links.live"
                target="_blank"
                rel="noopener noreferrer"
                @click.stop
                class="text-slate-500 hover:text-sky-400 transition-colors shrink-0 mt-0.5"
                :aria-label="`${project.title} öffnen`"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                </svg>
              </a>
            </div>

            <p v-if="project.subheading" class="text-sky-400/70 text-xs font-mono mb-3">
              {{ project.subheading }}
            </p>

            <p class="text-slate-400 text-sm leading-relaxed mb-4 flex-1">
              {{ project.description }}
            </p>

            <div class="flex justify-end mt-auto">
              <span class="text-slate-600 group-hover:text-sky-400 transition-colors text-xs font-mono">
                Details →
              </span>
            </div>
          </div>
        </RouterLink>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
