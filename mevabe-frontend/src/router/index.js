import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      component: () => import('@/layouts/BlankLayout.vue'),
      meta: { guestOnly: true },
      children: [
        {
          path: '',
          name: 'login',
          component: () => import('@/views/auth/LoginView.vue'),
          meta: { title: 'Đăng nhập', guestOnly: true },
        },
      ],
    },
    {
      path: '/',
      component: () => import('@/layouts/AdminLayout.vue'),
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          redirect: '/dashboard',
        },
        {
          path: 'dashboard',
          name: 'dashboard',
          component: () => import('@/views/dashboard/DashboardView.vue'),
          meta: { title: 'Dashboard', requiresAuth: true },
        },
        {
          path: 'products',
          name: 'products',
          component: () => import('@/views/products/ProductListView.vue'),
          meta: { title: 'Sản phẩm', requiresAuth: true },
        },
        {
          path: 'products/create',
          name: 'product-create',
          component: () => import('@/views/products/ProductFormView.vue'),
          meta: { title: 'Thêm sản phẩm', requiresAuth: true },
        },
        {
          path: 'products/:id/edit',
          name: 'product-edit',
          component: () => import('@/views/products/ProductFormView.vue'),
          meta: { title: 'Sửa sản phẩm', requiresAuth: true },
        },
      ],
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'not-found',
      component: () => import('@/views/error/NotFoundView.vue'),
      meta: { title: 'Không tìm thấy' },
    },
  ],
})

router.beforeEach((to) => {
  const auth = useAuthStore()
  const title = to.meta.title ? `${to.meta.title} | MeVaBe Admin` : 'MeVaBe Admin'
  document.title = title

  if (to.meta.requiresAuth && !auth.isLoggedIn) {
    return {
      name: 'login',
      query: { redirect: to.fullPath },
    }
  }

  if (to.meta.guestOnly && auth.isLoggedIn) {
    return { name: 'dashboard' }
  }

  return true
})

export default router
