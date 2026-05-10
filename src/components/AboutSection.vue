<script setup>
import { about } from '@/data/about.js'
</script>

<template>
  <section id="about" class="py-24 border-t border-slate-800">
    <div class="max-w-5xl mx-auto px-6">
      <p class="text-sky-400 text-xs font-mono tracking-widest mb-2">Über mich</p>
      <h3 class="text-3xl font-bold text-slate-100 mb-12">Wer bin ich?</h3>

      <div class="max-w-2xl">
        <div>
          <p class="text-slate-300 leading-relaxed mb-5">
            Softwareingenieur mit Schwerpunkt auf Backend- und Cloud-Entwicklung. Fokus auf skalierbare Architekturen und verteilte Systeme, mit ergänzender Erfahrung in der Frontend-Entwicklung.
          </p>
          <p class="text-slate-300 leading-relaxed mb-5">
            Während meines Studiums der angewandten Informatik an der Hochschule Ravensburg-Weingarten absolvierte ich mein Pflichtpraktikum bei der ZF Group und wurde anschließend als Werkstudent Teil des Teams. Nach dem Abschluss wechselte ich zur e-findo GmbH, wo ich hauptsächlich im Backend tätig bin.
          </p>
          <p class="text-slate-300 leading-relaxed">
            In meiner Freizeit arbeite ich derzeit an
            <a
              href="https://magazineguessr.com"
              target="_blank"
              rel="noopener noreferrer"
              class="text-sky-400 hover:text-sky-300 underline underline-offset-4"
            >MagazineGuessr.com</a>.
          </p>
        </div>

      </div>
    </div>
  </section>
</template>
