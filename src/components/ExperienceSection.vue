<script setup>
import { experience, education } from '@/data/experience.js'
</script>

<template>
  <section id="experience" class="py-24 border-t border-slate-800">
    <div class="max-w-5xl mx-auto px-6">
      <p class="text-sky-400 text-xs font-mono tracking-widest mb-2">Erfahrung</p>
      <h3 class="text-3xl font-bold text-slate-100 mb-12">Beruflicher Werdegang</h3>

      <div class="grid lg:grid-cols-2 gap-16">
        <div>
          <h4 class="text-slate-500 text-xs uppercase tracking-widest mb-8 font-semibold">
            Berufserfahrung
          </h4>
          <div class="relative">
            <div class="absolute left-1.5 top-2 bottom-0 w-px bg-slate-800"></div>
            <div class="space-y-10">
              <div
                v-for="job in experience"
                :key="job.company + job.period"
                class="pl-10 relative"
              >
                <div class="absolute left-0 top-1.5 w-3 h-3 rounded-full bg-sky-400 ring-4 ring-slate-950"></div>
                <div class="flex flex-wrap items-baseline gap-x-2 gap-y-0.5 mb-1">
                  <h5 class="text-slate-100 font-semibold">{{ job.role }}</h5>
                  <span class="text-sky-400 text-sm font-medium">@ {{ job.company }}</span>
                </div>
                <p class="text-slate-500 text-xs font-mono mb-3">{{ job.period }}</p>
                <ul class="space-y-2">
                  <li
                    v-for="item in job.items"
                    :key="item"
                    class="flex gap-2 text-slate-400 text-sm leading-relaxed"
                  >
                    <span class="text-sky-400 shrink-0 mt-0.5">▸</span>
                    <span>{{ item }}</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        <div>
          <h4 class="text-slate-500 text-xs uppercase tracking-widest mb-8 font-semibold">
            Bildungsweg
          </h4>
          <div class="relative">
            <div class="absolute left-1.5 top-2 bottom-0 w-px bg-slate-800"></div>
            <div class="space-y-8">
              <div
                v-for="edu in education"
                :key="edu.institution"
                class="pl-10 relative"
              >
                <div class="absolute left-0 top-1.5 w-3 h-3 rounded-full bg-sky-400/50 ring-4 ring-slate-950"></div>
                <h5 class="text-slate-100 font-semibold">{{ edu.degree }}</h5>
                <p class="text-sky-400/80 text-sm">{{ edu.institution }}</p>
                <p class="text-slate-500 text-xs font-mono mb-2">{{ edu.period }}</p>
                <ul v-if="edu.details.length" class="space-y-1.5">
                  <li
                    v-for="detail in edu.details"
                    :key="typeof detail === 'string' ? detail : detail.text"
                    class="flex gap-2 text-slate-400 text-sm"
                  >
                    <span class="text-sky-400/60 shrink-0">▸</span>
                    <a
                      v-if="typeof detail === 'object' && detail.link"
                      :href="detail.link"
                      target="_blank"
                      rel="noopener noreferrer"
                      class="text-sky-400 hover:text-sky-300 underline underline-offset-4"
                    >{{ detail.text }}</a>
                    <span v-else>{{ typeof detail === 'string' ? detail : detail.text }}</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
