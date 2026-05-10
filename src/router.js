import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '@/views/HomeView.vue'
import UeberMichView from '@/views/UeberMichView.vue'
import ProjekteView from '@/views/ProjekteView.vue'
import ProjectDetailView from '@/views/ProjectDetailView.vue'

export default createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: HomeView },
    { path: '/ueber-mich', component: UeberMichView },
    { path: '/projekte', component: ProjekteView },
    { path: '/projekte/:slug', component: ProjectDetailView },
  ],
  scrollBehavior(_to, _from, savedPosition) {
    if (savedPosition) return savedPosition
    return { top: 0, behavior: 'instant' }
  },
})
