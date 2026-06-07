<script setup>
import { skills } from '@/data/skills.js'

const levels = [
  { dots: 1, label: 'Grundkenntnisse' },
  { dots: 2, label: 'Erfahren' },
  { dots: 3, label: 'Vertieft' },
]
</script>

<template>
  <section id="skills" class="py-24 border-t border-slate-800">
    <div class="max-w-5xl mx-auto px-6">
      <p class="text-sky-400 text-xs font-mono tracking-widest mb-2">Fähigkeiten</p>
      <h3 class="text-3xl font-bold text-slate-100 mb-6">Technologien &amp; Skills</h3>

      <div class="flex flex-wrap gap-6 mb-12">
        <div v-for="lvl in levels" :key="lvl.dots" class="flex items-center gap-2">
          <div class="flex gap-1">
            <div
              v-for="i in 3"
              :key="i"
              class="w-2 h-2 rounded-full"
              :class="i <= lvl.dots ? 'bg-sky-400' : 'bg-slate-700'"
            />
          </div>
          <span class="text-slate-400 text-xs font-mono">{{ lvl.label }}</span>
        </div>
      </div>

      <div class="grid md:grid-cols-2 gap-x-12 gap-y-10">
        <div v-for="group in skills" :key="group.category">
          <h4 class="text-slate-400 text-xs font-mono tracking-widest uppercase mb-4">
            {{ group.category }}
          </h4>
          <div>
            <div
              v-for="skill in group.items"
              :key="skill.name"
              class="flex items-center justify-between py-2.5 border-b border-slate-800 last:border-0"
            >
              <span class="text-slate-200 text-sm">{{ skill.name }}</span>
              <div class="flex gap-1 shrink-0 ml-4">
                <div
                  v-for="i in 3"
                  :key="i"
                  class="w-2 h-2 rounded-full transition-colors"
                  :class="i <= skill.level ? 'bg-sky-400' : 'bg-slate-700'"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
