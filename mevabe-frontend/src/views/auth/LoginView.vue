<script setup>
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { toast } from '@/utils/notify'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const loading = ref(false)
const errors = reactive({
  email: '',
  password: '',
})
const form = reactive({
  email: 'admin@mevabe.local',
  password: 'admin123',
})

function validate() {
  errors.email = ''
  errors.password = ''

  if (!form.email.trim()) {
    errors.email = 'Vui lòng nhập email'
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) {
    errors.email = 'Email không hợp lệ'
  }

  if (!form.password) {
    errors.password = 'Vui lòng nhập mật khẩu'
  }

  return !errors.email && !errors.password
}

async function handleSubmit() {
  if (!validate()) return

  loading.value = true
  try {
    await authStore.login(form)
    toast.success('Đăng nhập thành công')
    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/dashboard'
    router.replace(redirect)
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="card login-card shadow-sm">
    <div class="card-body p-4">
      <div class="login-card__header">
        <i class="bi bi-bag-heart text-danger fs-2"></i>
        <h1>MeVaBe Admin</h1>
        <p>Đăng nhập để quản lý cửa hàng mẹ và bé</p>
      </div>

      <form @submit.prevent="handleSubmit">
        <div class="mb-3">
          <label class="form-label" for="email">Email</label>
          <input
            id="email"
            v-model="form.email"
            type="email"
            class="form-control"
            :class="{ 'is-invalid': errors.email }"
            placeholder="admin@mevabe.local"
          />
          <div v-if="errors.email" class="invalid-feedback">{{ errors.email }}</div>
        </div>

        <div class="mb-3">
          <label class="form-label" for="password">Mật khẩu</label>
          <input
            id="password"
            v-model="form.password"
            type="password"
            class="form-control"
            :class="{ 'is-invalid': errors.password }"
            placeholder="Nhập mật khẩu"
          />
          <div v-if="errors.password" class="invalid-feedback">{{ errors.password }}</div>
        </div>

        <button type="submit" class="btn btn-primary w-100" :disabled="loading">
          <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
          Đăng nhập
        </button>
      </form>

      <p class="login-hint">Mock mode: dùng email/mật khẩu bất kỳ (đã điền sẵn).</p>
    </div>
  </div>
</template>

<style scoped>
.login-card {
  width: 100%;
  max-width: 420px;
  border: 0;
  border-radius: 12px;
}

.login-card__header {
  text-align: center;
  margin-bottom: 24px;
}

.login-card__header h1 {
  margin: 12px 0 6px;
  font-size: 24px;
}

.login-card__header p {
  margin: 0;
  color: #909399;
}

.login-hint {
  margin: 16px 0 0;
  font-size: 12px;
  color: #a8abb2;
  text-align: center;
}
</style>
