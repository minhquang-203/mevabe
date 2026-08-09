import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { fetchMe, login as loginApi, logout as logoutApi } from '@/api/modules/auth'
import { TOKEN_STORAGE_KEY, USER_STORAGE_KEY } from '@/constants'

function readStoredUser() {
  try {
    const raw = localStorage.getItem(USER_STORAGE_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem(TOKEN_STORAGE_KEY) || '')
  const user = ref(readStoredUser())

  const isLoggedIn = computed(() => Boolean(token.value))

  function persist() {
    if (token.value) {
      localStorage.setItem(TOKEN_STORAGE_KEY, token.value)
    } else {
      localStorage.removeItem(TOKEN_STORAGE_KEY)
    }

    if (user.value) {
      localStorage.setItem(USER_STORAGE_KEY, JSON.stringify(user.value))
    } else {
      localStorage.removeItem(USER_STORAGE_KEY)
    }
  }

  async function login(credentials) {
    const data = await loginApi(credentials)
    token.value = data.token
    user.value = data.user
    persist()
    return data
  }

  async function loadProfile() {
    if (!token.value) return null
    const profile = await fetchMe()
    user.value = profile
    persist()
    return profile
  }

  async function logout() {
    try {
      if (token.value) {
        await logoutApi()
      }
    } catch {
      // Ignore logout API errors; clear local session anyway.
    } finally {
      token.value = ''
      user.value = null
      persist()
    }
  }

  return {
    token,
    user,
    isLoggedIn,
    login,
    loadProfile,
    logout,
  }
})
