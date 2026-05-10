<script setup>
import { skills } from '@/data/skills.js'
</script>

<template>
  <section id="skills" class="py-24 border-t border-slate-800">
    <div class="max-w-5xl mx-auto px-6">
      <p class="text-sky-400 text-xs font-mono tracking-widest mb-2">Fähigkeiten</p>
      <h3 class="text-3xl font-bold text-slate-100 mb-12">Technologien &amp; Tools</h3>

      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
        <div
          v-for="group in skills"
          :key="group.category"
          class="bg-slate-900 border border-slate-800 rounded-xl p-6 hover:border-sky-400/30 transition-colors"
        >
          <h4 class="text-slate-200 font-semibold mb-4 text-sm">{{ group.category }}</h4>
          <div class="flex flex-wrap gap-2">
            <span
              v-for="item in group.items"
              :key="item"
              class="text-xs px-2.5 py-1 bg-slate-800 text-sky-300 rounded-full border border-slate-700 font-mono"
            >
              {{ item }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
