import axios from 'axios'
import { TOKEN_STORAGE_KEY } from '@/constants'
import { isMockEnabled, mockAdapter } from '@/api/mock'
import { toast } from '@/utils/notify'

const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
  },
})

if (isMockEnabled()) {
  http.defaults.adapter = mockAdapter
}

http.interceptors.request.use((config) => {
  const token = localStorage.getItem(TOKEN_STORAGE_KEY)
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

http.interceptors.response.use(
  (response) => {
    const payload = response.data

    if (payload && typeof payload === 'object' && 'status' in payload) {
      if (payload.status === 'SUCCESS') {
        return payload.data
      }

      const message = payload.message || 'Yêu cầu thất bại'
      toast.error(message)
      return Promise.reject(payload)
    }

    return payload
  },
  async (error) => {
    const status = error.response?.status
    const message =
      error.response?.data?.message || error.message || 'Không thể kết nối tới máy chủ'

    if (status === 401) {
      localStorage.removeItem(TOKEN_STORAGE_KEY)
      localStorage.removeItem('mevabe_admin_user')
      if (window.location.pathname !== '/login') {
        window.location.href = `/login?redirect=${encodeURIComponent(window.location.pathname)}`
      }
    }

    toast.error(message)
    return Promise.reject(error)
  },
)

export default http
