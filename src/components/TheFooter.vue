<script setup>
import { about } from '@/data/about.js'
</script>

<template>
  <footer class="border-t border-slate-800 py-8 mt-8">
    <div class="max-w-5xl mx-auto px-6 flex flex-col md:flex-row items-center justify-between gap-4">
      <p class="text-slate-600 text-sm">
        Erstellt mit Vue.js und Tailwind CSS
      </p>
      <div class="flex items-center gap-6">
        <a
          :href="about.github"
          target="_blank"
          rel="noopener noreferrer"
          class="text-slate-600 hover:text-sky-400 transition-colors text-sm"
        >
          GitHub
        </a>
        <a
          :href="about.linkedin"
          target="_blank"
          rel="noopener noreferrer"
          class="text-slate-600 hover:text-sky-400 transition-colors text-sm"
        >
          LinkedIn
        </a>
        <a
          :href="`mailto:${about.email}`"
          class="text-slate-600 hover:text-sky-400 transition-colors text-sm"
        >
          E-Mail
        </a>
      </div>
    </div>
  </footer>
</template>
