<script setup>
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { adminMenus } from '@/config/menu'
import { useAppStore } from '@/stores/app'
import { useAuthStore } from '@/stores/auth'
import { confirmDialog } from '@/utils/notify'

const route = useRoute()
const router = useRouter()
const appStore = useAppStore()
const authStore = useAuthStore()

const openMenus = ref(new Set(['catalog', 'content']))

const breadcrumbs = computed(() => {
  return route.matched
    .filter((item) => item.meta?.title)
    .map((item) => ({
      title: item.meta.title,
      path: item.path.startsWith('/') ? item.path : `/${item.path}`,
    }))
})

function isActive(path) {
  return route.path === path || route.path.startsWith(`${path}/`)
}

function isGroupActive(item) {
  return item.children?.some((child) => isActive(child.index))
}

function toggleGroup(index) {
  const next = new Set(openMenus.value)
  if (next.has(index)) next.delete(index)
  else next.add(index)
  openMenus.value = next
}

function go(path) {
  if (!path?.startsWith('/') || path === route.path) return
  router.push(path)
}

async function handleLogout() {
  const ok = await confirmDialog('Bạn có chắc muốn đăng xuất?', 'Xác nhận')
  if (!ok) return
  await authStore.logout()
  router.push({ name: 'login' })
}
</script>

<template>
  <div class="admin-layout" :class="{ 'admin-layout--collapsed': appStore.sidebarCollapsed }">
    <aside class="admin-aside">
      <div class="brand">
        <i class="bi bi-bag-heart"></i>
        <span v-if="!appStore.sidebarCollapsed" class="brand__text">MeVaBe Admin</span>
      </div>

      <nav class="admin-menu">
        <template v-for="item in adminMenus" :key="item.index">
          <div v-if="item.children?.length" class="menu-group">
            <button
              type="button"
              class="menu-link menu-link--group"
              :class="{ active: isGroupActive(item) }"
              @click="toggleGroup(item.index)"
            >
              <i class="bi" :class="item.icon"></i>
              <span v-if="!appStore.sidebarCollapsed" class="menu-link__text">{{ item.title }}</span>
              <i
                v-if="!appStore.sidebarCollapsed"
                class="bi menu-caret"
                :class="openMenus.has(item.index) ? 'bi-chevron-up' : 'bi-chevron-down'"
              ></i>
            </button>
            <div v-show="openMenus.has(item.index) && !appStore.sidebarCollapsed" class="menu-children">
              <button
                v-for="child in item.children"
                :key="child.index"
                type="button"
                class="menu-link menu-link--child"
                :class="{ active: isActive(child.index) }"
                :disabled="child.disabled"
                @click="go(child.index)"
              >
                <span>{{ child.title }}</span>
              </button>
            </div>
          </div>

          <button
            v-else
            type="button"
            class="menu-link"
            :class="{ active: isActive(item.index) }"
            :disabled="item.disabled"
            @click="go(item.index)"
          >
            <i class="bi" :class="item.icon"></i>
            <span v-if="!appStore.sidebarCollapsed" class="menu-link__text">{{ item.title }}</span>
          </button>
        </template>
      </nav>
    </aside>

    <div class="admin-body">
      <header class="admin-header">
        <div class="admin-header__left">
          <button type="button" class="btn btn-light btn-sm" @click="appStore.toggleSidebar">
            <i class="bi" :class="appStore.sidebarCollapsed ? 'bi-layout-sidebar-inset' : 'bi-layout-sidebar'"></i>
          </button>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
              <li class="breadcrumb-item">
                <RouterLink to="/dashboard">Trang chủ</RouterLink>
              </li>
              <li
                v-for="item in breadcrumbs"
                :key="item.path"
                class="breadcrumb-item active"
                aria-current="page"
              >
                {{ item.title }}
              </li>
            </ol>
          </nav>
        </div>

        <div class="dropdown">
          <button
            class="btn btn-light d-flex align-items-center gap-2"
            type="button"
            data-bs-toggle="dropdown"
            aria-expanded="false"
          >
            <span class="user-avatar">{{ authStore.user?.fullName?.[0] || 'A' }}</span>
            <span class="d-none d-sm-inline">{{ authStore.user?.fullName || 'Admin' }}</span>
            <i class="bi bi-chevron-down"></i>
          </button>
          <ul class="dropdown-menu dropdown-menu-end">
            <li>
              <span class="dropdown-item-text text-muted small">
                {{ authStore.user?.email || 'admin@mevabe.local' }}
              </span>
            </li>
            <li><hr class="dropdown-divider" /></li>
            <li>
              <button type="button" class="dropdown-item text-danger" @click="handleLogout">
                Đăng xuất
              </button>
            </li>
          </ul>
        </div>
      </header>

      <main class="admin-main">
        <router-view />
      </main>
    </div>
  </div>
</template>

<style scoped>
.admin-layout {
  display: flex;
  min-height: 100vh;
}

.admin-aside {
  width: 240px;
  flex-shrink: 0;
  background: var(--admin-sidebar-bg);
  color: var(--admin-sidebar-text);
  overflow: hidden;
}

.admin-layout--collapsed .admin-aside {
  width: 64px;
}

.brand {
  height: 60px;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0 16px;
  color: #fff;
  font-weight: 700;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.brand i {
  font-size: 1.35rem;
}

.brand__text {
  white-space: nowrap;
}

.admin-menu {
  padding: 10px 8px;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.menu-link {
  width: 100%;
  border: 0;
  outline: none;
  box-shadow: none;
  background: transparent;
  color: var(--admin-sidebar-text);
  display: flex;
  align-items: center;
  gap: 10px;
  min-height: 42px;
  padding: 10px 12px;
  border-radius: 8px;
  text-align: left;
  line-height: 1.2;
  cursor: pointer;
  transition: background-color 0.15s ease, color 0.15s ease;
}

.menu-link i {
  width: 1.25rem;
  text-align: center;
  font-size: 1.05rem;
  flex-shrink: 0;
}

.menu-link:hover:not(:disabled):not(.active) {
  background: rgba(255, 255, 255, 0.06);
  color: #e8eef5;
}

.menu-link:focus-visible {
  background: rgba(255, 255, 255, 0.08);
  color: #fff;
}

.menu-link.active {
  color: var(--admin-sidebar-active);
  background: rgba(255, 157, 176, 0.14);
  font-weight: 600;
}

.menu-link.active:hover:not(:disabled) {
  color: var(--admin-sidebar-active);
  background: rgba(255, 157, 176, 0.2);
}

.menu-link:disabled {
  opacity: 0.38;
  cursor: not-allowed;
  background: transparent !important;
  color: var(--admin-sidebar-text) !important;
}

.menu-link__text {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.menu-caret {
  font-size: 0.75rem;
  opacity: 0.65;
  margin-left: auto;
}

.menu-children {
  display: flex;
  flex-direction: column;
  gap: 2px;
  margin: 2px 0 6px;
  padding-left: 0;
}

.menu-link--child {
  min-height: 36px;
  padding: 8px 12px 8px 42px;
  font-size: 0.92rem;
  position: relative;
}

.menu-link--child::before {
  content: '';
  position: absolute;
  left: 22px;
  top: 50%;
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: currentColor;
  opacity: 0.35;
  transform: translateY(-50%);
}

.menu-link--child.active::before {
  opacity: 1;
  background: var(--admin-sidebar-active);
}

.admin-layout--collapsed .menu-link {
  justify-content: center;
  padding: 10px 0;
}

.admin-layout--collapsed .menu-link i {
  margin: 0;
}

.admin-body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.admin-header {
  height: 60px;
  background: #fff;
  border-bottom: 1px solid #ebeef5;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 0 16px;
}

.admin-header__left {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
}

.user-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #ff9db0;
  color: #fff;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
}

.admin-main {
  padding: 20px;
}
</style>
