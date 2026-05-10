<script setup>
import TheNavbar from '@/components/TheNavbar.vue'
import TheFooter from '@/components/TheFooter.vue'
</script>

<template>
  <div class="min-h-screen bg-slate-950 text-slate-100">
    <TheNavbar />
    <main>
      <RouterView />
    </main>
    <TheFooter />
  </div>
</template>
